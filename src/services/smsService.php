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
}