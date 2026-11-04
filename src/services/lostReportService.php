<?php

class LostReportService {
    private LostReportRepository $lostReportRepository;
    private CategoryRepository $categoryRepository;

    private PotentialMatchService $potentialMatchService;
    private SMSService $smsService;
    private EmailService $emailService;

    public function __construct(PDO $connection) {
        $this->lostReportRepository = new LostReportRepository($connection);
        $this->categoryRepository = new CategoryRepository($connection);
        $this->potentialMatchService = new PotentialMatchService($connection);
        $this->smsService = new SMSService();
        $this->emailService = new EmailService();
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

        $data = RequestUtils::normalizeContactFields($data);

        $validationError = RequestUtils::validatePatchFields($data, LostReport::class);
        if ($validationError) return $validationError;

        $validationError = RequestUtils::validateGeneralFields($data);
        if ($validationError) return $validationError;

        $validationError = RequestUtils::validateContactPreference($data, $report);
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
        $matchesSaved = null;

        if ($success) {
            $updatedReport = $this->lostReportRepository->getById($reportId);

            if ($updatedReport) {
                if (
                    $report['status'] !== 'cancelled' &&
                    $updatedReport['status'] === 'cancelled' &&
                    $updatedReport['contact_preference'] === 'sms' &&
                    !empty($updatedReport['phone_number'])
                ) {
                    $smsResult = $this->smsService->sendSMSLostReportCancellation($updatedReport);
                    error_log('TextBee lost-report cancellation response: ' . json_encode($smsResult));
                }

                if (
                    $report['status'] !== 'cancelled' &&
                    $updatedReport['status'] === 'cancelled' &&
                    $updatedReport['contact_preference'] === 'email' &&
                    !empty($updatedReport['email'])
                ) {
                    $emailResult = $this->emailService->sendEmailLostReportCancellation($updatedReport);
                    error_log('EmailJS lost-report cancellation response: ' . json_encode($emailResult));
                }

                if ($updatedReport['status'] !== 'active') {
                    $this->potentialMatchService->deleteByReportId($reportId);
                    $matchesRefreshed = 2;
                } elseif (
                    $report['status'] !== 'active' ||
                    $this->potentialMatchService->hasMatchingFieldsChanged($data, $report)
                ) {
                    $this->potentialMatchService->deleteByReportId($reportId);
                    $matchesSaved = $this->potentialMatchService->findPotentialMatches($updatedReport);
                    $matchesRefreshed = 1;
                }
            }
        }
        return RequestUtils::handleUpdateFailure($success, $matchesRefreshed, $matchesSaved);
    }

    public function createLostReport(array $data): array {
        $data = RequestUtils::normalizeContactFields($data);

        $validationError = RequestUtils::validateRequiredFields($data, LostReport::class, ['email', 'phone_number', 'contact_preference', 'location_lost', 'date_lost', 'time_lost', 'report_code']);
        if ($validationError) return $validationError;

        $validationError = RequestUtils::validateGeneralFields($data);
        if ($validationError) return $validationError;

        $validationError = RequestUtils::validateContactPreference($data);
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
            email: $data['email'] ?? null,
            phone_number: $data['phone_number'] ?? null,
            contact_preference: $data['contact_preference'] ?? 'email'
        );

        $createdReport = $this->lostReportRepository->create($report);

        if (!$createdReport) {
            return RequestUtils::handleCreateFailure(false);
        }

        $matchesSaved = $this->potentialMatchService->findPotentialMatches($createdReport);

        if (
            $createdReport['contact_preference'] === 'sms' &&
            !empty($createdReport['phone_number'])
        ) {
            $smsResult = $this->smsService->sendSMSLostReportCreation($createdReport);
            error_log('TextBee lost-report creation response: ' . json_encode($smsResult));
        } elseif (
            $createdReport['contact_preference'] === 'email' &&
            !empty($createdReport['email'])
        ) {
            $emailResult = $this->emailService->sendEmailLostReportCreation($createdReport);
            error_log('EmailJS lost-report creation response: ' . json_encode($emailResult));
        }

        return RequestUtils::handleCreateFailure(true, $matchesSaved);
    }
    
    public function getLostReportByCode(string $code): array {
        $success = $this->lostReportRepository->getByCode($code);

        if ($success && $success['status'] !== 'active') {
            http_response_code(404);
            return ['message' => 'Active lost report not found.'];
        }

        return RequestUtils::handleFindFailure($success) ?? $success;
    }

    public function cancelLostReportByCode(string $code): array {
        $report = $this->lostReportRepository->getByCode($code);

        if (!$report || $report['status'] !== 'active') {
            http_response_code(404);
            return ['message' => 'Active lost report not found.'];
        }

        return $this->updateLostReport((int) $report['report_id'], ['status' => 'cancelled']);
    }
    

    // Private helper methods --------------------------------
    private function generateReportCode(): string {
        do {
            $code = 'LR-' . date('Y') . '-' . random_int(100000, 999999);
        } while ($this->lostReportRepository->codeExists($code));
        return $code;
    }
}