<?php

class AdminController {
    private ItemService $itemService;
    private PDO $connection;

    public function __construct(PDO $connection) {
        $this->connection = $connection;
        $this->itemService = new ItemService($connection);
    }

    public function handleRequest(string $method, string $path): void {

        //Test endpoint to check if the API is working
        if ($method === 'GET' && $path === '/api/admin/test') {
            echo json_encode($this->itemService->test());
            return;
        }

        //Endpoint to get all items from the database
        if ($method === 'GET' && $path === '/api/admin/items') {
            echo json_encode($this->itemService->getAllItems());
            return;
        }

        http_response_code(404);
        echo json_encode(['error' => 'Admin endpoint not found']);
    }
}