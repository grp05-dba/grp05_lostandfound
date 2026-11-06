-- Implements the documented Database Owner / DBA identity in docs/user-roles.md.
-- Fresh local setup only: the supplied installer does not provision this account.
-- No password literal or cluster provisioning attribute. Ownership is project-scoped.
\set ON_ERROR_STOP on
CREATE ROLE campussafe_owner LOGIN INHERIT NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS;
ALTER DATABASE grp07_campussafedb OWNER TO campussafe_owner;
ALTER TABLE public.role OWNER TO campussafe_owner;
ALTER TABLE public.app_user OWNER TO campussafe_owner;
ALTER TABLE public.hazard_category OWNER TO campussafe_owner;
ALTER TABLE public.campus_location OWNER TO campussafe_owner;
ALTER TABLE public.hazard_report OWNER TO campussafe_owner;
ALTER TABLE public.assignment OWNER TO campussafe_owner;
ALTER TABLE public.report_status_history OWNER TO campussafe_owner;
ALTER TABLE public.maintenance_action OWNER TO campussafe_owner;
ALTER TABLE public.attachment OWNER TO campussafe_owner;
-- Table ownership also controls its owned SERIAL sequence. Verify all owners afterward.
-- Keep migration defaults aligned with the documented owner instead of only postgres.
ALTER DEFAULT PRIVILEGES FOR ROLE campussafe_owner IN SCHEMA public GRANT SELECT, INSERT, UPDATE ON TABLES TO campussafe_runtime_grp;
ALTER DEFAULT PRIVILEGES FOR ROLE campussafe_owner IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO campussafe_runtime_grp;
ALTER DEFAULT PRIVILEGES FOR ROLE campussafe_owner IN SCHEMA public GRANT SELECT ON TABLES TO campussafe_backup_grp;
ALTER DEFAULT PRIVILEGES FOR ROLE campussafe_owner IN SCHEMA public GRANT SELECT ON SEQUENCES TO campussafe_backup_grp;
SELECT c.relname,c.relkind,pg_get_userbyid(c.relowner) AS owner FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname='public' AND c.relkind IN ('r','S') ORDER BY c.relkind,c.relname;
