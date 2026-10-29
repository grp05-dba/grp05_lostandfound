<?php

class ItemService { 
    private ItemRepository $itemRepository;

    public function __construct(PDO $connection) {
        $this->itemRepository = new ItemRepository($connection);
    }

    public function test(): array{
        return ['message' => 'its working! :D'];
    }

    public function getAllItems(): array {
        return $this->itemRepository->getAll();
    }

    public function getItemById(string $id): array {
        if (!ctype_digit($id) || (int) $id < 1 || (float) $id > 2147483647) {
            http_response_code(400);
            return ['error' => 'ID must be a positive integer.'];
        }
        $item = $this->itemRepository->getById((int) $id);
        if ($item === false) {
            http_response_code(404);
            return ['message' => 'No item found.'];
        }
        return $item;
    }
}
