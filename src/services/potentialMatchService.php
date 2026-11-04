<?php

class PotentialMatchService {
    private PotentialMatchRepository $potentialMatchRepository;
    private ItemRepository $itemRepository;
    private LostReportRepository $lostReportRepository;

    public function __construct(PDO $connection) {
        $this->potentialMatchRepository = new PotentialMatchRepository($connection);
        $this->itemRepository = new ItemRepository($connection);
        $this->lostReportRepository = new LostReportRepository($connection);
    }

    public function getAllPotentialMatches(): array {
        return $this->potentialMatchRepository->getAll();
    }

    public function getPotentialMatchById(int $id): array {
        $success = $this->potentialMatchRepository->getById($id);
        return RequestUtils::handleFindFailure($success) ?? $success;
    }

    public function deleteByReportId(int $reportId): void {
        $this->potentialMatchRepository->deleteByReportId($reportId);
    }
    
    public function deleteByItemId(int $itemId): void {
        $this->potentialMatchRepository->deleteByItemId($itemId);
    }

    public function findPotentialMatches(array $lostReport): int {
        $dateLost = $lostReport['date_lost'] ?? null;

        if ($dateLost) {
            $items = $this->itemRepository->getEligibleItems($dateLost);
        } else {
            $items = $this->itemRepository->getAllUnclaimedItems();
        }

        $matchesSaved = 0;

        foreach ($items as $item) {
            $score = $this->calculateSimilarity($lostReport, $item);

            if ($score >= 60 && $this->potentialMatchRepository->create(
                    $lostReport['report_id'],
                    $item['item_id'],
                    round($score, 2)
                )) {
                $matchesSaved++;
            }
        }

        return $matchesSaved;
    }

    public function findPotentialReports(array $item): int {
        $dateFound = $item['date_found'] ?? null;

        if ($dateFound) {
            $reports = $this->lostReportRepository->getEligibleReports($dateFound);
        } else {
            $reports = $this->lostReportRepository->getAllActiveReports();
        }

        $matchesSaved = 0;

        foreach ($reports as $report) {
            $score = $this->calculateSimilarity($report, $item);

            if ($score >= 60 && $this->potentialMatchRepository->create(
                    $report['report_id'],
                    $item['item_id'],
                    round($score, 2)
                )) {
                $matchesSaved++;
            }
        }

        return $matchesSaved;
    }

    public function hasMatchingFieldsChanged(array $data, array $existingData): bool {
        $matchingFields = [
            'title',
            'description',
            'location_lost',
            'date_lost',
            'category_id',
            'location_found',
            'date_found'
        ];

        foreach ($matchingFields as $field) {
            if (array_key_exists($field, $data) && $data[$field] != $existingData[$field]) {
                return true;
            }
        }
        return false;
    }


    // Private helper methods --------------------------------
    private function calculateSimilarity(array $lostReport, array $item): float {
        $score = 0;
        $totalWeight = 0;

        // Title (35%)
        $score += $this->compareText(
            $lostReport['title'],
            $item['title']
        ) * 0.35;
        $totalWeight += 0.35;

        // Description (25%)
        if(!empty($lostReport['description']) && !empty($item['description'])) {
            $score += $this->compareText(
                $lostReport['description'],
                $item['description']
            ) * 0.25;
            $totalWeight += 0.25;
        }

        // Category (15%)
        if (!empty($lostReport['category_id']) && !empty($item['category_id'])) {
            $score += (
                (int) $lostReport['category_id'] === (int) $item['category_id'] ? 1.0 : 0.0
            ) * 0.15;
            $totalWeight += 0.15;
        }

        // Location (15%) 
        // Frontend should provide a dropdown of locations to ensure consistency in location names. didnt think of this earlier sry :(
        if (!empty($lostReport['location_lost']) && !empty($item['location_found'])) {
            $score += (
                $lostReport['location_lost'] === $item['location_found'] ? 1.0 : 0.0
            ) * 0.15;
            $totalWeight += 0.15;
        }

        // Date (10%)
        if (!empty($lostReport['date_lost']) && !empty($item['date_found'])) {
            $score += $this->compareDate(
                $lostReport['date_lost'],
                $item['date_found']
            ) * 0.10;
            $totalWeight += 0.10;
        }

        return $totalWeight > 0 ? ($score / $totalWeight) * 100 : 0;
    }

    private function compareText(string $first, string $second): float {
        similar_text(
            strtolower($first),
            strtolower($second),
            $percentage
        );

        return $percentage / 100;
    }

    private function compareDate(string $dateLost, string $dateFound): float {
        $daysDifference = abs(
            (strtotime($dateLost) - strtotime($dateFound)) / 86400
        );

        // Closer dates receive higher scores.
        return max(0, 1 - ($daysDifference / 30));
    }
}