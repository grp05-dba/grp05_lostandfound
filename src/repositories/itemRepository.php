<?php

class ItemRepository {
    private PDO $pdo;

    public function __construct(PDO $pdo) {
        $this->pdo = $pdo;
    }

    public function getAll(): array {
    $stmt = $this->pdo->prepare('SELECT * FROM items');
    $stmt->execute();

    return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }
}