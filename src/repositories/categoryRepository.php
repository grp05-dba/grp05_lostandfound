<?php

class CategoryRepository {
    private PDO $connection;

    public function __construct(PDO $connection) {
        $this->connection = $connection;
    }

    public function getAll(): array {
    $stmt = $this->connection->prepare('SELECT * FROM categories');
    $stmt->execute();

    return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
}