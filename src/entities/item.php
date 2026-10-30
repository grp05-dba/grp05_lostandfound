<?php

class Item {
    private int $categoryId;
    private string $title;
    private string $description;
    private string $locationFound;
    private string $dateFound; //could be stored as a DateTime object instead of a string
    private string $timeFound; //could be stored as a DateTime object instead of a string
    private string $status;
    //photo

    public function __construct(
        int $categoryId,
        string $title,
        string $description,
        string $locationFound,
        string $dateFound,
        string $timeFound,
        string $status
    ) {
        $this->categoryId = $categoryId;
        $this->title = $title;
        $this->description = $description;
        $this->locationFound = $locationFound;
        $this->dateFound = $dateFound;
        $this->timeFound = $timeFound;
        $this->status = $status;
    }
}