<?php

class PhotoService {
    private PhotoRepository $photoRepository;
    private const MAX_PHOTOS = 5;
    private const MAX_FILE_SIZE = 5242880;
    private const ALLOWED_TYPES = ['image/jpeg', 'image/png', 'image/webp'];

    public function __construct(PDO $connection) {
        $this->photoRepository = new PhotoRepository($connection);
    }

    public function addUploadedPhotos(string $type, int $ownerId, array $files): array {
        if ($ownerId < 1) {
            http_response_code(400);
            return ['message' => 'Invalid record ID.'];
        }

        $normalized = $this->normalizeFiles($files);
        if (!$normalized) {
            http_response_code(400);
            return ['message' => 'Select at least one photo to upload.'];
        }

        $existing = $this->photoRepository->countForOwner($type, $ownerId);
        if ($existing + count($normalized) > self::MAX_PHOTOS) {
            http_response_code(400);
            return ['message' => 'A record can have a maximum of 5 photos.'];
        }

        $saved = 0;
        foreach ($normalized as $file) {
            if ($file['error'] !== UPLOAD_ERR_OK) {
                http_response_code(400);
                return ['message' => 'One or more photos could not be uploaded.'];
            }
            if ($file['size'] < 1 || $file['size'] > self::MAX_FILE_SIZE) {
                http_response_code(400);
                return ['message' => 'Each photo must be between 1 byte and 5 MB.'];
            }

            $mime = (new finfo(FILEINFO_MIME_TYPE))->file($file['tmp_name']);
            if (!in_array($mime, self::ALLOWED_TYPES, true)) {
                http_response_code(400);
                return ['message' => 'Only JPEG, PNG, and WebP photos are supported.'];
            }

            $contents = file_get_contents($file['tmp_name']);
            if ($contents === false || !$this->photoRepository->add($type, $ownerId, basename($file['name']), $mime, $contents)) {
                http_response_code(500);
                return ['message' => 'Failed to save photo.'];
            }
            $saved++;
        }

        http_response_code(201);
        return ['message' => 'Photos saved successfully.', 'saved' => $saved];
    }

    public function getPhoto(string $type, int $ownerId, int $photoId): array|false {
        return $this->photoRepository->getData($type, $ownerId, $photoId);
    }

    public function getPhotos(string $type, int $ownerId): array {
        return $this->photoRepository->getForOwner($type, $ownerId);
    }

    private function normalizeFiles(array $files): array {
        if (!isset($files['name'])) return [];
        if (!is_array($files['name'])) {
            return [[
                'name' => $files['name'],
                'type' => $files['type'] ?? '',
                'tmp_name' => $files['tmp_name'] ?? '',
                'error' => $files['error'] ?? UPLOAD_ERR_NO_FILE,
                'size' => $files['size'] ?? 0,
            ]];
        }

        $normalized = [];
        foreach ($files['name'] as $index => $name) {
            $normalized[] = [
                'name' => $name,
                'type' => $files['type'][$index] ?? '',
                'tmp_name' => $files['tmp_name'][$index] ?? '',
                'error' => $files['error'][$index] ?? UPLOAD_ERR_NO_FILE,
                'size' => $files['size'][$index] ?? 0,
            ];
        }
        return $normalized;
    }
}
