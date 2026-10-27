<?php

class AdminController {
    private AdminService $adminService;

    public function __construct(AdminService $adminService) {
        $this->adminService = $adminService;
    }

    public function handleRequest(string $method, string $path): void {

        //Test endpoint to check if the API is working
        if ($method === 'GET' && $path === '/api/admin/test') {
            echo json_encode($this->adminService->test());
            return;
        }

        //Endpoint to get all items from the database
        if ($method === 'GET' && $path === '/api/admin/items') {
            echo json_encode($this->adminService->getAllItems());
            return;
        }

        http_response_code(404);
        echo json_encode(['error' => 'Admin endpoint not found']);
    }
}