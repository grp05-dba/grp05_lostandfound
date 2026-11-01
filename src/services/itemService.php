<?php

class ItemService { 
    private ItemRepository $itemRepository;

    private CategoryRepository $categoryRepository;

    public function __construct(PDO $connection) {
        $this->itemRepository = new ItemRepository($connection);
        $this->categoryRepository = new CategoryRepository($connection);
    }

    public function test(): array{
        return ['message' => 'its working! :D'];
    }

    public function getAllItems(): array {
        return $this->itemRepository->getAll();
    }

    public function getItemById(int $id): array {
        $success = $this->itemRepository->getById($id);
        return RequestUtils::handleFindFailure($success) ?? $success;
    }

    public function createItem(array $data): array {
        $validationError = RequestUtils::validateRequestBody($data, Item::class);
        if ($validationError) {
            return $validationError;
        }

        // Check if the category exists
        $category = $this->categoryRepository->getById((int) $data['category_id']);
        if (!$category) {
            http_response_code(400);
            return ['message' => 'Invalid category_id provided.'];
        }

        $item = new Item(
            category_id: (int) $data['category_id'],
            title: $data['title'],
            description: $data['description'],
            location_found: $data['location_found'],
            date_found: $data['date_found'],
            time_found: $data['time_found']
        );

        $success = $this->itemRepository->create($item);

        return RequestUtils::handleCreateFailure($success);
    }
}
