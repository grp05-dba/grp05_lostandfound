<?php

class TextBeeClient{

    private function request(string $method, string $endpoint, ?array $data = null): array {
        $env = parse_ini_file(__DIR__ . '/../../.env');

        $apiKey = $env['TEXTBEE_API_KEY'];
        $baseUrl = $env['TEXTBEE_BASE_URL'];

        $ch = curl_init($baseUrl . $endpoint);

        $headers = [
            'x-api-key: ' . $apiKey,
            'Content-Type: application/json'
        ];

        $options = [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_HTTPHEADER => $headers,
            CURLOPT_CUSTOMREQUEST => $method,
            CURLOPT_TIMEOUT => 10
        ];

        if ($data !== null) {
            $options[CURLOPT_POSTFIELDS] = json_encode($data);
        }

        curl_setopt_array($ch, $options);

        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        
        if ($response === false) {
            return [
                'success' => false,
                'status' => 0,
                'message' => 'Unable to connect to TextBee.'
            ];
        }

        $responseData = json_decode($response, true);
        
        return [
            'success' => $httpCode >= 200 && $httpCode < 300,
            'status' => $httpCode,
            'response' => $responseData ?? $response
        ];
    }

    public function getGatewayStats(): array {
        return $this->request('GET', '/api/v1/gateway/stats');
    }

    public function getGatewayDevices(): array {
        return $this->request('GET', '/api/v1/gateway/devices');
    }
}