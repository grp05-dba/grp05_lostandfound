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
        $success = $this->claimRepository->getById($id);
        return RequestUtils::handleFindFailure($success) ?? $success;
    }
}
