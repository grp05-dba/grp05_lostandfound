<?php

class ClaimService {
    private ClaimRepository $claimRepository;

    public function __construct(PDO $connection) {
        $this->claimRepository = new ClaimRepository($connection);
    }

    public function getAllClaims(): array {
        return $this->claimRepository->getAll();
    }

    public function getClaimById(int $id): array {
        $claim = $this->claimRepository->getById($id);
        if ($claim === false) {
            http_response_code(404);
            return ['message' => 'No claim found.'];
        }
        return $claim;
    }
}
