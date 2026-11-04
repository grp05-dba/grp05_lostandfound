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

    public function sendSMSPotentialMatchNotification(array $lostReport, array $item): array {
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

    public function sendSMSLostReportCreation(array $lostReport): array {
        $name = $lostReport['full_name'];
        $reportCode = $lostReport['report_code'];
        $message = "*PUP-SPOT Automated Notification*\n" .
            "Hi $name,\n\n" .
            "Your lost report has been created successfully.\n" .
            "Please keep your report code, $reportCode, safe and your SMS notifications enabled. PUP-SPOT will notify you if a potential match is found for your reported item.\n\n" .
            "Thank You,\n" .
            "PUP-SPOT";

        return $this->textBeeClient->sendSMS($message, $lostReport['phone_number']);
    }

    public function sendSMSLostReportCancellation(array $lostReport): array {
        $name = $lostReport['full_name'];
        $reportCode = $lostReport['report_code'];
        $message = "*PUP-SPOT Automated Notification*\n" .
            "Hi $name,\n\n" .
            "Your lost report $reportCode has been cancelled.\n\n" .
            "Thank You,\n" .
            "PUP-SPOT";
        return $this->textBeeClient->sendSMS($message, $lostReport['phone_number']);
    }

    public function sendSMSClaimCreation(array $claim): array {
        $name = $claim['full_name'];
        $claimCode = $claim['claim_code'];
        $message = "*PUP-SPOT Automated Notification*\n" .
            "Hi $name,\n\n" .
            "Your claim has been submitted successfully. Please wait for the Lost and Found Office to review and approve your claim. You will be notified once its status is updated. You can view your claim status at any time using your claim reference code, $claimCode.\n\n" .
            "Thank You,\n" .
            "PUP-SPOT";
        return $this->textBeeClient->sendSMS($message, $claim['phone_number']);
    }

    public function sendSMSClaimApproval(array $claim): array {
        $name = $claim['full_name'];
        $claimCode = $claim['claim_code'];
        $message = "*PUP-SPOT Automated Notification*\n" .
            "Hi $name,\n\n" .
            "Your claim has been approved! Please visit the office to claim your item. Use your claim reference code, $claimCode, to view your claim receipt in PUP-SPOT, then take a screenshot and present it to the office for verification.\n\n" .
            "Thank You,\n" .
            "PUP-SPOT";
        return $this->textBeeClient->sendSMS($message, $claim['phone_number']);
    }

    public function sendSMSClaimRejection(array $claim): array {
        $name = $claim['full_name'];
        $claimCode = $claim['claim_code'];
        $message = "*PUP-SPOT Automated Notification*\n" .
            "Hi $name,\n\n" .
            "Your claim $claimCode has been rejected. Please contact the Lost and Found Office for more information.\n\n" .
            "Thank You,\n" .
            "PUP-SPOT";
        return $this->textBeeClient->sendSMS($message, $claim['phone_number']);
    }
}