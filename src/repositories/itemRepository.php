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

    public function create(Item $item): array|false {
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
            ) RETURNING *');

        $stmt->execute([
            'categoryId' => $item->getCategoryId(),
            'title' => $item->getTitle(),
            'description' => $item->getDescription(),
            'locationFound' => $item->getLocationFound(),
            'dateFound' => $item->getDateFound(),
            'timeFound' => $item->getTimeFound()
        ]);

        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    public function update(int $itemId, array $data): bool {
        $updates = [];

        foreach ($data as $field => $value) {
            $updates[] = "$field = :$field";
        }

        if(empty($updates)) return false; 

        $stmt = $this->connection->prepare('UPDATE items SET ' . implode(', ', $updates) . ' WHERE item_id = :itemId');

        return $stmt->execute([...$data, 'itemId' => $itemId]);
    }

    public function getEligibleItems(string $dateLost): array {
        $stmt = $this->connection->prepare('SELECT * FROM items WHERE status = :status AND (date_found IS NULL OR date_found >= :dateLost)');
        $stmt->execute(['status' => 'unclaimed', 'dateLost' => $dateLost]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function getAllUnclaimedItems(): array {
        $stmt = $this->connection->prepare('SELECT * FROM items WHERE status = :status');
        $stmt->execute(['status' => 'unclaimed']);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function searchUnclaimed(array $filters): array {
        $sql = 'SELECT items.*, categories.name AS category_name
            FROM items
            LEFT JOIN categories ON items.category_id = categories.category_id
            WHERE items.status = :status';
        $parameters = ['status' => 'unclaimed'];

        if (!empty($filters['title'])) {
            $sql .= ' AND items.title ILIKE :title';
            $parameters['title'] = '%' . $filters['title'] . '%';
        }

        if (!empty($filters['category_id'])) {
            $sql .= ' AND items.category_id = :categoryId';
            $parameters['categoryId'] = $filters['category_id'];
        }

        if (!empty($filters['location_found'])) {
            $sql .= ' AND items.location_found ILIKE :locationFound';
            $parameters['locationFound'] = '%' . $filters['location_found'] . '%';
        }

        if (!empty($filters['date_found'])) {
            $sql .= ' AND items.date_found = :dateFound';
            $parameters['dateFound'] = $filters['date_found'];
        }

        if (!empty($filters['time_found'])) {
            $sql .= ' AND items.time_found = :timeFound';
            $parameters['timeFound'] = $filters['time_found'];
        }

        $sql .= ' ORDER BY items.date_found DESC NULLS LAST, items.time_found DESC NULLS LAST';

        $stmt = $this->connection->prepare($sql);
        $stmt->execute($parameters);

        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
}