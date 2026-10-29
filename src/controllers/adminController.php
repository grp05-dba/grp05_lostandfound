<?php

class AdminController {
    private ItemService $itemService;
    private SMSService $smsService;
    private LostReportService $lostReportService;
    private ClaimService $claimService;
    private PDO $connection;

    public function __construct(PDO $connection) {
        $this->connection = $connection;
        $this->itemService = new ItemService($connection);
        $this->smsService = new SMSService();
        $this->lostReportService = new LostReportService($connection);
        $this->claimService = new ClaimService($connection);
    }

    public function handleRequest(string $method, string $path): void {

        if ($method === 'GET' && $path === '/api/admin/lost-reports') {
            echo json_encode($this->lostReportService->getAllLostReports());
            return;
        }

        if ($method === 'GET' && $path === '/api/admin/claims') {
            echo json_encode($this->claimService->getAllClaims());
            return;
        }

        if ($method === 'GET' && preg_match('#^/api/admin/(items|lost-reports|claims)/([^/]+)$#', $path, $matches)) {
            $id = filter_var($matches[2], FILTER_VALIDATE_INT, ['options' => ['min_range' => 1, 'max_range' => 2147483647]]);
            if ($id === false) {
                http_response_code(400);
                echo json_encode(['error' => 'ID must be a positive integer.']);
                return;
            }
            $record = match ($matches[1]) {
                'items' => $this->itemService->getItemById($id),
                'lost-reports' => $this->lostReportService->getLostReportById($id),
                'claims' => $this->claimService->getClaimById($id),
            };
            echo json_encode($record);
            return;
        }

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
