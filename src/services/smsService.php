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
        $locationFound = $item['location_found'] ?? 'an unknown location';
        $dateFound = $item['date_found'] ?? 'an unknown date';
        $name = $lostReport['full_name'];
        $reportCode = $lostReport['report_code'];

        $message = "*PUP-SPOT Automated Notification*\n" .
            "Hi $name,\n\n" .
            "A possible match was found for your lost report: $itemTitle, found at $locationFound on $dateFound.\n\n" .
            "This is not confirmed. To view details, use your lost report code: $reportCode.\n\n" .
            "Thank You,\n" .
            "PUP-SPOT";

        return $this->textBeeClient->sendSMS($message, $lostReport['phone_number']);
    }
}