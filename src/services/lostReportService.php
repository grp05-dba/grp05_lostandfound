<?php

class LostReportService {
    private LostReportRepository $lostReportRepository;

    public function __construct(PDO $connection) {
        $this->lostReportRepository = new LostReportRepository($connection);
    }

    public function getAllLostReports(): array {
        return $this->lostReportRepository->getAll();
    }

    public function getLostReportById(string $id): array {
        if (!ctype_digit($id) || (int) $id < 1 || (float) $id > 2147483647) {
            http_response_code(400);
            return ['error' => 'ID must be a positive integer.'];
        }
        $report = $this->lostReportRepository->getById((int) $id);
        if ($report === false) {
            http_response_code(404);
            return ['message' => 'No report found.'];
        }
        return $report;
    }
}
