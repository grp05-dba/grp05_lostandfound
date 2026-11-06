-- Run as postgres, connected to ojt_managementdb, after creating the schema.
BEGIN;
ALTER DATABASE ojt_managementdb OWNER TO grp03_ojt_admin_grp;
SET ROLE grp03_ojt_admin_grp;
REVOKE ALL ON DATABASE ojt_managementdb FROM PUBLIC;
GRANT CONNECT ON DATABASE ojt_managementdb TO grp03_ojt_runtime_grp, grp03_ojt_readonly_grp;
REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO grp03_ojt_runtime_grp, grp03_ojt_readonly_grp;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public FROM PUBLIC;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO grp03_ojt_runtime_grp;
GRANT INSERT ON users, students, academic_supervisors, company_supervisors,
 companies, requirements, ojt_applications, student_requirements,
 ojt_placements, attendance, evaluations TO grp03_ojt_runtime_grp;
GRANT UPDATE (is_active, updated_at) ON users TO grp03_ojt_runtime_grp;
GRANT UPDATE (status, remarks) ON ojt_applications TO grp03_ojt_runtime_grp;
GRANT UPDATE (file_path, status, submission_date, remarks, verified_by_sup_id, verified_at)
 ON student_requirements TO grp03_ojt_runtime_grp;
GRANT UPDATE (status) ON ojt_placements TO grp03_ojt_runtime_grp;
GRANT UPDATE (is_verified) ON attendance TO grp03_ojt_runtime_grp;
GRANT USAGE ON SEQUENCE users_user_id_seq, students_student_id_seq,
 academic_supervisors_academic_sup_id_seq, company_supervisors_company_sup_id_seq,
 companies_company_id_seq, requirements_req_id_seq, ojt_applications_application_id_seq,
 student_requirements_student_req_id_seq, ojt_placements_placement_id_seq,
 attendance_attendance_id_seq, evaluations_evaluation_id_seq TO grp03_ojt_runtime_grp;
GRANT SELECT ON students, academic_supervisors, company_supervisors, companies,
 requirements, ojt_applications, student_requirements, ojt_placements, attendance,
 evaluations TO grp03_ojt_readonly_grp;
GRANT SELECT (user_id, username, role, is_active, created_at, updated_at, deleted_at)
 ON users TO grp03_ojt_readonly_grp;
GRANT SELECT (audit_id, table_name, action, row_id, action_time)
 ON audit_log TO grp03_ojt_readonly_grp;
-- No blanket privileges for future tables/sequences. Review each migration.
-- Function EXECUTE is public by default, so restrict it for the migration owner.
ALTER DEFAULT PRIVILEGES FOR ROLE grp03_ojt_admin_grp REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;
RESET ROLE;
COMMIT;
