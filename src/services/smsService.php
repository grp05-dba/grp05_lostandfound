<?php

class SMSService {
    private TextBeeClient $textBeeClient;

    public function __construct() {
        $this->textBeeClient = new TextBeeClient();
    }

    public function getGatewayStats(): array {
        return $this->textBeeClient->getGatewayStats();
    }

    public function getGatewayDevices(): array {
        return $this->textBeeClient->getGatewayDevices();
    }

    public function sendSMS(array $lostReport, array $item): array {
        $itemTitle = $item['title'];
        $locationFound = $item['location_found'] ?? null;
        $dateFound = $item['date_found'] ?? null;

        if (empty($locationFound)) {
            $locationFound = 'an unknown location';
        }

        if (empty($dateFound)) {
            $dateFound = 'an unknown date';
        }

        $message = "Possible match found for your lost report: $itemTitle, found at $locationFound on $dateFound. " .
            "This is not confirmed. To view details, use your lost report code: {$lostReport['report_code']}.";

        return $this->textBeeClient->sendSMS($message, $lostReport['phone_number']);
    }
}