<?php

class ItemService { 
    private PDO $connection;
    private ItemRepository $itemRepository;
    private CategoryRepository $categoryRepository;
    private PotentialMatchService $potentialMatchService;

    private PotentialMatchService $potentialMatchService;
    private ImageService $imageService;

    public function __construct(PDO $connection) {
        $this->connection = $connection;
        $this->itemRepository = new ItemRepository($connection);
        $this->categoryRepository = new CategoryRepository($connection);
        $this->potentialMatchService = new PotentialMatchService($connection);
    }

    public function test(): array{
        return ['message' => 'its working! :D'];
    }

    public function getAllItems(): array {
        $items = $this->itemRepository->getAll();
        return $this->imageService->attachImageUrls('items', $items, 'item_id');
    }

    public function getAllUnclaimedItems(): array {
        $items = $this->itemRepository->getAllUnclaimedItems();
        return $this->imageService->attachImageUrls('items', $items, 'item_id');
    }

    public function getItemById(int $id): array {
        $success = $this->itemRepository->getById($id);
        $failure = RequestUtils::handleFindFailure($success);

        if ($failure) return $failure;

        return $this->imageService->attachImageUrls('items', [$success], 'item_id')[0];
    }

    public function createItem(array $data, array $uploads = []): array {
        $validationError = RequestUtils::validateRequiredFields($data, Item::class);
        if ($validationError) return $validationError;

        $validationError = RequestUtils::validateGeneralFields($data);
        if ($validationError) return $validationError;

        $validationError = RequestUtils::validateDateTimeFields($data);
        if ($validationError) return $validationError;

        try {
            $validatedUploads = $this->imageService->validateUploads($uploads);
        } catch (InvalidArgumentException $error) {
            http_response_code(400);
            return ['message' => $error->getMessage()];
        }

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
                return ['message' => 'Invalid status provided. Allowed values: unclaimed, claimed, archived.'];
            }
        }

        $success = $this->itemRepository->update($itemId, $data);
        $matchesRefreshed = 0;
        $matchesSaved = null;

        if ($success) {
            $updatedItem = $this->itemRepository->getById($itemId);
            
            if($updatedItem){
                if ($updatedItem['status'] !== 'unclaimed') {
                    $this->potentialMatchService->deleteByItemId($itemId);
                    $matchesRefreshed = 2;
                } elseif (
                    $item['status'] !== 'unclaimed' ||
                    $this->potentialMatchService->hasMatchingFieldsChanged($data, $item)
                ) {
                    $this->potentialMatchService->deleteByItemId($itemId);
                    $matchesSaved = $this->potentialMatchService->findPotentialReports($updatedItem);
                    $matchesRefreshed = 1;
                }
            }
        }
        return RequestUtils::handleUpdateFailure($success, $matchesRefreshed, $matchesSaved);
    }
}
