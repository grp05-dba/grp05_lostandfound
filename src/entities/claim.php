<?php

class Claim {
    private string $claimCode;
    private int $itemId;
    private string $fullName;
    private string $studentNumber;
    private string $email;
    private string $phoneNumber;
    private string $status;
    //photos

    public function __construct(
        string $claimCode,
        int $itemId,
        string $fullName,
        string $studentNumber,
        string $email,
        string $phoneNumber,
        string $status
    ) {
        $this->claimCode = $claimCode;
        $this->itemId = $itemId;
        $this->fullName = $fullName;
        $this->studentNumber = $studentNumber;
        $this->email = $email;
        $this->phoneNumber = $phoneNumber;
        $this->status = $status;
    }
}