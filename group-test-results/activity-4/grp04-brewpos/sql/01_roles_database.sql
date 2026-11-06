\set ON_ERROR_STOP on
-- Fresh dedicated lab only. Connect as provisioning administrator to postgres.
CREATE ROLE brewpos_owner_grp NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE brewpos_runtime_grp NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE brewpos_readonly_grp NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE brewpos_app LOGIN INHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE brewpos_auditor LOGIN INHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE brewpos_dba LOGIN INHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
GRANT brewpos_runtime_grp TO brewpos_app;
GRANT brewpos_readonly_grp TO brewpos_auditor;
GRANT brewpos_owner_grp TO brewpos_dba;
CREATE DATABASE grp_brewposdb OWNER brewpos_owner_grp;
CREATE DATABASE brewpos_unrelateddb;
REVOKE ALL ON DATABASE grp_brewposdb FROM PUBLIC;
REVOKE ALL ON DATABASE brewpos_unrelateddb FROM PUBLIC;
-- These two revokes are appropriate ONLY in this newly provisioned isolated lab.
-- On a shared server, assess legitimate users and preserve their grants first.
REVOKE CONNECT, TEMPORARY ON DATABASE postgres FROM PUBLIC;
REVOKE CONNECT, TEMPORARY ON DATABASE template1 FROM PUBLIC;
GRANT CONNECT ON DATABASE grp_brewposdb TO brewpos_runtime_grp, brewpos_readonly_grp;
-- Passwords are assigned locally after creation, never stored in these scripts.
