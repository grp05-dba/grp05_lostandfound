\set ON_ERROR_STOP on
-- Fresh project setup in the isolated evaluation cluster; connect to postgres.
CREATE ROLE habalgo_owner_grp NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE habalgo_runtime_grp NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE habalgo_readonly_grp NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE habalgo_app LOGIN INHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE habalgo_auditor LOGIN INHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE habalgo_dba LOGIN INHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
GRANT habalgo_runtime_grp TO habalgo_app;
GRANT habalgo_readonly_grp TO habalgo_auditor;
GRANT habalgo_owner_grp TO habalgo_dba;
CREATE DATABASE grp00_habalgodb OWNER habalgo_owner_grp;
CREATE DATABASE habalgo_unrelateddb;
REVOKE ALL ON DATABASE grp00_habalgodb FROM PUBLIC;
REVOKE ALL ON DATABASE habalgo_unrelateddb FROM PUBLIC;
GRANT CONNECT ON DATABASE grp00_habalgodb TO habalgo_runtime_grp, habalgo_readonly_grp;
-- Set distinct private passwords locally; no passwords are stored in this script.
-- Other databases require their own CONNECT review; see 03_lab_isolation.sql.
