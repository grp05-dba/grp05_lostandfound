<?php

class PotentialMatchService {
    private ItemRepository $itemRepository;
    private LostReportRepository $lostReportRepository;
    private PotentialMatchRepository $potentialMatchRepository;
    private NotificationService $notificationService;

    private const MATCH_THRESHOLD = 0.55;
    private const TITLE_THRESHOLD = 0.40;

    public function __construct(PDO $connection) {
        $this->itemRepository = new ItemRepository($connection);
        $this->lostReportRepository = new LostReportRepository($connection);
        $this->potentialMatchRepository = new PotentialMatchRepository($connection);
        $this->notificationService = new NotificationService();
    }

    public function getAllPotentialMatches(): array {
        return $this->potentialMatchRepository->getAll();
    }

    public function getMatchesForReport(int $reportId): array {
        return $this->potentialMatchRepository->getByReportId($reportId);
    }

    public function getMatchesForItem(int $itemId): array {
        return $this->potentialMatchRepository->getByItemId($itemId);
    }

    public function deletePotentialMatch(int $matchId): array {
        if (!$this->potentialMatchRepository->delete($matchId)) {
            http_response_code(404);
            return ['message' => 'Potential match not found.'];
        }

        return ['message' => 'Potential match deleted successfully.'];
    }

    public function generatePotentialMatches(): int {
        $reports = $this->lostReportRepository->getAll();
        $items = $this->itemRepository->getAll();
        $created = 0;

        foreach ($reports as $report) {
            if (($report['status'] ?? 'active') !== 'active') {
                continue;
            }

            foreach ($items as $item) {
                if (($item['status'] ?? 'unclaimed') !== 'unclaimed') {
                    continue;
                }

                if (!$this->isPotentialMatch($report, $item)) {
                    continue;
                }

                if ($this->potentialMatchRepository->createIfNotExists(
                    (int) $report['report_id'],
                    (int) $item['item_id']
                )) {
                    $created++;
                    $this->notificationService->notifyPotentialMatch($report, $item);
                }
            }
        }

        return $created;
    }

    private function isPotentialMatch(array $report, array $item): bool {
        $title = $this->similarity($report['title'] ?? '', $item['title'] ?? '');
        $description = $this->similarity($report['description'] ?? '', $item['description'] ?? '');
        $location = $this->similarity($report['location_lost'] ?? '', $item['location_found'] ?? '');
        $category = (
            isset($report['category_id'], $item['category_id']) &&
            (int) $report['category_id'] === (int) $item['category_id']
        ) ? 1.0 : 0.0;

        $score = ($title * 0.60) + ($description * 0.25) +
            ($location * 0.10) + ($category * 0.05);

        return $score >= self::MATCH_THRESHOLD &&
            ($title >= self::TITLE_THRESHOLD || $score >= 0.68);
    }

    private function similarity(string $first, string $second): float {
        $first = $this->normalize($first);
        $second = $this->normalize($second);

        if ($first === '' || $second === '') {
            return 0.0;
        }

        if ($first === $second) {
            return 1.0;
        }

        similar_text($first, $second, $percentage);
        return $percentage / 100;
    }

    private function normalize(string $value): string {
        $value = trim($value);
        $value = function_exists('mb_strtolower')
            ? mb_strtolower($value, 'UTF-8')
            : strtolower($value);
        $value = preg_replace('/[^\p{L}\p{N}\s]/u', ' ', $value) ?? '';
        $value = preg_replace('/\s+/u', ' ', $value) ?? '';
        return trim($value);
    }
}
