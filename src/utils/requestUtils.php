<?php

class RequestUtils {
    public static function getRequestBody(): array {
        $input = file_get_contents('php://input');
        $data = json_decode($input, true);
        return is_array($data) ? $data : [];
    }

    public static function getRequestData(): array {
        $contentType = $_SERVER['CONTENT_TYPE'] ?? '';

        if (str_starts_with(strtolower($contentType), 'multipart/form-data')) {
            return $_POST;
        }

        return self::getRequestBody();
    }

    public static function handleFindFailure(mixed $success): ?array {
        if (!$success) {
            http_response_code(404);
            return ['message' => 'Resource not found.'];
        }
        return null;
    }

    public static function handleCreateFailure(bool $success, ?int $matchesSaved = null): array {
        if (!$success) {
            http_response_code(500);
            return ['message' => 'Failed to create resource.'];
        }
        http_response_code(201);

        $response = ['message' => 'Resource created successfully.'];

        if ($matchesSaved !== null) {
            $response['potential_matches_status'] = self::formatPotentialMatchesStatus('Potential matches checked.', $matchesSaved);
        }

        return $response;
    }

    public static function handleUpdateFailure(bool $success, ?int $matchesRefreshed = null, ?int $matchesSaved = null): array {
        if (!$success) {
            http_response_code(500);
            return ['message' => 'Failed to update resource.'];
        }

        $response = ['message' => 'Resource updated successfully.'];

        if ($matchesRefreshed !== null) {
            if ($matchesRefreshed === 1) {
                $response['potential_matches_status'] = self::formatPotentialMatchesStatus('Potential matches refreshed.', $matchesSaved ?? 0);
            } elseif ($matchesRefreshed === 2) {
                $response['potential_matches_status'] = 'Potential matches deleted because this resource is no longer eligible.';
            } else {
                $response['potential_matches_status'] = 'Potential matches unchanged.';
            }
        }

        return $response;
    }

    private static function formatPotentialMatchesStatus(string $message, int $matchesSaved): string {
        if ($matchesSaved === 0) {
            return "$message (No matches found.)";
        }

        $matchLabel = 'matches';
        if ($matchesSaved === 1) {
            $matchLabel = 'match';
        }

        return "$message ($matchesSaved $matchLabel saved.)";
    }

    public static function validatePatchFields(array $data, string $entityClass): ?array {
        $reflection = new ReflectionClass($entityClass);
        
        foreach (array_keys($data) as $field) {
            if (!$reflection->hasProperty($field)) {
                http_response_code(400);
                return ['message' => "Unexpected field: $field"];
            }
        }

        return null;
    }

    public static function validateRequiredFields(array $data, string $entityClass, array $excludedFields = []): ?array {
        $reflection = new ReflectionClass($entityClass);

        $fields = [];
        foreach ($reflection->getProperties() as $property) {
            $fields[] = $property->getName();
        }

        $additionalFields = array_diff(array_keys($data), $fields);

        if ($additionalFields) {
            http_response_code(400);
            return ['message' => 'Unexpected fields: ' . implode(', ', $additionalFields)];
        }

        $fields = array_diff($fields, ['status'], $excludedFields);

        $missingFields = array_diff($fields, array_keys($data));
        
        if ($missingFields) {
            http_response_code(400);
            return ['message' => 'Missing required fields: ' . implode(', ', $missingFields)];
        }
        
        return null;
    }

    public static function validateGeneralFields(array $data): ?array {
        $fieldLimits = [
            'full_name' => 150,
            'student_number' => 50,
            'email' => 150,
            'phone_number' => 50,
            'title' => 255,
            'location_found' => 255,
            'location_lost' => 255,
            'name' => 100, // For category name, probably not even needed since categories are predefined, but just in case.
        ];

        $optionalFields = [
            'email',
            'phone_number', 
            'location_lost', 
            'date_lost', 
            'time_lost', 
            //'location_found', why are these commented out? they're optional according to database schema, but should be required. will fix soon.
            //'date_found', 
            //'time_found'
        ];

        foreach ($data as $field => $value) {
            if (!array_key_exists($field, $fieldLimits)) {
                continue;
            }

            if (in_array($field, $optionalFields, true) && empty($value)) {
                continue;
            }

            if (!is_string($value) || trim($value) === '') {
                http_response_code(400);
                return ['message' => "Invalid or empty field: $field"];
            }

            if (mb_strlen($value) > $fieldLimits[$field]) {
                http_response_code(400);
                return ['message' => "Field too long: $field (max: {$fieldLimits[$field]} characters)"];
            }

            if ($field === 'email' && !filter_var($value, FILTER_VALIDATE_EMAIL)) {
                http_response_code(400);
                return ['message' => 'Invalid email provided.'];
            }

            if ($field === 'phone_number' && !preg_match('/^[0-9+\-]+$/', $value)) {
                http_response_code(400);
                return ['message' => 'Invalid phone number provided.'];
            }
        }

        return null;
    }

    public static function normalizeContactFields(array $data): array {
        foreach (['email', 'phone_number'] as $field) {
            if (array_key_exists($field, $data)) {
                $data[$field] = is_string($data[$field]) && trim($data[$field]) !== ''
                    ? trim($data[$field])
                    : null;
            }
        }

        return $data;
    }

    public static function validateContactPreference(array $data, ?array $existingData = null): ?array {
        $contactData = self::normalizeContactFields(array_merge($existingData ?? [], $data));
        $preference = $contactData['contact_preference'] ?? 'email';

        if (!is_string($preference) || !in_array($preference, ['email', 'sms'], true)) {
            http_response_code(400);
            return ['message' => 'Invalid contact_preference. Allowed values: email, sms.'];
        }

        if (empty($contactData['email']) && empty($contactData['phone_number'])) {
            http_response_code(400);
            return ['message' => 'Provide an email address or phone number.'];
        }

        if ($preference === 'email' && empty($contactData['email'])) {
            http_response_code(400);
            return ['message' => 'An email address is required for email contact preference.'];
        }

        if ($preference === 'sms' && empty($contactData['phone_number'])) {
            http_response_code(400);
            return ['message' => 'A phone number is required for SMS contact preference.'];
        }

        return null;
    }

    public static function validateDateTimeFields(array $data): ?array {
        $fieldFormats = [
            'date_found' => 'Y-m-d',
            'time_found' => 'H:i:s',
            'date_lost' => 'Y-m-d',
            'time_lost' => 'H:i:s'
        ];

        foreach ($fieldFormats as $field => $format) {
            $value = $data[$field] ?? null;

            if (empty($value)) {
                continue;
            }

            if (!is_string($value)) {
                http_response_code(400);
                return ['message' => "Invalid field: $field"];
            }

            if (($field === 'time_found' || $field === 'time_lost') && strlen($value) === 5) {
                $format = 'H:i';
            }

            $dateTime = DateTimeImmutable::createFromFormat('!' . $format, $value);

            if (
                !$dateTime ||
                $dateTime->format($format) !== $value ||
                (($field === 'date_found' || $field === 'date_lost') && (int) $dateTime->format('Y') < 1)
            ) {
                http_response_code(400);
                return ['message' => "Invalid field: $field"];
            }
        }

        return null;
    }
}
