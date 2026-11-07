<?php

require_once __DIR__ . '/../../src/utils/requestUtils.php';
require_once __DIR__ . '/../../src/services/lostReportService.php';
require_once __DIR__ . '/../../src/services/claimService.php';
require_once __DIR__ . '/../../src/services/imageService.php';
require_once __DIR__ . '/../../src/controllers/publicController.php';
require_once __DIR__ . '/../../src/controllers/adminController.php';

// Keep controller/HTTP behavior real; replace database and notification services.
class LookupLostReportService extends LostReportService {
    public function __construct() {}

    public function getLostReportByCode(string $code): array {
        return ['report_code' => $code];
    }

    public function cancelLostReportByCode(string $code): array {
        return ['cancelled_report_code' => $code];
    }

    public function getLostReportById(int $id): array {
        return ['report_id' => $id];
    }
}

class LookupClaimService extends ClaimService {
    public function __construct() {}

    public function getClaimByCode(string $code): array {
        return ['claim_code' => $code];
    }
}

class LookupImageService extends ImageService {
    public function __construct() {}

    public function getImageFile(string $entityType, int $imageId): array|false {
        if ($entityType !== 'lost-reports' || $imageId !== 7) {
            return false;
        }

        return ['mime_type' => 'image/png', 'file_path' => getenv('TEST_IMAGE_PATH')];
    }
}

$path = $_SERVER['REQUEST_URI'];
$reflection = new ReflectionClass(str_starts_with($path, '/api/admin/') ? AdminController::class : PublicController::class);
$controller = $reflection->newInstanceWithoutConstructor();
foreach ([
    'lostReportService' => new LookupLostReportService(),
    'claimService' => new LookupClaimService(),
    'imageService' => new LookupImageService(),
] as $name => $service) {
    $reflection->getProperty($name)->setValue($controller, $service);
}

header('Content-Type: application/json');
$controller->handleRequest($_SERVER['REQUEST_METHOD'], $path);
