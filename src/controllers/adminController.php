<?php

class AdminController {
    private ItemService $itemService;
    private SMSService $smsService;
    private PDO $connection;

    public function __construct(PDO $connection) {
        $this->connection = $connection;
        $this->itemService = new ItemService($connection);
        $this->smsService = new SMSService();
    }

    public function handleRequest(string $method, string $path): void {

        //Test endpoint to check if the API is working
        if ($method === 'GET' && $path === '/api/admin/test') {
            echo json_encode($this->itemService->test());
            return;
        }

        //Endpoint to get all items from the database
        if ($method === 'GET' && $path === '/api/admin/items') {
            echo json_encode($this->itemService->getAllItems());
            return;
        }


        //Endpoints to get SMS gateway info (textbee integration)
        if ($method === 'GET' && $path === '/api/admin/sms/stats') {
            echo json_encode($this->smsService->getGatewayStats());
            return;
        }

        if ($method === 'GET' && $path === '/api/admin/sms/devices') {
            echo json_encode($this->smsService->getGatewayDevices());
            return;
        }

        http_response_code(404);
        echo json_encode(['error' => 'Admin endpoint not found']);
    }
}