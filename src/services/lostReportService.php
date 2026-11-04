<?php

class LostReportService {
    private LostReportRepository $lostReportRepository;
    private CategoryRepository $categoryRepository;

    private PotentialMatchService $potentialMatchService;

    public function __construct(PDO $connection) {
        $this->lostReportRepository = new LostReportRepository($connection);
        $this->categoryRepository = new CategoryRepository($connection);
        $this->potentialMatchService = new PotentialMatchService($connection);
    }

    public function getAllLostReports(): array {
        return $this->lostReportRepository->getAll();
    }

    public function getLostReportById(int $id): array {
        $success = $this->lostReportRepository->getById($id);
        return RequestUtils::handleFindFailure($success) ?? $success;
    }

    public function updateLostReport(int $reportId, array $data): array {
        $report = $this->lostReportRepository->getById($reportId);
        if (!$report) {
            http_response_code(404);
            return ['message' => 'Lost report not found.'];
        }

        $validationError = RequestUtils::validatePatchFields($data, LostReport::class);
        if ($validationError) return $validationError;

        $validationError = RequestUtils::validateGeneralFields($data);
        if ($validationError) return $validationError;

        $validationError = RequestUtils::validateDateTimeFields($data);
        if ($validationError) return $validationError;

        if (isset($data['category_id'])) {
            $category = $this->categoryRepository->getById((int) $data['category_id']);

            if (!$category) {
                http_response_code(400);
                return ['message' => 'Invalid category_id provided.'];
            }
        }

        if (array_key_exists('status', $data)) {
            $allowedStatuses = ['active', 'resolved', 'cancelled'];
            if (!is_string($data['status']) || !in_array($data['status'], $allowedStatuses, true)) {
                http_response_code(400);
                return ['message' => 'Invalid status provided. Allowed values: active, resolved, cancelled.'];
            }

        }

        $success = $this->lostReportRepository->update($reportId, $data);
        $matchesRefreshed = 0;

        if ($success) {
            $updatedReport = $this->lostReportRepository->getById($reportId);

            if ($updatedReport) {
                if ($updatedReport['status'] !== 'active') {
                    $this->potentialMatchService->deleteByReportId($reportId);
                    $matchesRefreshed = 2;
                } elseif (
                    $report['status'] !== 'active' ||
                    $this->potentialMatchService->hasMatchingFieldsChanged($data, $report)
                ) {
                    $this->potentialMatchService->deleteByReportId($reportId);
                    $this->potentialMatchService->findPotentialMatches($updatedReport);
                    $matchesRefreshed = 1;
                }
            }
        }
        return RequestUtils::handleUpdateFailure($success, $matchesRefreshed);
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

        $createdReport = $this->lostReportRepository->create($report);

        if (!$createdReport) {
            return RequestUtils::handleCreateFailure(false);
        }

        $this->potentialMatchService->findPotentialMatches($createdReport);
        return RequestUtils::handleCreateFailure(true);
    }
    
    public function getLostReportByCode(string $code): array {
        $success = $this->lostReportRepository->getByCode($code);
        return RequestUtils::handleFindFailure($success) ?? $success;
    }
    

    // Private helper methods --------------------------------
    private function generateReportCode(): string {
        do {
            $code = 'LR-' . date('Y') . '-' . random_int(100000, 999999);
        } while ($this->lostReportRepository->codeExists($code));
        return $code;
    }
}