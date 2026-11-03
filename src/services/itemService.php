<?php

class ItemService { 
    private ItemRepository $itemRepository;

    private CategoryRepository $categoryRepository;
    private PotentialMatchService $potentialMatchService;

    public function __construct(PDO $connection) {
        $this->itemRepository = new ItemRepository($connection);
        $this->categoryRepository = new CategoryRepository($connection);
        $this->potentialMatchService = new PotentialMatchService($connection);
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
        $validationError = RequestUtils::validateRequiredFields($data, Item::class);
        if ($validationError) return $validationError;

        $validationError = RequestUtils::validateGeneralFields($data);
        if ($validationError) return $validationError;

        $validationError = RequestUtils::validateDateTimeFields($data);
        if ($validationError) return $validationError;

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
        if (!$success) return RequestUtils::handleCreateFailure(false);

        try {
            $this->potentialMatchService->generatePotentialMatches();
        } catch (Throwable $e) {
            error_log('Potential matching after item creation failed: ' . $e->getMessage());
        }

        return RequestUtils::handleCreateFailure(true);
    }
//hehe
    public function updateItem(int $itemId, array $data): array {
        $item = $this->itemRepository->getById($itemId);
        if (!$item) {
            http_response_code(404);
            return ['message' => 'Item not found.'];
        }

        $validationError = RequestUtils::validatePatchFields($data, Item::class);
        if ($validationError) return $validationError;

        $validationError = RequestUtils::validateGeneralFields($data);
        if ($validationError) return $validationError;

        $validationError = RequestUtils::validateDateTimeFields($data);
        if ($validationError) return $validationError;

        if (isset($data['category_id'])) {
            $category = $this->categoryRepository->getById((int) $data['category_id']);

            if (!$category) {
                http_response_code(400);
                return ['message' => 'Invalid category_id provided.'];
            }
        }

        if (array_key_exists('status', $data)) {
            $allowedStatuses = ['unclaimed', 'claimed', 'archived'];
            if (!is_string($data['status']) || !in_array($data['status'], $allowedStatuses, true)) {
                http_response_code(400);
                return ['message' => 'Invalid status provided. Allowed values: pending, approved, rejected.'];
            }
        }

        $success = $this->itemRepository->update($itemId, $data);

        return RequestUtils::handleUpdateFailure($success);
    }
}
