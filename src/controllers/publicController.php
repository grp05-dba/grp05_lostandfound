<?php

class PublicController {
    private CategoryService $categoryService;
    private ItemService $itemService;
    private SearchService $searchService;
    private LostReportService $lostReportService;
    private ClaimService $claimService;
    private PotentialMatchService $potentialMatchService;
    private ImageService $imageService;
    private PDO $connection;

    public function __construct(PDO $connection) {
        $this->connection = $connection;
        $this->categoryService = new CategoryService($connection);
        $this->itemService = new ItemService($connection);
        $this->searchService = new SearchService($connection);
        $this->lostReportService = new LostReportService($connection);
        $this->claimService = new ClaimService($connection);
        $this->potentialMatchService = new PotentialMatchService($connection);
        $this->imageService = new ImageService($connection);
    }

    public function handleRequest(string $method, string $path): void{
        // Ignore query parameters when matching routes.
        $query = parse_url($path, PHP_URL_QUERY) ?? '';
        $path = parse_url($path, PHP_URL_PATH) ?: $path;   


        // Lost report endpoints-------------------------------------
        if ($method === 'POST' && $path === '/api/public/lost-reports/add') {
            echo json_encode($this->lostReportService->createLostReport(
                RequestUtils::getRequestData(),
                $_FILES['images'] ?? []
            ));
            return;
        }

        if ($method === 'POST' && $path === '/api/public/lost-reports/view') {
            echo json_encode($this->lostReportService->getLostReportByCode(RequestUtils::getRequestBody()['report_code']));
            return;
        }

        if ($method === 'POST' && $path === '/api/public/lost-reports/cancel') {
            echo json_encode($this->lostReportService->cancelLostReportByCode(RequestUtils::getRequestBody()['report_code']));
            return;
        }

        
        //Potential match endpoints-------------------------------------
        if ($method === 'GET' && str_starts_with($path, '/api/public/lost-reports/matches/')) {
            $reportCode = str_replace('/api/public/lost-reports/matches/', '', $path);
            echo json_encode($this->potentialMatchService->getPotentialMatchesByReportCode($reportCode));
            return;
        }


        // Claim endpoints-------------------------------------
        if ($method === 'POST' && $path === '/api/public/claims/add') {
            echo json_encode($this->claimService->createClaim(
                RequestUtils::getRequestData(),
                $_FILES['images'] ?? []
            ));
            return;
        }

        if ($method === 'POST' && $path === '/api/public/claims/view') {
            $claim = $this->claimService->getClaimByCode(RequestUtils::getRequestBody()['claim_code']);

            if (isset($claim['item_id'])) {
                $claim['claimed_item'] = $this->itemService->getItemById((int) $claim['item_id']);
            }

            echo json_encode($claim);
            return;
        }


        // Miscellaneous public endpoints-------------------------------------
        if ($method === 'GET' && $path === '/api/public/items') {
            echo json_encode($this->itemService->getAllUnclaimedItems());
            return;
        }

        if ($method === 'GET' && str_starts_with($path, '/api/public/items/images/')) {
            $imageId = (int) str_replace('/api/public/items/images/', '', $path);
            $this->sendImage('items', $imageId);
            return;
        }

        if ($method === 'GET' && str_starts_with($path, '/api/public/lost-reports/images/')) {
            $imageId = (int) str_replace('/api/public/lost-reports/images/', '', $path);
            $this->sendImage('lost-reports', $imageId);
            return;
        }

        if ($method === 'GET' && $path === '/api/public/items/search') {
            $filters = [];
            parse_str($query, $filters);
            echo json_encode($this->searchService->searchItems($filters));
            return;
        }

        if ($method === 'GET' && $path === '/api/public/categories') {
            echo json_encode($this->categoryService->getAllCategories());
            return;
        }

        if ($method === 'GET' && str_starts_with($path, '/api/public/categories/')) {
            $id = (int) str_replace('/api/public/categories/', '', $path);
            echo json_encode($this->categoryService->getCategoryById($id));
            return;
        }

        http_response_code(404);
        echo json_encode(['error' => 'Public endpoint not found']);
    }

    private function sendImage(string $entityType, int $imageId): void {
        $image = $this->imageService->getImageFile($entityType, $imageId);

        if (!$image) {
            http_response_code(404);
            echo json_encode(['message' => 'Image not found.']);
            return;
        }

        header('Content-Type: ' . $image['mime_type']);
        header('Content-Length: ' . filesize($image['file_path']));
        header('X-Content-Type-Options: nosniff');
        header('Cache-Control: public, max-age=86400');
        readfile($image['file_path']);
    }
}
