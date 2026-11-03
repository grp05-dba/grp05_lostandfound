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
