<?php

class ImageService {
    private ImageRepository $imageRepository;

    private array $imageTypes = [
        'items' => [
            'directory' => 'items',
            'public_path' => '/api/public/items/images/'
        ],
        'lost-reports' => [
            'directory' => 'lost-reports',
            'public_path' => '/api/public/lost-reports/images/'
        ],
        'claims' => [
            'directory' => 'claims',
            'public_path' => '/api/admin/claims/images/'
        ]
    ];

    private array $allowedMimeTypes = [
        'image/jpeg' => 'jpg',
        'image/png' => 'png',
        'image/webp' => 'webp'
    ];

    private int $maximumFiles = 5;
    private int $maximumFileSize = 5242880;

    public function __construct(PDO $connection) {
        $this->imageRepository = new ImageRepository($connection);
    }

    public function validateUploads(array $uploads): array {
        if (!isset($uploads['name'])) {
            return [];
        }

        $uploadFiles = [];
        if (is_array($uploads['name'])) {
            foreach (array_keys($uploads['name']) as $index) {
                $uploadFiles[] = [
                    'name' => $uploads['name'][$index],
                    'type' => $uploads['type'][$index] ?? '',
                    'tmp_name' => $uploads['tmp_name'][$index] ?? '',
                    'error' => $uploads['error'][$index] ?? UPLOAD_ERR_NO_FILE,
                    'size' => $uploads['size'][$index] ?? 0
                ];
            }
        } else {
            $uploadFiles[] = $uploads;
        }

        $validFiles = [];
        foreach ($uploadFiles as $upload) {
            if ($upload['error'] === UPLOAD_ERR_NO_FILE) {
                continue;
            }

            if ($upload['error'] !== UPLOAD_ERR_OK) {
                throw new InvalidArgumentException('An image upload failed. Please try again.');
            }

            if (count($validFiles) >= $this->maximumFiles) {
                throw new InvalidArgumentException('You can upload up to 5 images per record.');
            }

            if ($upload['size'] > $this->maximumFileSize) {
                throw new InvalidArgumentException('Each image must be 5 MB or smaller.');
            }

            if (!is_uploaded_file($upload['tmp_name'])) {
                throw new InvalidArgumentException('An uploaded image could not be verified.');
            }

            $fileInfo = new finfo(FILEINFO_MIME_TYPE);
            $mimeType = $fileInfo->file($upload['tmp_name']);

            if (!array_key_exists($mimeType, $this->allowedMimeTypes)) {
                throw new InvalidArgumentException('Images must be JPEG, PNG, or WebP files.');
            }

            if (getimagesize($upload['tmp_name']) === false) {
                throw new InvalidArgumentException('An uploaded file is not a valid image.');
            }

            $upload['mime_type'] = $mimeType;
            $upload['extension'] = $this->allowedMimeTypes[$mimeType];
            $validFiles[] = $upload;
        }

        return $validFiles;
    }

    public function saveUploads(string $entityType, int $entityId, array $uploads): array {
        if (!array_key_exists($entityType, $this->imageTypes)) {
            throw new InvalidArgumentException('Invalid image record type.');
        }

        $storageDirectory = $this->getStorageDirectory($entityType);
        if (!is_dir($storageDirectory) && !mkdir($storageDirectory, 0750, true) && !is_dir($storageDirectory)) {
            throw new RuntimeException('Unable to create the image storage directory.');
        }

        $savedStorageKeys = [];

        try {
            foreach ($uploads as $upload) {
                $fileName = bin2hex(random_bytes(16)) . '.' . $upload['extension'];
                $storageKey = $this->imageTypes[$entityType]['directory'] . '/' . $fileName;
                $filePath = $storageDirectory . '/' . $fileName;

                if (!move_uploaded_file($upload['tmp_name'], $filePath)) {
                    throw new RuntimeException('Unable to save an uploaded image.');
                }

                $savedStorageKeys[] = $storageKey;

                if (!$this->imageRepository->create($entityType, $entityId, $storageKey, $upload['mime_type'])) {
                    throw new RuntimeException('Unable to save image details.');
                }
            }
        } catch (Throwable $error) {
            $this->deleteStoredFiles($savedStorageKeys);
            throw $error;
        }

        return $savedStorageKeys;
    }

    public function deleteStoredFiles(array $storageKeys): void {
        foreach ($storageKeys as $storageKey) {
            $storagePath = $this->getStoragePath($storageKey);
            if ($storagePath && is_file($storagePath)) {
                unlink($storagePath);
            }
        }
    }

    public function attachImageUrls(string $entityType, array $records, string $idField): array {
        foreach ($records as &$record) {
            $record['images'] = $this->getImageUrls($entityType, (int) $record[$idField]);
        }
        unset($record);

        return $records;
    }

    public function getImageUrls(string $entityType, int $entityId): array {
        $imageRecords = $this->imageRepository->getForEntity($entityType, $entityId);

        foreach ($imageRecords as &$imageRecord) {
            $imageRecord['url'] = $this->imageTypes[$entityType]['public_path'] . $imageRecord['image_id'];
            unset($imageRecord['storage_key']);
        }
        unset($imageRecord);

        return $imageRecords;
    }

    public function getImageFile(string $entityType, int $imageId): array|false {
        if (!array_key_exists($entityType, $this->imageTypes)) {
            return false;
        }

        $image = $this->imageRepository->getById($entityType, $imageId);
        if (!$image) {
            return false;
        }

        $filePath = $this->getStoragePath($image['storage_key']);
        if (!$filePath || !is_file($filePath)) {
            return false;
        }

        $image['file_path'] = $filePath;
        return $image;
    }

    private function getStorageDirectory(string $entityType): string {
        return dirname(__DIR__, 2) . '/storage/' . $this->imageTypes[$entityType]['directory'];
    }

    private function getStoragePath(string $storageKey): string|false {
        $storageRoot = realpath(dirname(__DIR__, 2) . '/storage');
        if ($storageRoot === false) {
            return false;
        }

        $filePath = realpath($storageRoot . '/' . $storageKey);
        if ($filePath === false || !str_starts_with($filePath, $storageRoot . DIRECTORY_SEPARATOR)) {
            return false;
        }

        return $filePath;
    }
}
