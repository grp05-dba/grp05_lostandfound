<?php

class LostReport {
    private string $reportCode;
    private int $categoryId;
    private string $title;
    private string $description;
    private string $locationLost; 
    private string $dateLost;
    private string $timeLost;
    private string $fullName;
    private string $studentNumber;
    private string $email;
    private string $phoneNumber;
    private string $status;
    //photos

    public function __construct(
        string $reportCode,
        int $categoryId,
        string $title,
        string $description,
        string $locationLost,
        string $dateLost,
        string $timeLost,
        string $fullName,
        string $studentNumber,
        string $email,
        string $phoneNumber,
        string $status
    ) {
        $this->reportCode = $reportCode;
        $this->categoryId = $categoryId;
        $this->title = $title;
        $this->description = $description;
        $this->locationLost = $locationLost;
        $this->dateLost = $dateLost;
        $this->timeLost = $timeLost;
        $this->fullName = $fullName;
        $this->studentNumber = $studentNumber;
        $this->email = $email;
        $this->phoneNumber = $phoneNumber;
        $this->status = $status;
    }
}