<?php

class EmailJSClient {
    private array $env;
    public function __construct() {
        $env = parse_ini_file(__DIR__ . '/../../.env');
        $this->env = is_array($env) ? $env : [];
    }

    public function sendEmail(array $templateParams): array {
        foreach (['EMAILJS_SERVICE_ID', 'EMAILJS_TEMPLATE_ID', 'EMAILJS_PUBLIC_KEY'] as $key) {
            if (empty($this->env[$key])) return ['success' => false, 'status' => 0, 'message' => 'EmailJS is not configured.'];
        }
        $payload = [
            'service_id' => $this->env['EMAILJS_SERVICE_ID'],
            'template_id' => $this->env['EMAILJS_TEMPLATE_ID'],
            'user_id' => $this->env['EMAILJS_PUBLIC_KEY'],
            'template_params' => $templateParams,
        ];
        if (!empty($this->env['EMAILJS_PRIVATE_KEY'])) $payload['accessToken'] = $this->env['EMAILJS_PRIVATE_KEY'];
        $baseUrl = rtrim($this->env['EMAILJS_BASE_URL'] ?? 'https://api.emailjs.com/api/v1.0/email', '/');
        $ch = curl_init($baseUrl . '/send');
        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_HTTPHEADER => ['Content-Type: application/json'],
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => json_encode($payload),
            CURLOPT_TIMEOUT => 10,
        ]);
        $response = curl_exec($ch);
        $httpCode = (int) curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $error = curl_error($ch);
        curl_close($ch);
        if ($response === false) return ['success' => false, 'status' => 0, 'message' => $error ?: 'Unable to connect to EmailJS.'];
        return ['success' => $httpCode >= 200 && $httpCode < 300, 'status' => $httpCode, 'response' => $response];
    }
}
