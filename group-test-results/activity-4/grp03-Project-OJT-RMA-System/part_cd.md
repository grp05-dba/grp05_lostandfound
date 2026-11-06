# Part C and Part D – Roles, Privileges, and Least Privilege

## 1. Implementation Scope

The access plan in [Part B](part_b.md) is implemented for `ojt_managementdb`. The database and roles already existed when this run began. Their definitions, ownership and memberships were verified; [03_privileges.sql](sql/03_privileges.sql) was executed successfully on 6 November 2026. [Implementation output](evidence/privilege-implementation.txt) records the successful grants and restrictions. The role creation script below reproduces their configuration in a fresh environment; it was not rerun to create duplicate roles.

## 2. Group Roles, Login Roles and Database

Execute [01_roles_database.sql](sql/01_roles_database.sql) as the cluster administrator while connected to `postgres`, only on a fresh installation:

```sql
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

```

Passwords are intentionally absent. Use local credential configuration and psql's interactive `\password` command when password authentication is required. Never add actual credentials to these reports or SQL files.

Load [02_schema.sql](sql/02_schema.sql) into `ojt_managementdb` with `SET ROLE grp03_ojt_admin_grp` first. This makes the admin group the owner of application objects. Existing local objects were verified to have this ownership.

## 3. Database, Schema, Table, Column and Sequence Privileges

Run the following [03_privileges.sql](sql/03_privileges.sql) as `postgres` while connected to `ojt_managementdb`:

```sql
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

```

These grants describe the current reviewed schema. This is a repeatable grant script for that configuration, not a universal cleanup script for arbitrary pre-existing grants. The actual catalog was checked for unexpected direct grants, inherited memberships, PUBLIC privileges and ownership; see [catalog evidence](evidence/catalog.txt).

## 4. Least Privilege Review

| Activity 4 requirement | Implemented control | Verified outcome |
|---|---|---|
| Ordinary application access uses no superuser | JDBC uses `grp03_ojt_app`, inheriting only the runtime group | Java smoke test confirmed the actual JDBC current user |
| Project accounts do not access unrelated databases | PUBLIC privileges removed on `ojt_managementdb`; no unrelated grants assigned by our scripts | **Incomplete:** other databases still grant PUBLIC CONNECT; all three logins connected to `grp_parkitdb` |
| Restrict modifications to assigned responsibilities | Runtime INSERT only on required tables; UPDATE only on columns used by Java; no DELETE or TRUNCATE | Actual permitted inserts/updates succeeded; tested forbidden operations returned SQLSTATE `42501` |
| Read-only users cannot write | Auditor has only SELECT grants | INSERT, UPDATE and DELETE attempts returned `42501` |
| Avoid unnecessary elevated attributes | All six roles lack SUPERUSER, CREATEDB, CREATEROLE, REPLICATION and BYPASSRLS | Catalog confirmed; all three logins were denied CREATE DATABASE and CREATE ROLE |
| Review PUBLIC and inherited access | PUBLIC revoked on project resources; one intended group per login; runtime owns no objects | Catalog and denied SET ROLE tests confirmed the reviewed configuration |
| Account for future objects | No blanket future data grants; migration owner's PUBLIC function execution revoked | Future table, sequence and function checks all returned false for runtime |

`grp03_ojt_dba` is a project administrator through ownership. It can maintain project objects but cannot provision cluster roles; use the separate cluster administrator for that task. For consistent future ownership and default privileges, execute migrations after `SET ROLE grp03_ojt_admin_grp`. Creating directly as the DBA login would use that login's ownership/defaults instead.

## 5. Unresolved Isolation and Application Limits

Revoking CONNECT from an individual account cannot override CONNECT granted to PUBLIC. To finish the cross-database requirement, the cluster administrator must inventory legitimate users on each unrelated database, explicitly preserve their access, then revoke PUBLIC CONNECT there; alternatively use a separate PostgreSQL cluster or appropriate per-account database restrictions in `pg_hba.conf`. No unreviewed changes were made to the other projects' database access or server authentication configuration.

No row-level security policies exist. The database runtime account can read all users and insert records on behalf of the application's five roles. Per-student/per-supervisor visibility and action authorization depend on Java. Column grants narrow the service's authority but do not enforce individual user identities. Existing hardcoded demo seeding should be removed or gated before deployment, and automatic audit recording needs an owning-group implementation.

**Status: privileges tested, with an unresolved cross-database isolation issue.** This configuration must not be marked fully completed for Activity 4. See [part_d.md](part_d.md) for actual permitted/denied results.
