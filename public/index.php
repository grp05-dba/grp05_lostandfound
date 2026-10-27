<?php

header('Content-Type: application/json');

require_once __DIR__ . '/../src/repositories/itemRepository.php';
require_once __DIR__ . '/../src/db/db.php';
require_once __DIR__ . '/../src/controllers/adminController.php';
require_once __DIR__ . '/../src/controllers/publicController.php';
require_once __DIR__ . '/../src/services/adminService.php';

$connection = Connection::getConnection();

if (!$connection) {
    http_response_code(500);
    echo json_encode(['error' => 'Database connection failed']);
    exit;
}

$adminService = new AdminService($connection);

$path = $_SERVER['REQUEST_URI'];

if (str_starts_with($path, '/api/admin/')) {
    $controller = new AdminController($adminService);
} 
else if (str_starts_with($path, '/api/public/')) {
    //$controller = new PublicController($connect);
    //wait
}
else {
    http_response_code(404);
    echo json_encode(['error' => 'Endpoint not found']);
    exit;
}

$controller->handleRequest();