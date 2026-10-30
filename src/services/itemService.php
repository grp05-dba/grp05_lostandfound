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

    public function getItemById(int $id): array {
        $item = $this->itemRepository->getById($id);
        if ($item === false) {
            http_response_code(404);
            return ['message' => 'No item found.'];
        }
        return $item;
    }
}
