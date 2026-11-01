<?php

class RequestUtils {
    public static function getRequestBody(): array {
        $input = file_get_contents('php://input');
        $data = json_decode($input, true);
        return is_array($data) ? $data : [];
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

    public static function validateRequestBody(array $data, string $entityClass, array $optionalFields = [], array $generatedFields = []): ?array {
        $reflection = new ReflectionClass($entityClass);

        $fields = [];
        foreach ($reflection->getProperties() as $property) {
            $fields[] = $property->getName();
        }

        $fields = array_diff($fields, ['status'], $optionalFields, $generatedFields);

        $missingFields = array_diff($fields, array_keys($data));
        
        if ($missingFields) {
            http_response_code(400);
            return ['message' => 'Missing required fields: ' . implode(', ', $missingFields)];
        }

        foreach ($reflection->getProperties() as $property) {
            $name = $property->getName();
            if ($name === 'status' || in_array($name, $generatedFields, true) || !array_key_exists($name, $data)) {
                continue;
            }
            $value = $data[$name];
            if (in_array($name, $optionalFields, true) && ($value === null || $value === '')) {
                continue;
            }
            $type = $property->getType()->getName();
            if (($type === 'string' && (!is_string($value) || trim($value) === '' || str_contains($value, "\0"))) ||
                ($type === 'int' && (!is_int($value) || $value < 1 || $value > 2147483647))) {
                http_response_code(400);
                return ['message' => 'Invalid field: ' . $name];
            }
        }
        return null;
    }
}
