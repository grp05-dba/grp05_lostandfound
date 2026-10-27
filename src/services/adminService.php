<?php

class AdminService { 
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
}