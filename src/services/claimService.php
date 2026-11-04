<?php

class ClaimService {
    private ClaimRepository $claimRepository;
    private ItemRepository $itemRepository;

    public function __construct(PDO $connection) {
        $this->claimRepository = new ClaimRepository($connection);
        $this->itemRepository = new ItemRepository($connection);
    }

    public function getAllClaims(): array {
        return $this->claimRepository->getAll();
    }

    public function getClaimById(int $id): array {
        $success = $this->claimRepository->getById($id);
        return RequestUtils::handleFindFailure($success) ?? $success;
    }

    public function updateClaim(int $claimId, array $data): array {
        $claim = $this->claimRepository->getById($claimId);
        if (!$claim) {
            http_response_code(404);
            return ['message' => 'Claim not found.'];
        }

        $validationError = RequestUtils::validatePatchFields($data, Claim::class);
        if ($validationError) return $validationError;

        $validationError = RequestUtils::validateGeneralFields($data);
        if ($validationError) return $validationError;

        if (isset($data['item_id'])) {
            $item = $this->itemRepository->getById((int) $data['item_id']);

            if (!$item) {
                http_response_code(400);
                return ['message' => 'Invalid item_id provided.'];
            }
        }

        if (array_key_exists('status', $data)) {
            $allowedStatuses = ['pending', 'approved', 'rejected'];
            if (!is_string($data['status']) || !in_array($data['status'], $allowedStatuses, true)) {
                http_response_code(400);
                return ['message' => 'Invalid status provided. Allowed values: pending, approved, rejected.'];
            }
        }

        $success = $this->claimRepository->update($claimId, $data);
        return RequestUtils::handleUpdateFailure($success);
    }

    public function createClaim(array $data): array {
        $validationError = RequestUtils::validateRequiredFields($data, Claim::class, ['phone_number', 'claim_code']);
        if ($validationError) return $validationError;

        $validationError = RequestUtils::validateGeneralFields($data);
        if ($validationError) return $validationError;

        $item = $this->itemRepository->getById($data['item_id']);
        if (!$item || $item['status'] !== 'unclaimed') {
            http_response_code(400);
            return ['message' => 'Item does not exist or is not eligible to be claimed.'];
        }

        $claim = new Claim(
            claim_code: $this->generateClaimCode(),
            item_id: $data['item_id'],
            full_name: $data['full_name'],
            student_number: $data['student_number'],
            email: $data['email'],
            phone_number: $data['phone_number'] ?? null
        );

        return RequestUtils::handleCreateFailure($this->claimRepository->create($claim));
    }

    public function getClaimByCode(string $code): array {
        $success = $this->claimRepository->getByCode($code);
        return RequestUtils::handleFindFailure($success) ?? $success;
    }

    
    // Private helper methods --------------------------------
    private function generateClaimCode(): string {
        do {
            $code = 'CLM-' . date('Y') . '-' . random_int(100000, 999999);
        } while ($this->claimRepository->codeExists($code));
        return $code;
    }

    
}
