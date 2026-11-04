<?php

class EmailService {
    private EmailJSClient $emailJSClient;

    public function __construct() {
        $this->emailJSClient = new EmailJSClient();
    }

    public function sendEmailPotentialMatchNotification(array $lostReport, array $item): array {
        $itemTitle = $item['title'];
        $locationFound = $item['location_found'] ?? 'an unknown location';
        $dateFound = $item['date_found'] ?? 'an unknown date';
        $name = $lostReport['full_name'];
        $reportCode = $lostReport['report_code'];
        $email = $lostReport['email'];

        $data = [
            "template_params" => [
                "body" => "Hi $name,\n\n" .
                    "A possible match was found for your lost report: $itemTitle, found at $locationFound on $dateFound.\n" .
                    "This is not confirmed. To view details, use your lost report code: $reportCode.\n\n",
                "email" => $email
            ]
        ];

        return $this->emailJSClient->sendEmail($data);
    }

    public function sendEmailLostReportCreation(array $lostReport): array {
        $name = $lostReport['full_name'];
        $email = $lostReport['email'];
        $reportCode = $lostReport['report_code'];

        $data = [
            "template_params" => [
                "body" => "Hi $name,\n\n" .
                    "Your lost report has been created successfully.\n" .
                    "Please keep your report code, $reportCode, safe and your email notifications enabled. PUP-SPOT will notify you if a potential match is found for your reported item.\n\n",
                "email" => $email
            ]
        ];

        return $this->emailJSClient->sendEmail($data);
    }

    public function sendEmailLostReportCancellation(array $lostReport): array {
        $name = $lostReport['full_name'];
        $email = $lostReport['email'];
        $reportCode = $lostReport['report_code'];

        $data = [
            "template_params" => [
                "body" => "Hi $name,\n\n" .
                    "Your lost report $reportCode has been cancelled.\n",
                "email" => $email
            ]
        ];

        return $this->emailJSClient->sendEmail($data);
    }

    public function sendEmailClaimCreation(array $claim): array {
        $name = $claim['full_name'];
        $email = $claim['email'];
        $claimCode = $claim['claim_code'];

        $data = [
            "template_params" => [
                "body" => "Hi $name,\n\n" .
                    "Your claim has been submitted successfully. Please wait for the Lost and Found Office to review and approve your claim. You will be notified once its status is updated. You can view your claim status at any time using your claim reference code, $claimCode.\n\n",
                "email" => $email
            ]
        ];

        return $this->emailJSClient->sendEmail($data);
    }

    public function sendEmailClaimApproval(array $claim): array {
        $name = $claim['full_name'];
        $email = $claim['email'];
        $claimCode = $claim['claim_code'];

        $data = [
            "template_params" => [
                "body" => "Hi $name,\n\n" .
                    "Your claim has been approved! Please visit the office to claim your item. Use your claim reference code, $claimCode, to view your claim receipt in PUP-SPOT, then take a screenshot and present it to the office for verification.\n\n",
                "email" => $email
            ]
        ];

        return $this->emailJSClient->sendEmail($data);
    }

    public function sendEmailClaimRejection(array $claim): array {
        $name = $claim['full_name'];
        $email = $claim['email'];
        $claimCode = $claim['claim_code'];

        $data = [
            "template_params" => [
                "body" => "Hi $name,\n\n" .
                    "Your claim $claimCode has been rejected. Please contact the Lost and Found Office for more information.\n\n",
                "email" => $email
            ]
        ];

        return $this->emailJSClient->sendEmail($data);
    }
}