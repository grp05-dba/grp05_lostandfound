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

        if ($data === []) {
            http_response_code(400);
            return ['message' => 'Request body must contain at least one field.'];
        }

        $validationError = RequestUtils::validatePatchFields($data, Claim::class);
        if ($validationError) return $validationError;

        $validationError = RequestUtils::validateGeneralFields($data);
        if ($validationError) return $validationError;

        if (array_key_exists('claim_code', $data)) {
            if (!is_string($data['claim_code']) || trim($data['claim_code']) === '' || mb_strlen($data['claim_code']) > 50) {
                http_response_code(400);
                return ['message' => 'Invalid claim_code provided.'];
            }
        }

        if (array_key_exists('item_id', $data)) {
            $itemId = filter_var($data['item_id'], FILTER_VALIDATE_INT);
            if ($itemId === false || $itemId < 1 || !$this->itemRepository->getById($itemId)) {
                http_response_code(400);
                return ['message' => 'Invalid item_id provided.'];
            }
            $data['item_id'] = $itemId;
        }

        if (array_key_exists('student_number', $data)) {
            if (!is_string($data['student_number']) || trim($data['student_number']) === '' || mb_strlen($data['student_number']) > 50) {
                http_response_code(400);
                return ['message' => 'Invalid student_number provided.'];
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

    private function generateClaimCode(): string {
        do {
            $code = 'CLM-' . date('Y') . '-' . random_int(100000, 999999);
        } while ($this->claimRepository->codeExists($code));
        return $code;
    }
}
