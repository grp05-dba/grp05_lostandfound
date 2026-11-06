\set ON_ERROR_STOP on
-- Fresh, disposable lab cluster only. Run as its provisioning administrator.
-- New logins have no password until set securely using psql \password.
CREATE ROLE canteen_owner_grp NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE canteen_app_grp NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE canteen_readonly_grp NOLOGIN NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE canteen_admin LOGIN NOINHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE canteen_app LOGIN INHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
CREATE ROLE canteen_readonly LOGIN INHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
GRANT canteen_owner_grp TO canteen_admin WITH INHERIT FALSE, SET TRUE, ADMIN FALSE;
GRANT canteen_app_grp TO canteen_app WITH INHERIT TRUE, SET TRUE, ADMIN FALSE;
GRANT canteen_readonly_grp TO canteen_readonly WITH INHERIT TRUE, SET TRUE, ADMIN FALSE;
CREATE DATABASE canteen_g05_activity4 OWNER canteen_owner_grp;
CREATE DATABASE canteen_unrelated_lab;
REVOKE ALL ON DATABASE canteen_g05_activity4 FROM PUBLIC;
GRANT CONNECT ON DATABASE canteen_g05_activity4 TO canteen_admin, canteen_app_grp, canteen_readonly_grp;
-- Load upstream migrations 001 and 002, then seed 001, in the target database
-- under SET ROLE canteen_owner_grp before applying 02_privileges.sql.
