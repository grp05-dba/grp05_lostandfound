<?php

class ClaimService {
    private ClaimRepository $claimRepository;

    public function __construct(PDO $connection) {
        $this->claimRepository = new ClaimRepository($connection);
    }

    public function getAllClaims(): array {
        return $this->claimRepository->getAll();
    }

    public function getClaimById(string $id): array {
        if (!ctype_digit($id) || (int) $id < 1 || (float) $id > 2147483647) {
            http_response_code(400);
            return ['error' => 'ID must be a positive integer.'];
        }
        $claim = $this->claimRepository->getById((int) $id);
        if ($claim === false) {
            http_response_code(404);
            return ['message' => 'No claim found.'];
        }
        return $claim;
    }
}
