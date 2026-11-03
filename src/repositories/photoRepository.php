<?php

class PhotoRepository {
    private PDO $connection;
    private const TABLES = [
        'item' => ['table' => 'item_photos', 'owner' => 'item_id'],
        'lost_report' => ['table' => 'lost_report_photos', 'owner' => 'report_id'],
        'claim' => ['table' => 'claim_photos', 'owner' => 'claim_id'],
    ];

    public function __construct(PDO $connection) {
        $this->connection = $connection;
    }

    private function target(string $type): array {
        if (!isset(self::TABLES[$type])) throw new InvalidArgumentException('Unsupported photo owner type.');
        return self::TABLES[$type];
    }

    public function countForOwner(string $type, int $ownerId): int {
        $target = $this->target($type);
        $stmt = $this->connection->prepare('SELECT COUNT(*) FROM ' . $target['table'] . ' WHERE ' . $target['owner'] . ' = :ownerId');
        $stmt->execute(['ownerId' => $ownerId]);
        return (int) $stmt->fetchColumn();
    }

    public function add(string $type, int $ownerId, string $fileName, string $mimeType, string $contents): bool {
        $target = $this->target($type);
        $sql = 'INSERT INTO ' . $target['table'] . ' (' . $target['owner'] . ', file_name, mime_type, photo_data)
                VALUES (:ownerId, :fileName, :mimeType, :photoData)';
        $stmt = $this->connection->prepare($sql);
        $stmt->bindValue(':ownerId', $ownerId, PDO::PARAM_INT);
        $stmt->bindValue(':fileName', $fileName, PDO::PARAM_STR);
        $stmt->bindValue(':mimeType', $mimeType, PDO::PARAM_STR);
        $stmt->bindValue(':photoData', $contents, PDO::PARAM_LOB);
        return $stmt->execute();
    }

    public function getForOwner(string $type, int $ownerId): array {
        $target = $this->target($type);
        $stmt = $this->connection->prepare(
            'SELECT photo_id, ' . $target['owner'] . ', file_name, mime_type, uploaded_at
             FROM ' . $target['table'] . ' WHERE ' . $target['owner'] . ' = :ownerId ORDER BY photo_id'
        );
        $stmt->execute(['ownerId' => $ownerId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getData(string $type, int $photoId): array|false {
        $target = $this->target($type);
        $stmt = $this->connection->prepare(
            'SELECT file_name, mime_type, photo_data FROM ' . $target['table'] . ' WHERE photo_id = :photoId'
        );
        $stmt->execute(['photoId' => $photoId]);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }
}
