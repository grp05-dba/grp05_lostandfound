<?php

class LostReport {
    private string $report_code;
    private int $category_id;
    private string $title;
    private string $description;
    private ?string $location_lost;
    private ?string $date_lost;
    private ?string $time_lost;
    private string $full_name;
    private string $student_number;
    private ?string $email;
    private ?string $phone_number;
    private string $contact_preference;
    private string $status; //automatically set to "active" when an item is created by POSTGRESQL
    //photos

    public function __construct(
        string $report_code,
        int $category_id,
        string $title,
        string $description,
        ?string $location_lost,
        ?string $date_lost,
        ?string $time_lost,
        string $full_name,
        string $student_number,
        ?string $email,
        ?string $phone_number,
        string $contact_preference = 'email'
    ) {
        $this->report_code = $report_code;
        $this->category_id = $category_id;
        $this->title = $title;
        $this->description = $description;
        $this->location_lost = $location_lost;
        $this->date_lost = $date_lost;
        $this->time_lost = $time_lost;
        $this->full_name = $full_name;
        $this->student_number = $student_number;
        $this->email = $email;
        $this->phone_number = $phone_number;
        $this->contact_preference = $contact_preference;
    }

    public function getReportCode(): string {
        return $this->report_code;
    }

    public function getCategoryId(): int {
        return $this->category_id;
    }

    public function getTitle(): string {
        return $this->title;
    }

    public function getDescription(): string {
        return $this->description;
    }

    public function getLocationLost(): ?string {
        return $this->location_lost;
    }

    public function getDateLost(): ?string {
        return $this->date_lost;
    }

    public function getTimeLost(): ?string {
        return $this->time_lost;
    }

    public function getFullName(): string {
        return $this->full_name;
    }

    public function getStudentNumber(): string {
        return $this->student_number;
    }

    public function getEmail(): ?string {
        return $this->email;
    }

    public function getPhoneNumber(): ?string {
        return $this->phone_number;
    }

    public function getContactPreference(): string {
        return $this->contact_preference;
    }

    public function getStatus(): string {
        return $this->status;
    }
}