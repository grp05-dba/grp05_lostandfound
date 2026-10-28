<?php

class CategoryService { 
    private CategoryRepository $categoryRepository;

    public function __construct(PDO $connection) {
        $this->categoryRepository = new CategoryRepository($connection);
    }

    public function getAllCategories(): array {
        return $this->categoryRepository->getAll();
    }
}