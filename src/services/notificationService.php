<?php

class NotificationService {
    private TextBeeClient $textBeeClient;
    private EmailJSClient $emailJSClient;

    public function __construct() {
        $this->textBeeClient = new TextBeeClient();
        $this->emailJSClient = new EmailJSClient();
    }

    public function notifyPotentialMatch(array $report, array $item): void {
        $name = $report['full_name'] ?? 'there';
        $message = sprintf(
            'Hello %s, a possible match was found for your lost item "%s". Found item: "%s". Please contact the PUP-SPOT team to verify it.',
            $name,
            $report['title'] ?? 'your item',
            $item['title'] ?? 'a found item'
        );

        $preference = strtolower((string) ($report['contact_preference'] ?? 'email'));

        try {
            if ($preference === 'sms' && !empty($report['phone_number'])) {
                $result = $this->textBeeClient->sendSMS(
                    $this->toInternationalPhone((string) $report['phone_number']),
                    $message
                );
            } else {
                $result = $this->emailJSClient->sendEmail([
                    'to_email' => $report['email'] ?? '',
                    'to_name' => $name,
                    'subject' => 'Possible match for your lost item',
                    'message' => $message,
                    'lost_item' => $report['title'] ?? '',
                    'found_item' => $item['title'] ?? '',
                ]);
            }

            if (empty($result['success'])) {
                error_log('Potential-match notification failed: ' . json_encode($result));
            }
        } catch (Throwable $e) {
            error_log('Potential-match notification error: ' . $e->getMessage());
        }
    }

    private function toInternationalPhone(string $phone): string {
        $phone = preg_replace('/[\s()\-]/', '', $phone) ?? '';
        if (str_starts_with($phone, '09')) {
            return '+63' . substr($phone, 1);
        }
        if (str_starts_with($phone, '9') && strlen($phone) === 10) {
            return '+63' . $phone;
        }
        return $phone;
    }
}
