<?php

class Item {
    private int $category_id;
    private string $title;
    private string $description;
    private string $location_found;
    private string $date_found; //could be stored as a DateTime object instead of a string
    private string $time_found; //could be stored as a DateTime object instead of a string
    private string $status; //automatically set to "unclaimed" when an item is created by POSTGRESQL
    //photo

    public function __construct(
        int $category_id,
        string $title,
        string $description,
        string $location_found,
        string $date_found,
        string $time_found,
    ) {
        $this->category_id = $category_id;
        $this->title = $title;
        $this->description = $description;
        $this->location_found = $location_found;
        $this->date_found = $date_found;
        $this->time_found = $time_found;
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

    public function getLocationFound(): string {
        return $this->location_found;
    }

    public function getDateFound(): string {
        return $this->date_found;
    }

    public function getTimeFound(): string {
        return $this->time_found;
    }

    public function getStatus(): string {
        return $this->status;
    }
}