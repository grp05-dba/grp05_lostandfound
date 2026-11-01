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

    public function generateReportCode(): string {
        $stmt = $this->connection->prepare('SELECT 1 FROM lost_reports WHERE report_code = :code');
        do {
            $code = 'LR-' . strtoupper(bin2hex(random_bytes(16)));
            $stmt->execute(['code' => $code]);
            $exists = $stmt->fetchColumn();
            $stmt->closeCursor();
        } while ($exists !== false);
        return $code;
    }

    public function create(LostReport $report): bool {
        $stmt = $this->connection->prepare('INSERT INTO lost_reports (
            report_code, category_id, title, description, location_lost, date_lost,
            time_lost, full_name, student_number, email, phone_number
        ) VALUES (
            :reportCode, :categoryId, :title, :description, :locationLost, :dateLost,
            :timeLost, :fullName, :studentNumber, :email, :phoneNumber
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
            'phoneNumber' => $report->getPhoneNumber()
        ]);
    }
}
