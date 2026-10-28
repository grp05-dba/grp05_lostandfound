<?php

class PublicController {
    private CategoryService $categoryService;
    private PDO $connection;

    public function __construct(PDO $connection) {
        $this->connection = $connection;
        $this->categoryService = new CategoryService($connection);
    }

    public function handleRequest(string $method, string $path): void{

        if ($method === 'GET' && $path === '/api/public/categories') {
            echo json_encode($this->categoryService->getAllCategories());
            return;
        }

        if ($method === 'GET' && str_starts_with($path, '/api/public/categories/')) {
            $id = (int) str_replace('/api/public/categories/', '', $path);

            echo json_encode($this->categoryService->getCategoryById($id));
            return;
        }

        http_response_code(404);
        echo json_encode(['error' => 'Public endpoint not found']);
    }
}