<?php

class ItemRepository {
    private PDO $connection;

    public function __construct(PDO $connection) {
        $this->connection = $connection;
    }

    public function getAll(): array {
        $stmt = $this->connection->prepare('SELECT * FROM items');
        $stmt->execute();

        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getById(int $id): array|false {
        $stmt = $this->connection->prepare('SELECT * FROM items WHERE item_id = :id');
        $stmt->execute(['id' => $id]);
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    public function create(Item $item): bool {
        $stmt = $this->connection->prepare('INSERT INTO items (
            category_id, 
            title, 
            description, 
            location_found, 
            date_found, 
            time_found
            ) 
            VALUES (
            :categoryId, 
            :title, 
            :description, 
            :locationFound, 
            :dateFound, 
            :timeFound
            )');
        return $stmt->execute([
            'categoryId' => $item->getCategoryId(),
            'title' => $item->getTitle(),
            'description' => $item->getDescription(),
            'locationFound' => $item->getLocationFound(),
            'dateFound' => $item->getDateFound(),
            'timeFound' => $item->getTimeFound()
        ]);
    }
}
