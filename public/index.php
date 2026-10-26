<?php

require_once __DIR__ . '/../src/db/db.php';

$connect = Connection::getConnection();

if ($connect) {
    echo "Database connection successful!";
}
else{
    echo "Database connection failed!";
}
?>