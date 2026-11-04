<?php

class ItemService { 
    private PDO $connection;
    private ItemRepository $itemRepository;
    private CategoryRepository $categoryRepository;

    private PotentialMatchService $potentialMatchService;
    private ImageService $imageService;

    public function __construct(PDO $connection) {
        $this->connection = $connection;
        $this->itemRepository = new ItemRepository($connection);
        $this->categoryRepository = new CategoryRepository($connection);
        $this->potentialMatchService = new PotentialMatchService($connection);
        $this->imageService = new ImageService($connection);
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

        $savedStorageKeys = [];

        try {
            $this->connection->beginTransaction();
            $createdItem = $this->itemRepository->create($item);

            if (!$createdItem) {
                $this->connection->rollBack();
                return RequestUtils::handleCreateFailure(false);
            }

            $savedStorageKeys = $this->imageService->saveUploads('items', (int) $createdItem['item_id'], $validatedUploads);
            $this->connection->commit();
        } catch (Throwable $error) {
            if ($this->connection->inTransaction()) {
                $this->connection->rollBack();
            }

            $this->imageService->deleteStoredFiles($savedStorageKeys);
            error_log($error->getMessage());
            http_response_code(500);
            return ['message' => 'Failed to create item and save its images.'];
        }

        $matchesSaved = $this->potentialMatchService->findPotentialReports($createdItem);
        return RequestUtils::handleCreateFailure(true, $matchesSaved);
    }
    
    public function addItemImages(int $itemId, array $uploads): array {
        $item = $this->itemRepository->getById($itemId);
        if (!$item) {
            http_response_code(404);
            return ['message' => 'Item not found.'];
        }

        try {
            $validatedUploads = $this->imageService->validateUploads($uploads);
            $existingImages = $this->imageService->getImageUrls('items', $itemId);
            if (count($existingImages) + count($validatedUploads) > 5) {
                http_response_code(400);
                return ['message' => 'An item can have up to 5 images in total.'];
            }

            $this->connection->beginTransaction();
            $this->imageService->saveUploads('items', $itemId, $validatedUploads);
            $this->connection->commit();
            return ['message' => 'Item images uploaded successfully.', 'images' => $this->imageService->getImageUrls('items', $itemId)];
        } catch (InvalidArgumentException $error) {
            if ($this->connection->inTransaction()) $this->connection->rollBack();
            http_response_code(400);
            return ['message' => $error->getMessage()];
        } catch (Throwable $error) {
            if ($this->connection->inTransaction()) $this->connection->rollBack();
            error_log($error->getMessage());
            http_response_code(500);
            return ['message' => 'Failed to upload item images.'];
        }
    }

    public function deleteItemImage(int $itemId, int $imageId): array {
        if (!$this->itemRepository->getById($itemId)) {
            http_response_code(404);
            return ['message' => 'Item not found.'];
        }

        if (!$this->imageService->deleteImageForEntity('items', $itemId, $imageId)) {
            http_response_code(404);
            return ['message' => 'Image not found for this item.'];
        }

        return ['message' => 'Item image deleted successfully.'];
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
