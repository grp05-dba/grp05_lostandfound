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

    public function updateLostReport(int $reportId, array $data): array {
        try {
            $report = $this->lostReportRepository->getById($reportId);
            if (!$report) {
                http_response_code(404);
                return ['message' => 'Lost report not found.'];
            }

            if ($data === []) {
                http_response_code(400);
                return ['message' => 'Request body must contain at least one field.'];
            }

            $validationError = RequestUtils::validatePatchFields($data, LostReport::class);
            if ($validationError) return $validationError;

            $validationError = RequestUtils::validateGeneralFields($data);
            if ($validationError) return $validationError;

            $validationError = RequestUtils::validateDateTimeFields($data);
            if ($validationError) return $validationError;

            if (array_key_exists('report_code', $data)) {
                if (!is_string($data['report_code'])) {
                    http_response_code(400);
                    return ['message' => 'Invalid report_code provided.'];
                }

                if (
                    $data['report_code'] !== $report['report_code'] &&
                    $this->lostReportRepository->codeExists($data['report_code'])
                ) {
                    http_response_code(409);
                    return ['message' => 'The report_code is already in use.'];
                }
            }

            if (array_key_exists('category_id', $data)) {
                $categoryId = filter_var($data['category_id'], FILTER_VALIDATE_INT);
                if ($categoryId === false || $categoryId < 1 || !$this->categoryRepository->getById($categoryId)) {
                    http_response_code(400);
                    return ['message' => 'Invalid category_id provided.'];
                }
                $data['category_id'] = $categoryId;
            }

            if (array_key_exists('status', $data)) {
                $allowedStatuses = ['active', 'resolved', 'cancelled'];
                if (!is_string($data['status']) || !in_array($data['status'], $allowedStatuses, true)) {
                    http_response_code(400);
                    return ['message' => 'Invalid status provided. Allowed values: active, resolved, cancelled.'];
                }
            }

            $success = $this->lostReportRepository->update($reportId, $data);
            return RequestUtils::handleUpdateFailure($success);
        } catch (PDOException $exception) {
            // Keep database details in server logs; never expose them in the API response.
            error_log('Failed to update lost report: ' . $exception->getMessage());
            http_response_code(500);
            return ['message' => 'Failed to update lost report.'];
        }
    }

    public function createLostReport(array $data): array {
        $validationError = RequestUtils::validateRequiredFields($data, LostReport::class, ['phone_number', 'location_lost', 'date_lost', 'time_lost', 'report_code']);
        if ($validationError) return $validationError;

        $validationError = RequestUtils::validateGeneralFields($data);
        if ($validationError) return $validationError;

        $validationError = RequestUtils::validateDateTimeFields($data);
        if ($validationError) return $validationError;

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

    private function generateReportCode(): string {
        do {
            $code = 'LR-' . date('Y') . '-' . random_int(100000, 999999);
        } while ($this->lostReportRepository->codeExists($code));
        return $code;
    }
}