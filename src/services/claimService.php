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
        $validationError = RequestUtils::validateRequestBody($data, Claim::class, ['phone_number', 'claim_code']);
        if ($validationError) {
            return $validationError;
        }

        $validationError = $this->validateClaim($data);
        if ($validationError) {
            return $validationError;
        }

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
            phone_number: ($data['phone_number'] ?? '') === '' ? null : $data['phone_number']
        );

        return RequestUtils::handleCreateFailure($this->claimRepository->create($claim));
    }

    private function validateClaim(array $data): ?array {
        if (!is_int($data['item_id']) || $data['item_id'] < 1 || $data['item_id'] > 2147483647) {
            http_response_code(400);
            return ['message' => 'Invalid field: item_id'];
        }

        foreach (['full_name' => 150, 'student_number' => 50, 'email' => 150, 'phone_number' => 50] as $field => $limit) {
            $value = $data[$field] ?? null;
            if (in_array($field, ['phone_number'], true) && ($value === null || $value === '')) {
                continue;
            }
            if (!is_string($value) || trim($value) === '' || str_contains($value, "\0")) {
                http_response_code(400);
                return ['message' => 'Invalid field: ' . $field];
            }
            if ($limit !== null && preg_match_all('/./us', $value) > $limit) {
                http_response_code(400);
                return ['message' => 'Field too long: ' . $field];
            }
        }
        if (!filter_var($data['email'], FILTER_VALIDATE_EMAIL)) {
            http_response_code(400);
            return ['message' => 'Invalid email provided.'];
        }

        return null;
    }

    private function generateClaimCode(): string {
        do {
            $code = 'CLM-' . strtoupper(bin2hex(random_bytes(16)));
        } while ($this->claimRepository->codeExists($code));
        return $code;
    }
}
