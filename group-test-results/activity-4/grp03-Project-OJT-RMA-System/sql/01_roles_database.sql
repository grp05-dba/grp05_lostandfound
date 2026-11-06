-- Fresh setup only. Run as postgres, connected to postgres.
-- Roles are cluster-wide. Passwords are deliberately absent.
CREATE ROLE grp03_ojt_admin_grp NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE grp03_ojt_runtime_grp NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE grp03_ojt_readonly_grp NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE grp03_ojt_dba LOGIN INHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE grp03_ojt_app LOGIN INHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE grp03_ojt_auditor LOGIN INHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
GRANT grp03_ojt_admin_grp TO grp03_ojt_dba;
GRANT grp03_ojt_runtime_grp TO grp03_ojt_app;
GRANT grp03_ojt_readonly_grp TO grp03_ojt_auditor;
CREATE DATABASE ojt_managementdb OWNER grp03_ojt_admin_grp;
-- Configure credentials locally using psql \password for each login;
-- do not put passwords in this script or command-line arguments.
