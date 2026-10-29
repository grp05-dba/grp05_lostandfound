<?php

require_once __DIR__ . '/../src/db/db.php';
require_once __DIR__ . '/../src/repositories/lostReportRepository.php';
require_once __DIR__ . '/../src/repositories/claimRepository.php';
require_once __DIR__ . '/../src/services/lostReportService.php';
require_once __DIR__ . '/../src/services/claimService.php';

$connection = Connection::getConnection();
if (!$connection) { exit(1); }
$connection->beginTransaction();
try {
    $connection->exec('DELETE FROM potential_matches');
    $connection->exec('DELETE FROM claims');
    $connection->exec('DELETE FROM lost_reports');
    foreach ([new LostReportService($connection), new ClaimService($connection)] as $service) {
        $result = $service instanceof LostReportService ? $service->getAllLostReports() : $service->getAllClaims();
        if (json_encode($result) !== '[]') {
            throw new RuntimeException('Empty collection did not serialize as [].');
        }
    }
    echo "PASS: both empty collections serialize as []; transaction rolled back.\n";
} finally {
    $connection->rollBack();
}
