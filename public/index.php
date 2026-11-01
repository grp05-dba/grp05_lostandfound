<?php

header('Content-Type: application/json');

require_once __DIR__ . '/../src/db/db.php';
require_once __DIR__ . '/../src/integrations/textbeeClient.php';
require_once __DIR__ . '/../src/controllers/adminController.php';
require_once __DIR__ . '/../src/controllers/publicController.php';
require_once __DIR__ . '/../src/services/itemService.php';
require_once __DIR__ . '/../src/services/categoryService.php';
require_once __DIR__ . '/../src/services/smsService.php';
require_once __DIR__ . '/../src/repositories/itemRepository.php';
require_once __DIR__ . '/../src/repositories/categoryRepository.php';
require_once __DIR__ . '/../src/services/lostReportService.php';
require_once __DIR__ . '/../src/services/claimService.php';
require_once __DIR__ . '/../src/repositories/lostReportRepository.php';
require_once __DIR__ . '/../src/repositories/claimRepository.php';

require_once __DIR__ . '/../src/entities/item.php';

require_once __DIR__ . '/../src/utils/requestUtils.php';

try {
    $connection = Connection::getConnection();
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Database connection failed']);
    exit;
}

$controller = null;
$method = $_SERVER['REQUEST_METHOD'];
$path = $_SERVER['REQUEST_URI'];

if (str_starts_with($path, '/api/admin/')) {
    $controller = new AdminController($connection);
} 
else if (str_starts_with($path, '/api/public/')) {
    $controller = new PublicController($connection);
}
else {
    http_response_code(404);
    echo json_encode(['error' => 'Endpoint not found']);
    exit;
}

if($controller){
    try {
        $controller->handleRequest($method, $path);
    } catch (PDOException $e) {
        error_log($e->getMessage());
        http_response_code(500);
        echo json_encode(['error' => 'Database operation failed']);
    }
}
else {
http_response_code(404);
    echo json_encode(['error' => 'Controller not found']);
}
