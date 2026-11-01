<?php

class Claim {
    private string $claim_code;
    private int $item_id;
    private string $full_name;
    private string $student_number;
    private string $email;
    private string $phone_number;
    private string $status; //automatically set to "pending" when an item is created by POSTGRESQL
    //photos

    public function __construct(
        string $claim_code,
        int $item_id,
        string $full_name,
        string $student_number,
        string $email,
        string $phone_number,
    ) {
        $this->claim_code = $claim_code;
        $this->item_id = $item_id;
        $this->full_name = $full_name;
        $this->student_number = $student_number;
        $this->email = $email;
        $this->phone_number = $phone_number;
    }

    public function getClaimCode(): string {
        return $this->claim_code;
    }

    public function getItemId(): int {
        return $this->item_id;
    }

    public function getFullName(): string {
        return $this->full_name;
    }

    public function getStudentNumber(): string {
        return $this->student_number;
    }

    public function getEmail(): string {
        return $this->email;
    }

    public function getPhoneNumber(): string {
        return $this->phone_number;
    }

    public function getStatus(): string {
        return $this->status;
    }
}