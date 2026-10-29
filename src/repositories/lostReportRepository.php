<?php

class LostReportRepository {
    private PDO $connection;

    public function __construct(PDO $connection) {
        $this->connection = $connection;
    }

    public function getAll(): array {
        $stmt = $this->connection->prepare('SELECT * FROM lost_reports ORDER BY report_id');
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getById(int $id): array|false {
        $stmt = $this->connection->prepare('SELECT * FROM lost_reports WHERE report_id = :id');
        $stmt->execute(['id' => $id]);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }
}
