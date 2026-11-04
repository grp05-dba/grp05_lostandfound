<?php

class ImageRepository {
    private PDO $connection;

    private array $imageTables = [
        'items' => [
            'table' => 'item_images',
            'id' => 'item_image_id',
            'foreign_key' => 'item_id'
        ],
        'lost-reports' => [
            'table' => 'lost_report_images',
            'id' => 'report_image_id',
            'foreign_key' => 'report_id'
        ],
        'claims' => [
            'table' => 'claim_images',
            'id' => 'claim_image_id',
            'foreign_key' => 'claim_id'
        ]
    ];

    public function __construct(PDO $connection) {
        $this->connection = $connection;
    }

    public function create(string $entityType, int $entityId, string $storageKey, string $mimeType): bool {
        $imageTable = $this->imageTables[$entityType];
        $stmt = $this->connection->prepare(
            "INSERT INTO {$imageTable['table']} ({$imageTable['foreign_key']}, storage_key, mime_type)
            VALUES (:entityId, :storageKey, :mimeType)"
        );

        return $stmt->execute([
            'entityId' => $entityId,
            'storageKey' => $storageKey,
            'mimeType' => $mimeType
        ]);
    }

    public function getForEntity(string $entityType, int $entityId): array {
        $imageTable = $this->imageTables[$entityType];
        $stmt = $this->connection->prepare(
            "SELECT {$imageTable['id']} AS image_id, storage_key, mime_type, created_at
            FROM {$imageTable['table']}
            WHERE {$imageTable['foreign_key']} = :entityId
            ORDER BY created_at, {$imageTable['id']}"
        );
        $stmt->execute(['entityId' => $entityId]);

        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function deleteForEntity(string $entityType, int $entityId, int $imageId): array|false {
        $imageTable = $this->imageTables[$entityType];
        $stmt = $this->connection->prepare(
            "DELETE FROM {$imageTable['table']}
            WHERE {$imageTable['id']} = :imageId AND {$imageTable['foreign_key']} = :entityId
            RETURNING storage_key"
        );
        $stmt->execute(['imageId' => $imageId, 'entityId' => $entityId]);

        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    public function getById(string $entityType, int $imageId): array|false {
        $imageTable = $this->imageTables[$entityType];
        $stmt = $this->connection->prepare(
            "SELECT {$imageTable['id']} AS image_id, storage_key, mime_type
            FROM {$imageTable['table']}
            WHERE {$imageTable['id']} = :imageId"
        );
        $stmt->execute(['imageId' => $imageId]);

        return $stmt->fetch(PDO::FETCH_ASSOC);
    }
}
