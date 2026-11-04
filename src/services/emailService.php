<?php

class EmailService {
    private EmailJSClient $emailJSClient;

    public function __construct() {
        $this->emailJSClient = new EmailJSClient();
    }

    public function sendEmail(array $lostReport, array $item): array {
        $env = parse_ini_file(__DIR__ . '/../../.env');

        $template_id = $env['EMAILJS_POTENTIAL_MATCH_NOTIFICATION_TEMPLATE_ID'];
        
        $itemTitle = $item['title'];
        $locationFound = $item['location_found'] ?? 'an unknown location';
        $dateFound = $item['date_found'] ?? 'an unknown date';
        $name = $lostReport['full_name'];
        $reportCode = $lostReport['report_code'];
        $email = $lostReport['email'];

        $data = [
            "template_params" => [
                "full_name" => $name,
                "report_code" => $reportCode,
                "item_title" => $itemTitle,
                "location_found" => $locationFound,
                "date_found" => $dateFound,
                "email" => $email
            ]
        ];

        return $this->emailJSClient->sendEmail($template_id, $data);
    }
}