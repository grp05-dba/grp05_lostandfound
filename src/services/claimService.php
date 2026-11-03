<?php

class ClaimService {
    private ClaimRepository $claimRepository;
    private ItemRepository $itemRepository;
    private PotentialMatchRepository $potentialMatchRepository;

    public function __construct(PDO $connection) {
        $this->claimRepository = new ClaimRepository($connection);
        $this->itemRepository = new ItemRepository($connection);
        $this->potentialMatchRepository = new PotentialMatchRepository($connection);
    }

    public function getAllClaims(): array {
        return $this->claimRepository->getAll();
    }

    public function getClaimById(int $id): array {
        $success = $this->claimRepository->getById($id);
        return RequestUtils::handleFindFailure($success) ?? $success;
    }

    public function getClaimByCode(string $claimCode): array {
        $claim = $this->claimRepository->getByCode($claimCode);

        if (!$claim) {
            http_response_code(404);
            return ['message' => 'Claim not found.'];
        }

        return [
            'claim' => $claim,
            'potential_matches' => $this->potentialMatchRepository->getByItemId((int) $claim['item_id'])
        ];
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

        $validationError = $this->validateContactPreference($data, $claim);
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

        $validationError = $this->validateContactPreference($data);
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
            contact_preference: $data['contact_preference'],
            phone_number: $data['phone_number'] ?? null
        );

        return RequestUtils::handleCreateFailure($this->claimRepository->create($claim));
    }

    private function validateContactPreference(array $data, ?array $existingClaim = null): ?array {
        $preference = $data['contact_preference'] ?? $existingClaim['contact_preference'] ?? null;

        if (!is_string($preference) || !in_array($preference, ['email', 'phone'], true)) {
            http_response_code(400);
            return ['message' => 'Invalid contact_preference provided. Allowed values: email, phone.'];
        }

        $phoneNumber = array_key_exists('phone_number', $data)
            ? $data['phone_number']
            : ($existingClaim['phone_number'] ?? null);
        if ($preference === 'phone' && empty($phoneNumber)) {
            http_response_code(400);
            return ['message' => 'A phone_number is required when contact_preference is phone.'];
        }

        return null;
    }

    private function generateClaimCode(): string {
        do {
            $code = 'CLM-' . date('Y') . '-' . random_int(100000, 999999);
        } while ($this->claimRepository->codeExists($code));
        return $code;
    }
}
