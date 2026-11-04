<?php

class PotentialMatchRepository {
    private PDO $connection;

    public function __construct(PDO $connection) {
        $this->connection = $connection;
    }

    public function getAll(): array {
        $stmt = $this->connection->query('SELECT * FROM potential_matches');
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getById(int $id): array|false {
        $stmt = $this->connection->prepare('SELECT * FROM potential_matches WHERE match_id = :id');
        $stmt->execute(['id' => $id]);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    public function create(int $reportId, int $itemId, float $similarityScore): bool {
        $stmt = $this->connection->prepare(
            'INSERT INTO potential_matches (report_id, item_id, similarity_score)
            VALUES (:reportId, :itemId, :similarityScore)
            ');

        return $stmt->execute([
            'reportId' => $reportId,
            'itemId' => $itemId,
            'similarityScore' => $similarityScore
        ]);
    }

    public function deleteByReportId(int $reportId): bool {
        $stmt = $this->connection->prepare('DELETE FROM potential_matches WHERE report_id = :reportId');
        return $stmt->execute(['reportId' => $reportId]);
    }

    public function deleteByItemId(int $itemId): bool {
        $stmt = $this->connection->prepare('DELETE FROM potential_matches WHERE item_id = :itemId');
        return $stmt->execute(['itemId' => $itemId]);
    }
}