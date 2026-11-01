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
        $validationError = RequestUtils::validateRequestBody($data, Claim::class, ['phone_number'], ['claim_code']);
        if ($validationError) {
            return $validationError;
        }

        foreach (['full_name' => 150, 'student_number' => 50, 'email' => 150, 'phone_number' => 50] as $field => $limit) {
            if (isset($data[$field]) && preg_match_all('/./us', $data[$field]) > $limit) {
                http_response_code(400);
                return ['message' => 'Field too long: ' . $field];
            }
        }
        if (!filter_var($data['email'], FILTER_VALIDATE_EMAIL)) {
            http_response_code(400);
            return ['message' => 'Invalid email provided.'];
        }

        $item = $this->itemRepository->getById($data['item_id']);
        if (!$item || $item['status'] !== 'unclaimed') {
            http_response_code(400);
            return ['message' => 'Item does not exist or is not eligible to be claimed.'];
        }

        $claim = new Claim(
            claim_code: $this->claimRepository->generateClaimCode(),
            item_id: $data['item_id'],
            full_name: $data['full_name'],
            student_number: $data['student_number'],
            email: $data['email'],
            phone_number: ($data['phone_number'] ?? '') === '' ? null : $data['phone_number']
        );

        return RequestUtils::handleCreateFailure($this->claimRepository->create($claim));
    }
}
