\set ON_ERROR_STOP on
-- Fresh isolated lab only; connect as the provisioning administrator to postgres.
CREATE ROLE parkit_owner_grp NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE parkit_runtime_grp NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE parkit_readonly_grp NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE parkit_app LOGIN INHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE parkit_auditor LOGIN INHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE parkit_dba LOGIN INHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
GRANT parkit_runtime_grp TO parkit_app;
GRANT parkit_readonly_grp TO parkit_auditor;
GRANT parkit_owner_grp TO parkit_dba;
CREATE DATABASE grp_parkitdb OWNER parkit_owner_grp;
CREATE DATABASE parkit_unrelateddb;
REVOKE ALL ON DATABASE grp_parkitdb FROM PUBLIC;
REVOKE ALL ON DATABASE parkit_unrelateddb FROM PUBLIC;
-- Only safe without further review in this new, dedicated lab cluster.
REVOKE CONNECT, TEMPORARY ON DATABASE postgres FROM PUBLIC;
REVOKE CONNECT, TEMPORARY ON DATABASE template1 FROM PUBLIC;
GRANT CONNECT ON DATABASE grp_parkitdb TO parkit_runtime_grp, parkit_readonly_grp;
-- Assign private passwords separately with psql \password; none are stored here.
