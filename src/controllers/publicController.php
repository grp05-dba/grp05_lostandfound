<?php
//Yes is empty on purpose, as the public controller is not yet implemented.

class PublicController {
    private PDO $pdo;

    public function __construct(PDO $pdo)
    {
        $this->pdo = $pdo;
    }

    public function handleRequest(string $method, string $path): void{
        http_response_code(404);
        echo json_encode(['error' => 'Public endpoint not found']);
    }

}
