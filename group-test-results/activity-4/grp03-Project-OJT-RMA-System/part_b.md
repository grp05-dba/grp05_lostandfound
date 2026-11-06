# Part B – Identify Users, Group Roles, and Privileges

## 1. Objective

Define database access for Group 03's OJT Management System based on the reviewed Java operations and Activity 3 role documentation. The design separates database maintenance, application execution and read-only inspection.

## 2. Application Roles Versus Database Roles

The source supports `ADMIN`, `STUDENT`, `ACADEMIC_SUPERVISOR`, `COMPANY_SUPERVISOR`, and `OJT_COORDINATOR` through `users.role`. `Db.init()` opens a single JDBC connection; `Main.login()` authenticates application users without switching database accounts.

The PDF proposes PostgreSQL logins for each application role, but the Java code does not use those logins. Creating them would not enforce per-student access in this application. Our implementation uses one restricted runtime service account, one auditor account and one project database administrator. Role-specific screens and student/supervisor record scoping remain Java responsibilities; database row-level security is not implemented.

## 3. Access-Control Plan

| Login account | NOLOGIN group role | Application role served | Responsibility | Required access |
|---|---|---|---|---|
| `grp03_ojt_app` | `grp03_ojt_runtime_grp` | All five roles through the JDBC service | Authentication, profiles, company records, applications, submissions, placement, attendance, evaluation and startup seed operations | CONNECT; schema USAGE; SELECT on all 12 tables; INSERT on 11 tables; approved column UPDATE; USAGE on 11 sequences |
| `grp03_ojt_auditor` | `grp03_ojt_readonly_grp` | External inspection; no dedicated auditor UI | Read approved records without altering them | CONNECT; schema USAGE; SELECT on 10 operational/profile tables and approved columns of `users` and `audit_log` |
| `grp03_ojt_dba` | `grp03_ojt_admin_grp` | Database maintenance, separate from application ADMIN | Own/maintain the project database and objects, apply migrations and manage object grants | Database and object ownership through group membership; no cluster-level role/database creation |

All six roles have `NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION NOBYPASSRLS`. Login roles inherit the corresponding group's privileges. No account has membership in the other project groups or membership with ADMIN OPTION. Cluster role provisioning remains with the existing PostgreSQL administrator.

## 4. Runtime Table Privileges

| Table | SELECT | INSERT | UPDATE columns | DELETE |
|---|---|---|---|---|
| `users` | Yes, including hash needed for authentication | Yes | `is_active`, `updated_at` | No |
| `students` | Yes | Yes | None | No |
| `academic_supervisors` | Yes | Yes | None | No |
| `company_supervisors` | Yes | Yes | None | No |
| `companies` | Yes | Yes | None | No |
| `requirements` | Yes | Yes, needed by startup seed | None | No |
| `ojt_applications` | Yes | Yes | `status`, `remarks` | No |
| `student_requirements` | Yes | Yes | `file_path`, `status`, `submission_date`, `remarks`, `verified_by_sup_id`, `verified_at` | No |
| `ojt_placements` | Yes | Yes | `status` | No |
| `attendance` | Yes | Yes | `is_verified` | No |
| `evaluations` | Yes | Yes | None | No |
| `audit_log` | Yes | No | None | No |

The runtime account cannot rewrite stored hours, change an existing user's role, delete audit history, truncate tables or create schema objects. INSERT permissions necessarily allow supplied column values when creating accounts and operational records; these grants alone do not validate the identity or business authority of the application user. The runtime account is a trusted service credential and should not be given directly to students.

## 5. Read-Only Privileges

The auditor can SELECT the ten tables other than `users` and `audit_log`. For those two tables it receives only:

```sql
GRANT SELECT (user_id, username, role, is_active, created_at, updated_at, deleted_at)
ON users TO grp03_ojt_readonly_grp;
GRANT SELECT (audit_id, table_name, action, row_id, action_time)
ON audit_log TO grp03_ojt_readonly_grp;
```

This excludes `users.password_hash`, `users.email`, and `audit_log.details`. Profile and internship records still contain personal information; this account is for an authorized internal auditor, not public reporting. It receives no INSERT, UPDATE, DELETE, TRUNCATE, sequence USAGE or schema CREATE.

## 6. Sequences, Ownership and Defaults

The runtime receives USAGE on the sequence for each of its eleven insertable tables. It receives no access to `audit_log_audit_id_seq`. The auditor receives no sequence privileges. The admin group owns all existing tables/sequences and the database; ownership supports ALTER and grant management, which ordinary `GRANT ALL` on tables would not provide.

PUBLIC receives no privileges on this project's database, public schema or application objects. Runtime and auditor receive CONNECT and schema USAGE only. Future tables and sequences remain private until reviewed. Default PUBLIC EXECUTE on functions is revoked for objects created by the migration owner, `grp03_ojt_admin_grp`. Migrations must use that owner and explicit grants; defaults for other creating roles are not automatically changed.

The unrelated databases' PUBLIC CONNECT grants remain an observed cluster-wide gap, documented in [Part D/E verification](part_d.md). Creating project-specific usernames does not override PUBLIC privileges in those other databases.
