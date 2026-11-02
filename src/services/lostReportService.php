<?php

class LostReportService {
    private LostReportRepository $lostReportRepository;
    private CategoryRepository $categoryRepository;

    public function __construct(PDO $connection) {
        $this->lostReportRepository = new LostReportRepository($connection);
        $this->categoryRepository = new CategoryRepository($connection);
    }

    public function getAllLostReports(): array {
        return $this->lostReportRepository->getAll();
    }

    public function getLostReportById(int $id): array {
        $success = $this->lostReportRepository->getById($id);
        return RequestUtils::handleFindFailure($success) ?? $success;
    }

    public function createLostReport(array $data): array {
        $validationError = RequestUtils::validateRequiredFields($data, LostReport::class, ['phone_number', 'location_lost', 'date_lost', 'time_lost', 'report_code']);
        if ($validationError) {
            return $validationError;
        }

        $validationError = RequestUtils::validateGeneralFields($data);
        if ($validationError) {
            return $validationError;
        }

        $validationError = RequestUtils::validateDateTimeFields($data);
        if ($validationError) {
            return $validationError;
        }

        if (!$this->categoryRepository->getById($data['category_id'])) {
            http_response_code(400);
            return ['message' => 'Invalid category_id provided.'];
        }

        $report = new LostReport(
            report_code: $this->generateReportCode(),
            category_id: $data['category_id'],
            title: $data['title'],
            description: $data['description'],
            location_lost: ($data['location_lost'] ?? '') === '' ? null : $data['location_lost'],
            date_lost: ($data['date_lost'] ?? '') === '' ? null : $data['date_lost'],
            time_lost: ($data['time_lost'] ?? '') === '' ? null : $data['time_lost'],
            full_name: $data['full_name'],
            student_number: $data['student_number'],
            email: $data['email'],
            phone_number: ($data['phone_number'] ?? '') === '' ? null : $data['phone_number']
        );

        return RequestUtils::handleCreateFailure($this->lostReportRepository->create($report));
    }

    //needs to be fixed
    private function generateReportCode(): string {
        do {
            $code = 'LR-' . strtoupper(bin2hex(random_bytes(16)));
        } while ($this->lostReportRepository->codeExists($code));
        return $code;
    }
}
