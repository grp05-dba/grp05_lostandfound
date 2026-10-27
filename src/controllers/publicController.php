<?php

class PublicController {
    private PDO $pdo;

    public function __construct(PDO $pdo)
    {
        $this->pdo = $pdo;
    }

    public function handleRequest(): void{
        http_response_code(404);
        echo json_encode(['error' => 'Public endpoint not found']);
    }

}
