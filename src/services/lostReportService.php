<?php

class LostReportService {
    private LostReportRepository $lostReportRepository;

    public function __construct(PDO $connection) {
        $this->lostReportRepository = new LostReportRepository($connection);
    }

    public function getAllLostReports(): array {
        return $this->lostReportRepository->getAll();
    }

    public function getLostReportById(int $id): array {
        $success = $this->lostReportRepository->getById($id);
        return RequestUtils::handleFindFailure($success) ?? $success;
    }
}
