<?php

class CategoryService { 
    private CategoryRepository $categoryRepository;

    public function __construct(PDO $connection) {
        $this->categoryRepository = new CategoryRepository($connection);
    }

    public function getAllCategories(): array {
        return $this->categoryRepository->getAll();
    }

    public function getCategoryById(int $id): array {
        $response = $this->categoryRepository->getById($id);
        if ($response === false) {
            http_response_code(404);
            return ['error' => 'Category not found'];
        }
        return $response;
    }
}