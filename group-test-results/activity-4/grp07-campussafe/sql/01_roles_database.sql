\set ON_ERROR_STOP on
-- Fresh evaluation setup. Connect as provisioning administrator to postgres.
CREATE ROLE campussafe_owner_grp NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE campussafe_runtime_grp NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE campussafe_readonly_grp NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE campussafe_backup_grp NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE campussafe_app LOGIN INHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE campussafe_report LOGIN INHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE campussafe_backup LOGIN INHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE campussafe_dba LOGIN INHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
GRANT campussafe_runtime_grp TO campussafe_app;
GRANT campussafe_readonly_grp TO campussafe_report;
GRANT campussafe_backup_grp TO campussafe_backup;
GRANT campussafe_owner_grp TO campussafe_dba;
CREATE DATABASE grp07_campussafedb OWNER campussafe_owner_grp;
CREATE DATABASE campussafe_unrelateddb;
REVOKE ALL ON DATABASE grp07_campussafedb FROM PUBLIC;
REVOKE ALL ON DATABASE campussafe_unrelateddb FROM PUBLIC;
GRANT CONNECT ON DATABASE grp07_campussafedb TO campussafe_runtime_grp, campussafe_readonly_grp, campussafe_backup_grp;
-- Assign distinct private passwords locally after creation, never in this script.
