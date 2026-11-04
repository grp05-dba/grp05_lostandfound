<?php

class PotentialMatchRepository {
    private PDO $connection;

    public function __construct(PDO $connection) {
        $this->connection = $connection;
    }

    public function createIfNotExists(int $reportId, int $itemId): bool {
        $stmt = $this->connection->prepare(
            'INSERT INTO potential_matches (report_id, item_id)
             VALUES (:reportId, :itemId)
             ON CONFLICT (report_id, item_id) DO NOTHING'
        );
        $stmt->execute(['reportId' => $reportId, 'itemId' => $itemId]);
        return $stmt->rowCount() === 1;
    }

    public function getAll(): array {
        $stmt = $this->connection->query(
            'SELECT pm.match_id, pm.report_id, pm.item_id,
                    lr.report_code, lr.title AS lost_title,
                    i.title AS found_title
             FROM potential_matches pm
             JOIN lost_reports lr ON lr.report_id = pm.report_id
             JOIN items i ON i.item_id = pm.item_id
             ORDER BY pm.match_id DESC'
        );
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getByReportId(int $reportId): array {
        $stmt = $this->connection->prepare(
            'SELECT pm.match_id, pm.report_id, pm.item_id,
                    lr.report_code, lr.title AS lost_title,
                    i.title AS found_title
             FROM potential_matches pm
             JOIN lost_reports lr ON lr.report_id = pm.report_id
             JOIN items i ON i.item_id = pm.item_id
             WHERE pm.report_id = :reportId
             ORDER BY pm.match_id DESC'
        );
        $stmt->execute(['reportId' => $reportId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getByItemId(int $itemId): array {
        $stmt = $this->connection->prepare(
            'SELECT pm.match_id, pm.report_id, pm.item_id,
                    lr.report_code, lr.title AS lost_title,
                    i.title AS found_title
             FROM potential_matches pm
             JOIN lost_reports lr ON lr.report_id = pm.report_id
             JOIN items i ON i.item_id = pm.item_id
             WHERE pm.item_id = :itemId
             ORDER BY pm.match_id DESC'
        );
        $stmt->execute(['itemId' => $itemId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function delete(int $matchId): bool {
        $stmt = $this->connection->prepare(
            'DELETE FROM potential_matches WHERE match_id = :matchId'
        );
        $stmt->execute(['matchId' => $matchId]);
        return $stmt->rowCount() === 1;
    }
}
