<?php

class PublicController {
    private CategoryService $categoryService;
    private LostReportService $lostReportService;
    private ClaimService $claimService;
    private PhotoService $photoService;
    private PDO $connection;

    public function __construct(PDO $connection) {
        $this->connection = $connection;
        $this->categoryService = new CategoryService($connection);
        $this->lostReportService = new LostReportService($connection);
        $this->claimService = new ClaimService($connection);
        $this->photoService = new PhotoService($connection);
    }

    public function handleRequest(string $method, string $path): void{

        if (preg_match('#^/api/public/lost-reports/(\\d+)/photos/(\\d+)$#', $path, $photoMatches) && $method === 'GET') {
            $photo = $this->photoService->getPhoto('lost_report', (int) $photoMatches[1], (int) $photoMatches[2]);
            if (!$photo) { http_response_code(404); echo json_encode(['message' => 'Photo not found.']); return; }
            header('Content-Type: ' . $photo['mime_type']);
            header('Content-Disposition: inline; filename="' . basename($photo['file_name']) . '"');
            $data = $photo['photo_data'];
            echo is_resource($data) ? stream_get_contents($data) : $data;
            return;
        }

        if (preg_match('#^/api/public/lost-reports/(\\d+)/photos$#', $path, $matches)) {
            $reportId = (int) $matches[1];
            if ($method === 'POST') {
                echo json_encode($this->photoService->addUploadedPhotos('lost_report', $reportId, $_FILES['photos'] ?? []));
                return;
            }
            if ($method === 'GET') {
                echo json_encode($this->photoService->getPhotos('lost_report', $reportId));
                return;
            }
        }

        if (preg_match('#^/api/public/claims/(\\d+)/photos/(\\d+)$#', $path, $photoMatches) && $method === 'GET') {
            $photo = $this->photoService->getPhoto('claim', (int) $photoMatches[1], (int) $photoMatches[2]);
            if (!$photo) { http_response_code(404); echo json_encode(['message' => 'Photo not found.']); return; }
            header('Content-Type: ' . $photo['mime_type']);
            header('Content-Disposition: inline; filename="' . basename($photo['file_name']) . '"');
            $data = $photo['photo_data'];
            echo is_resource($data) ? stream_get_contents($data) : $data;
            return;
        }

        if (preg_match('#^/api/public/claims/(\\d+)/photos$#', $path, $matches)) {
            $claimId = (int) $matches[1];
            if ($method === 'POST') {
                echo json_encode($this->photoService->addUploadedPhotos('claim', $claimId, $_FILES['photos'] ?? []));
                return;
            }
            if ($method === 'GET') {
                echo json_encode($this->photoService->getPhotos('claim', $claimId));
                return;
            }
        }

        if ($method === 'POST' && $path === '/api/public/lost-reports/add') {
            echo json_encode($this->lostReportService->createLostReport(RequestUtils::getRequestBody()));
            return;
        }

        if ($method === 'POST' && $path === '/api/public/claims/add') {
            echo json_encode($this->claimService->createClaim(RequestUtils::getRequestBody()));
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
}
