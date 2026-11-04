<?php

class PotentialMatchService {
    private PotentialMatchRepository $potentialMatchRepository;
    private ItemRepository $itemRepository;

    public function __construct(PDO $connection) {
        $this->potentialMatchRepository = new PotentialMatchRepository($connection);
        $this->itemRepository = new ItemRepository($connection);
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

    public function findPotentialMatches(array $lostReport): void {
        $dateLost = $lostReport['date_lost'] ?? null;

        if ($dateLost) {
            $items = $this->itemRepository->getEligibleItems($dateLost);
        } else {
            $items = $this->itemRepository->getAllUnclaimedItems();
        }

        foreach ($items as $item) {
            $score = $this->calculateSimilarity($lostReport, $item);

            if ($score >= 60) {
                $this->potentialMatchRepository->create(
                    $lostReport['report_id'],
                    $item['item_id'],
                    round($score, 2)
                );
            }
        }
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
        $score += $this->compareText(
            $lostReport['description'],
            $item['description']
        ) * 0.25;
        $totalWeight += 0.25;

        // Category (15%)
        if (!empty($lostReport['category_id']) && !empty($item['category_id'])) {
            $score += (
                (int) $lostReport['category_id'] === (int) $item['category_id'] ? 1.0 : 0.0
            ) * 0.15;
            $totalWeight += 0.15;
        }

        // Location (15%)
        if (!empty($lostReport['location_lost']) && !empty($item['location_found'])) {
            $score += (
                (int) $lostReport['location_lost'] === (int) $item['location_found'] ? 1.0 : 0.0
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