\set ON_ERROR_STOP on
-- Target grp07_campussafedb; schema and seed have been loaded as the owner group.
ALTER SCHEMA public OWNER TO campussafe_owner_grp;
REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO campussafe_runtime_grp, campussafe_readonly_grp, campussafe_backup_grp;
GRANT SELECT ON public.role, public.app_user, public.hazard_category,
    public.campus_location, public.hazard_report, public.assignment,
    public.report_status_history, public.maintenance_action, public.attachment
    TO campussafe_runtime_grp, campussafe_backup_grp;
GRANT INSERT ON public.app_user, public.hazard_category, public.campus_location,
    public.hazard_report, public.assignment, public.report_status_history,
    public.maintenance_action, public.attachment TO campussafe_runtime_grp;
GRANT UPDATE ON public.app_user, public.hazard_category, public.campus_location,
    public.hazard_report, public.assignment TO campussafe_runtime_grp;
GRANT DELETE ON public.attachment TO campussafe_runtime_grp;
GRANT USAGE ON SEQUENCE public.app_user_user_id_seq,
    public.hazard_category_category_id_seq, public.campus_location_location_id_seq,
    public.hazard_report_report_id_seq, public.assignment_assignment_id_seq,
    public.report_status_history_history_id_seq, public.maintenance_action_action_id_seq,
    public.attachment_attachment_id_seq TO campussafe_runtime_grp;
-- Auditor may inspect the role dictionary and operational records, not app_user.
GRANT SELECT ON public.role, public.hazard_category, public.campus_location,
    public.hazard_report, public.assignment, public.report_status_history,
    public.maintenance_action, public.attachment TO campussafe_readonly_grp;
-- Backup operator can read sequence states but cannot nextval/setval.
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO campussafe_backup_grp;
ALTER DEFAULT PRIVILEGES FOR ROLE campussafe_owner_grp IN SCHEMA public REVOKE ALL ON TABLES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE campussafe_owner_grp IN SCHEMA public REVOKE ALL ON SEQUENCES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE campussafe_owner_grp REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;
-- New objects require reviewed grants, including for the backup operator.
ALTER ROLE campussafe_app IN DATABASE grp07_campussafedb SET search_path = public;
ALTER ROLE campussafe_app IN DATABASE grp07_campussafedb SET statement_timeout = '30s';
ALTER ROLE campussafe_app IN DATABASE grp07_campussafedb SET lock_timeout = '10s';
