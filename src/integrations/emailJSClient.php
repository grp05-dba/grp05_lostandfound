<?php

class EmailJSClient {
    private function request(string $method, string $endpoint, string $template_id, ?array $postData = null): array {
        $env = parse_ini_file(__DIR__ . '/../../.env');

        $baseUrl = $env['EMAILJS_BASE_URL'];

        $ch = curl_init($baseUrl . $endpoint);

        $data = [
            'service_id' => $env['EMAILJS_SERVICE_ID'],
            'template_id' => $template_id,
            'user_id' => $env['EMAILJS_PUBLIC_KEY'],
        ];

        if ($postData) {
            $data = array_merge($data, $postData);
        }

        $headers = [
            'Content-Type: application/json'
        ];

        $options = [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_HTTPHEADER => $headers,
            CURLOPT_CUSTOMREQUEST => $method,
            CURLOPT_POSTFIELDS => json_encode($data),
            CURLOPT_TIMEOUT => 10
        ];

        curl_setopt_array($ch, $options);

        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);

        if ($response === false) {
            return [
                'success' => false,
                'status' => 0,
                'message' => 'Unable to connect to EmailJS.'
            ];
        }

        $responseData = json_decode($response, true);

        return [
            'success' => $httpCode >= 200 && $httpCode < 300,
            'status' => $httpCode,
            'response' => $responseData ?? $response
        ];
    }

    public function sendEmail(string $template_id, array $data): array {
        return $this->request('POST', '/api/v1.0/email/send', $template_id, $data);
    }
}