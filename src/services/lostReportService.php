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

        if (array_key_exists('contact_preference', $data) && !in_array($data['contact_preference'], ['email', 'sms'], true)) {
            http_response_code(400);
            return ['message' => 'Invalid contact_preference. Allowed values: email, sms.'];
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
    }

    public function createLostReport(array $data): array {
        $validationError = RequestUtils::validateRequiredFields($data, LostReport::class, ['phone_number', 'location_lost', 'date_lost', 'time_lost', 'report_code', 'contact_preference']);
        if ($validationError) return $validationError;

        $validationError = RequestUtils::validateGeneralFields($data);
        if ($validationError) return $validationError;

        $validationError = RequestUtils::validateDateTimeFields($data);
        if ($validationError) return $validationError;

        if (isset($data['contact_preference']) && !in_array($data['contact_preference'], ['email', 'sms'], true)) {
            http_response_code(400);
            return ['message' => 'Invalid contact_preference. Allowed values: email, sms.'];
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
            phone_number: ($data['phone_number'] ?? '') === '' ? null : $data['phone_number'],
            contact_preference: $data['contact_preference'] ?? 'email'
        );

        $reportId = $this->lostReportRepository->create($report);
        if ($reportId === false) return RequestUtils::handleCreateFailure(false);

        try {
            $this->potentialMatchService->generatePotentialMatches();
        } catch (Throwable $e) {
            error_log('Potential matching after lost report creation failed: ' . $e->getMessage());
        }

        return array_merge(RequestUtils::handleCreateFailure(true), [
            'report_id' => $reportId,
            'report_code' => $report->getReportCode()
        ]);
    }

    private function generateReportCode(): string {
        do {
            $code = 'LR-' . date('Y') . '-' . random_int(100000, 999999);
        } while ($this->lostReportRepository->codeExists($code));
        return $code;
    }
}
