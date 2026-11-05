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

    public function getByReportCode(string $reportCode): array {
        $stmt = $this->connection->prepare(
            "SELECT potential_matches.match_id, potential_matches.similarity_score, potential_matches.created_at,
                items.item_id, items.title, items.description, items.location_found, items.date_found, items.time_found
            FROM potential_matches
            INNER JOIN lost_reports ON potential_matches.report_id = lost_reports.report_id
            INNER JOIN items ON potential_matches.item_id = items.item_id
            WHERE lost_reports.report_code = :reportCode
                AND lost_reports.status = 'active'
                AND items.status = 'unclaimed'
            ORDER BY potential_matches.similarity_score DESC, potential_matches.created_at DESC"
        );
        $stmt->execute(['reportCode' => $reportCode]);

        return $stmt->fetchAll(PDO::FETCH_ASSOC);
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

    public function deleteByIdAndReportCode(int $matchId, string $reportCode): bool {
        $stmt = $this->connection->prepare(
            'DELETE FROM potential_matches AS pm
             USING lost_reports AS lr
             WHERE pm.report_id = lr.report_id
                AND lr.report_code = :reportCode
                AND pm.match_id = :matchId'
        );

        $stmt->execute([
            'reportCode' => $reportCode,
            'matchId' => $matchId
        ]);

        return $stmt->rowCount() > 0;
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