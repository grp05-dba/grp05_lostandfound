<?php

class AdminController {
    private ItemService $itemService;
    private SMSService $smsService;
    private LostReportService $lostReportService;
    private ClaimService $claimService;
    private PhotoService $photoService;
    private PDO $connection;

    public function __construct(PDO $connection) {
        $this->connection = $connection;
        $this->itemService = new ItemService($connection);
        $this->smsService = new SMSService();
        $this->lostReportService = new LostReportService($connection);
        $this->claimService = new ClaimService($connection);
        $this->photoService = new PhotoService($connection);
    }

    public function handleRequest(string $method, string $path): void {
        // Ignore query parameters when matching routes.
        $path = parse_url($path, PHP_URL_PATH) ?: $path;

        //Lost report endpoints-------------------------------------
        if ($method === 'GET' && $path === '/api/admin/lost-reports') {
            echo json_encode($this->lostReportService->getAllLostReports());
            return;
        }

        if ($method === 'GET' && str_starts_with($path, '/api/admin/lost-reports/')) {
            $id = (int) str_replace('/api/admin/lost-reports/', '', $path);
            echo json_encode($this->lostReportService->getLostReportById($id));
            return;
        }

        if ($method === 'PATCH' && str_starts_with($path, '/api/admin/lost-reports/update/')) {
            $itemId = (int) str_replace('/api/admin/lost-reports/update/', '', $path);
            $result = $this->lostReportService->updateLostReport($itemId, RequestUtils::getRequestBody());
            echo json_encode($result);
            return;
        }


        //Claim endpoints-------------------------------------
        if ($method === 'GET' && $path === '/api/admin/claims') {
            echo json_encode($this->claimService->getAllClaims());
            return;
        }

        if ($method === 'GET' && str_starts_with($path, '/api/admin/claims/')) {
            $id = (int) str_replace('/api/admin/claims/', '', $path);
            echo json_encode($this->claimService->getClaimById($id));
            return;
        }

        if ($method === 'PATCH' && str_starts_with($path, '/api/admin/claims/update/')) {
            $claimId = (int) str_replace('/api/admin/claims/update/', '', $path);
            $result = $this->claimService->updateClaim($claimId, RequestUtils::getRequestBody());
            echo json_encode($result);
            return;
        }


        //Item photo endpoints-------------------------------------
        if (preg_match('#^/api/admin/items/(\\d+)/photos$#', $path, $matches)) {
            $itemId = (int) $matches[1];
            if ($method === 'POST') {
                echo json_encode($this->photoService->addUploadedPhotos('item', $itemId, $_FILES['photos'] ?? []));
                return;
            }
            if ($method === 'GET') {
                echo json_encode($this->photoService->getPhotos('item', $itemId));
                return;
            }
        }

        //Item endpoints-------------------------------------
        if ($method === 'GET' && $path === '/api/admin/items') {
            echo json_encode($this->itemService->getAllItems());
            return;
        }

        if ($method === 'GET' && str_starts_with($path, '/api/admin/items/')) {
            $id = (int) str_replace('/api/admin/items/', '', $path);
            echo json_encode($this->itemService->getItemById($id));
            return;
        }

        if ($method === 'POST' && $path === '/api/admin/items/add') {
            $result = $this->itemService->createItem(RequestUtils::getRequestBody());
            echo json_encode($result);
            return;
        }

        if ($method === 'PATCH' && str_starts_with($path, '/api/admin/items/update/')) {
            $itemId = (int) str_replace('/api/admin/items/update/', '', $path);
            $result = $this->itemService->updateItem($itemId, RequestUtils::getRequestBody());
            echo json_encode($result);
            return;
        }


        //Debugging endpoints-------------------------------------
        //Endpoints to get SMS gateway info (textbee integration)
        if ($method === 'GET' && $path === '/api/admin/sms/stats') {
            echo json_encode($this->smsService->getGatewayStats());
            return;
        }

        if ($method === 'GET' && $path === '/api/admin/sms/devices') {
            echo json_encode($this->smsService->getGatewayDevices());
            return;
        }


        //Test endpoint to check if the API is working
        if ($method === 'GET' && $path === '/api/admin/test') {
            echo json_encode($this->itemService->test());
            return;
        }

        http_response_code(404);
        echo json_encode(['error' => 'Admin endpoint not found']);
    }
}
