<?php

class LostReportRepository {
    private PDO $connection;

    public function __construct(PDO $connection) {
        $this->connection = $connection;
    }

    public function getAll(): array {
        $stmt = $this->connection->prepare('SELECT * FROM lost_reports');
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getById(int $id): array|false {
        $stmt = $this->connection->prepare('SELECT * FROM lost_reports WHERE report_id = :id');
        $stmt->execute(['id' => $id]);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    public function getByCode(string $code): array|false {
        $stmt = $this->connection->prepare('SELECT * FROM lost_reports WHERE report_code = :code');
        $stmt->execute(['code' => $code]);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    public function codeExists(string $code): bool {
        $stmt = $this->connection->prepare('SELECT 1 FROM lost_reports WHERE report_code = :code');
        $stmt->execute(['code' => $code]);
        return $stmt->fetchColumn() !== false;
    }

    public function update(int $reportId, array $data): bool {
        $updates = [];

        foreach ($data as $field => $value) {
            $updates[] = "$field = :$field";
        }

        if(empty($updates)) return false;

        $sql = 'UPDATE lost_reports SET ' . implode(', ', $updates) . ' WHERE report_id = :reportId';
        $stmt = $this->connection->prepare($sql);

        return $stmt->execute([...$data, 'reportId' => $reportId]);
    }

    public function create(LostReport $report): bool {
        $stmt = $this->connection->prepare('INSERT INTO lost_reports (
            report_code, category_id, title, description, location_lost, date_lost,
            time_lost, full_name, student_number, email, phone_number, contact_preference
        ) VALUES (
            :reportCode, :categoryId, :title, :description, :locationLost, :dateLost,
            :timeLost, :fullName, :studentNumber, :email, :phoneNumber, :contactPreference
        )');
        return $stmt->execute([
            'reportCode' => $report->getReportCode(),
            'categoryId' => $report->getCategoryId(),
            'title' => $report->getTitle(),
            'description' => $report->getDescription(),
            'locationLost' => $report->getLocationLost(),
            'dateLost' => $report->getDateLost(),
            'timeLost' => $report->getTimeLost(),
            'fullName' => $report->getFullName(),
            'studentNumber' => $report->getStudentNumber(),
            'email' => $report->getEmail(),
            'phoneNumber' => $report->getPhoneNumber(),
            'contactPreference' => $report->getContactPreference()
        ]);

        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    public function getEligibleReports(string $dateFound): array {
        $stmt = $this->connection->prepare('SELECT * FROM lost_reports WHERE status = :status AND (date_lost IS NULL OR date_lost <= :dateFound)');
        $stmt->execute(['status' => 'active', 'dateFound' => $dateFound]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getAllActiveReports(): array {
        $stmt = $this->connection->prepare('SELECT * FROM lost_reports WHERE status = :status');
        $stmt->execute(['status' => 'active']);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
}
