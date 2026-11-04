<?php

class Connection
{
    public static function getAdminConnection(): PDO
    {
        try {
            $env = parse_ini_file(__DIR__ . '/../../.env');

            $dbhost = $env['DB_HOST'];
            $dbport = $env['DB_PORT'];
            $dbname = $env['DB_NAME'];
            $dbuser = $env['DB_USER'];
            $dbpass = $env['DB_PASSWORD'];

            $connect = new PDO("pgsql:host=$dbhost;port=$dbport;dbname=$dbname",$dbuser,$dbpass);

            $connect->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);

            return $connect;

        } catch (PDOException $e) {
            error_log($e->getMessage());
            throw $e;
        }
    }

    public static function getPublicConnection(): PDO
    {
        try {
            $env = parse_ini_file(__DIR__ . '/../../.env');

            $dbhost = $env['DB_HOST'];
            $dbport = $env['DB_PORT'];
            $dbname = $env['DB_NAME'];
            $dbuser = $env['DB_PUBLIC_USER'];
            $dbpass = $env['DB_PUBLIC_PASSWORD'];

            $connect = new PDO("pgsql:host=$dbhost;port=$dbport;dbname=$dbname",$dbuser,$dbpass);

            $connect->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);

            return $connect;

        } catch (PDOException $e) {
            error_log($e->getMessage());
            throw $e;
        }
    }
}
