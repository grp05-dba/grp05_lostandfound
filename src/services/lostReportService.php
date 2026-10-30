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
        $report = $this->lostReportRepository->getById($id);
        if ($report === false) {
            http_response_code(404);
            return ['message' => 'No report found.'];
        }
        return $report;
    }
}
