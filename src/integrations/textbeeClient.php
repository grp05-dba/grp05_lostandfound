<?php

class TextBeeClient {
    private array $env;

    public function __construct() {
        $env = parse_ini_file(__DIR__ . '/../../.env');
        $this->env = is_array($env) ? $env : [];
    }

    private function request(string $method, string $endpoint, ?array $data = null): array {
        $apiKey = $this->env['TEXTBEE_API_KEY'] ?? '';
        $baseUrl = rtrim($this->env['TEXTBEE_BASE_URL'] ?? 'https://api.textbee.dev/api/v1', '/');
        if ($apiKey === '') return ['success' => false, 'status' => 0, 'message' => 'TextBee is not configured.'];

        $ch = curl_init($baseUrl . $endpoint);
        $options = [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_HTTPHEADER => ['x-api-key: ' . $apiKey, 'Content-Type: application/json'],
            CURLOPT_CUSTOMREQUEST => $method,
            CURLOPT_TIMEOUT => 10,
        ];
        if ($data !== null) $options[CURLOPT_POSTFIELDS] = json_encode($data);
        curl_setopt_array($ch, $options);
        $response = curl_exec($ch);
        $httpCode = (int) curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $error = curl_error($ch);
        curl_close($ch);

        if ($response === false) return ['success' => false, 'status' => 0, 'message' => $error ?: 'Unable to connect to TextBee.'];
        $decoded = json_decode($response, true);
        return ['success' => $httpCode >= 200 && $httpCode < 300, 'status' => $httpCode, 'response' => $decoded ?? $response];
    }

    public function getGatewayStats(): array { return $this->request('GET', '/gateway/stats'); }
    public function getGatewayDevices(): array { return $this->request('GET', '/gateway/devices'); }

    public function sendSMS(string $phoneNumber, string $message): array {
        return $this->request('POST', '/gateway/send-sms', ['recipients' => [$phoneNumber], 'message' => $message]);
    }
}
