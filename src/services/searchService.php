<?php

class SearchService {
    private ItemRepository $itemRepository;

    public function __construct(PDO $connection) {
        $this->itemRepository = new ItemRepository($connection);
    }

    public function searchItems(array $filters): array {
        $allowedFields = ['title', 'category_id', 'location_found', 'date_found', 'time_found'];

        foreach (array_keys($filters) as $field) {
            if (!in_array($field, $allowedFields, true)) {
                http_response_code(400);
                return ['message' => "Unexpected search field: $field"];
            }
        }

        foreach (['title', 'location_found'] as $field) {
            if (isset($filters[$field])) {
                if (!is_string($filters[$field])) {
                    http_response_code(400);
                    return ['message' => "Invalid search field: $field"];
                }

                $filters[$field] = trim($filters[$field]);

                if (mb_strlen($filters[$field]) > 255) {
                    http_response_code(400);
                    return ['message' => "Search field too long: $field (max: 255 characters)"];
                }
            }
        }

        if (isset($filters['category_id'])) {
            if (
                !is_scalar($filters['category_id']) ||
                !ctype_digit((string) $filters['category_id']) ||
                (int) $filters['category_id'] < 1
            ) {
                http_response_code(400);
                return ['message' => 'Invalid category_id provided.'];
            }

            $filters['category_id'] = (int) $filters['category_id'];
        }

        $validationError = RequestUtils::validateDateTimeFields($filters);
        if ($validationError) return $validationError;

        return $this->itemRepository->searchUnclaimed($filters);
    }
}