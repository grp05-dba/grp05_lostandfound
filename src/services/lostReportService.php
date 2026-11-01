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
        $validationError = RequestUtils::validateRequestBody(
            $data, LostReport::class,
            ['phone_number', 'location_lost', 'date_lost', 'time_lost'],
            ['report_code']
        );
        if ($validationError) {
            return $validationError;
        }

        foreach (['title' => 255, 'location_lost' => 255, 'full_name' => 150, 'student_number' => 50, 'email' => 150, 'phone_number' => 50] as $field => $limit) {
            if (isset($data[$field]) && preg_match_all('/./us', $data[$field]) > $limit) {
                http_response_code(400);
                return ['message' => 'Field too long: ' . $field];
            }
        }
        if (!filter_var($data['email'], FILTER_VALIDATE_EMAIL)) {
            http_response_code(400);
            return ['message' => 'Invalid email provided.'];
        }
        foreach (['date_lost' => 'Y-m-d', 'time_lost' => 'H:i:s'] as $field => $format) {
            $value = $data[$field] ?? '';
            if ($value === '') {
                continue;
            }
            if ($field === 'time_lost' && strlen($value) === 5) {
                $format = 'H:i';
            }
            $date = DateTimeImmutable::createFromFormat('!' . $format, $value);
            if (!$date || $date->format($format) !== $value || ($field === 'date_lost' && (int) $date->format('Y') < 1)) {
                http_response_code(400);
                return ['message' => 'Invalid field: ' . $field];
            }
        }

        if (!$this->categoryRepository->getById($data['category_id'])) {
            http_response_code(400);
            return ['message' => 'Invalid category_id provided.'];
        }

        $report = new LostReport(
            report_code: $this->lostReportRepository->generateReportCode(),
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
}
