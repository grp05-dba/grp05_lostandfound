<?php

class RequestUtils {
    public static function getRequestBody(): array {
        $input = file_get_contents('php://input');
        return json_decode($input, true) ?? [];
    }

    public static function handleFindFailure(mixed $success): ?array {
        if (!$success) {
            http_response_code(404);
            return ['message' => 'Resource not found.'];
        }
        return null;
    }

    public static function handleCreateFailure(bool $success): array {
        if (!$success) {
            http_response_code(500);
            return ['message' => 'Failed to create resource.'];
        }
        http_response_code(201);
        return ['message' => 'Resource created successfully.'];
    }

    public static function validateRequestBody(array $data, string $entityClass, array $excludedFields = []): ?array {
        $reflection = new ReflectionClass($entityClass);

        $fields = [];
        foreach ($reflection->getProperties() as $property) {
            $fields[] = $property->getName();
        }

        $fields = array_diff($fields, ['status'], $excludedFields);

        $missingFields = array_diff($fields, array_keys($data));
        
        if ($missingFields) {
            http_response_code(400);
            return ['message' => 'Missing required fields: ' . implode(', ', $missingFields)];
        }

        return null;
    }
}
