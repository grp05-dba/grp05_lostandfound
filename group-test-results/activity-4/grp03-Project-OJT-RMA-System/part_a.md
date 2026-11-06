# Part A – Database Setup and Assessment

## 1. Objective

Set up and assess Group 03's OJT Management System for COMP 018 Activity 4. Identify its database objects, application operations and access requirements before applying PostgreSQL roles and least privilege.

## 2. Project Information

| Item | Details |
|---|---|
| Project | Group 03 – OJT Management System / Project-OJT-RMA-System |
| Repository | https://github.com/swvenz/Project-OJT-RMA-System |
| Branch | `main` |
| Reviewed commit | `6a899fbc5882c2916be0af3a91457b1c0c54084b` |
| Source verification | Local checkout matched `origin/main` after a successful fetch on 6 November 2026 |
| Application | Java Swing with JDBC; Java 21 used locally |
| Database | PostgreSQL 18.6; database `ojt_managementdb`; schema `public` |
| JDBC driver used | PostgreSQL JDBC 42.7.13, already available locally |
| Review date | 6 November 2026 |

The owning group's README, `database/postgresql query.pdf`, and all four Java source files in `system/` were reviewed. The cloned source is outside this results folder; the owning group's repository was not modified.

## 3. Documented Setup and Actual Findings

The README says to create `ojt_managementdb`, configure `.env`, execute migration and seed scripts, and start the application. However, it does not provide a complete Java build/run command or identify separate migration and seed files.

| Finding | Local resolution / implication |
|---|---|
| `database/OJT Database.sql` begins with `PGDMP`; it is a custom-format PostgreSQL archive, not executable SQL | Inspected using `pg_restore --schema-only --no-owner --no-acl`. It contains database `Demo`, schema `lending`, and tables `customers` and `loans`. It was **not** restored into the OJT database. |
| OJT DDL is inside `database/postgresql query.pdf` | Extracted the table definitions into [02_schema.sql](sql/02_schema.sql). |
| An extra `);` follows `ojt_applications` | Removed that duplicate closing statement in our local adaptation. PDF extraction page breaks and an invisible character were also removed. |
| Java inserts columns missing from the PDF | Added nullable `employee_number`, `department`, `contact_number` to `academic_supervisors`, and `department` to `company_supervisors`, matching `Db.createUser()`. These are documented local compatibility additions. |
| PDF grants refer to `ojt_management`, while README names `ojt_managementdb` | Used the README database name consistently. |
| Java actually reads classpath `/db.properties`, not `.env` | Local runtime configuration uses `grp03_ojt_app` and `ojt_managementdb`; the credential-bearing configuration is excluded from these results. |
| Java calls `Db.seed()` during startup | Existing demo data was verified; the Java startup and all five demo logins were tested. Demo credentials are not reproduced here. |

**Setup result: Success with issues.** An initialized local database and the grp03 roles already existed when this run began. They were inspected and reused without dropping or recreating existing objects. This run reapplied the documented privilege script, independently replayed the corrected schema inside a temporary schema and rolled it back, compiled the unchanged Java sources, and verified JDBC startup and all five application roles. Full interactive workflows were not tested.

## 4. Reproducible Database Setup

For a **fresh** PostgreSQL environment, run from this project results folder:

```sh
psql -X -U postgres -d postgres -v ON_ERROR_STOP=1 -f sql/01_roles_database.sql
psql -X -U postgres -d ojt_managementdb -v ON_ERROR_STOP=1 -c 'SET ROLE grp03_ojt_admin_grp' -f sql/02_schema.sql
psql -X -U postgres -d ojt_managementdb -v ON_ERROR_STOP=1 -f sql/03_privileges.sql
```

The first two scripts are fresh-install scripts; do not run them blindly against the existing database. Objects are created as `grp03_ojt_admin_grp` so that the runtime login owns no tables or sequences. Configure passwords locally with psql's `\password grp03_ojt_app`, `\password grp03_ojt_auditor`, and `\password grp03_ojt_dba` when password authentication is required. No real passwords are stored in these scripts.

Compile `system/*.java` with Java 21 into a local classes directory. Put a private `db.properties` in that directory containing `url=jdbc:postgresql://localhost:5432/ojt_managementdb`, `user=grp03_ojt_app`, and a locally configured password. Add the PostgreSQL JDBC JAR to the runtime classpath and launch `ojt.Main`. Startup invokes the source's demo seed routine; use only a local test environment for that demonstration data. The headless verification harness is [Smoke.java](verification/Smoke.java); it requires `OJT_DEMO_PASSWORD` in the local environment and does not print it.

## 5. Database Objects

The verified `public` schema contains **12 tables and 12 SERIAL sequences**, with no application views, functions or user-defined triggers. Catalog evidence: [catalog.txt](evidence/catalog.txt).

| Table | Purpose | Generated identifier / sequence |
|---|---|---|
| `users` | Application authentication, role and activation status | `user_id` / `users_user_id_seq` |
| `audit_log` | Intended history of record changes | `audit_id` / `audit_log_audit_id_seq` |
| `students` | Student profiles | `student_id` / `students_student_id_seq` |
| `companies` | Company and partnership information | `company_id` / `companies_company_id_seq` |
| `academic_supervisors` | Academic adviser profiles | `academic_sup_id` / `academic_supervisors_academic_sup_id_seq` |
| `company_supervisors` | Company mentor profiles | `company_sup_id` / `company_supervisors_company_sup_id_seq` |
| `requirements` | Requirement definitions | `req_id` / `requirements_req_id_seq` |
| `ojt_applications` | Student applications and decisions | `application_id` / `ojt_applications_application_id_seq` |
| `student_requirements` | Submissions, review and verification | `student_req_id` / `student_requirements_student_req_id_seq` |
| `ojt_placements` | Internship assignments and completion | `placement_id` / `ojt_placements_placement_id_seq` |
| `attendance` | Hours worked and verification | `attendance_id` / `attendance_attendance_id_seq` |
| `evaluations` | Mentor scores and feedback | `evaluation_id` / `evaluations_evaluation_id_seq` |

Profiles reference `users`; company supervisors reference `companies`. Applications reference students and companies. Placements use a composite foreign key `(application_id, student_id, company_id)` to enforce consistency with the application and reference both supervisors. Submissions reference students, requirement definitions and an optional verifying academic supervisor. Attendance and evaluations reference placements; evaluations also reference company supervisors.

Constraints include unique usernames/emails, student numbers, company names, one profile per user, one placement per application, one submission per student/requirement, and one attendance record per placement/date. CHECK constraints restrict roles/statuses, require positive year levels and required hours, nonnegative attendance hours, valid date/time ordering, and scores from 0 to 100.

## 6. Operations and Application Roles

| Application component / role | Actual database use |
|---|---|
| Login | SELECT `users` and the appropriate profile; PBKDF2 verification in Java |
| ADMIN | Read/create accounts and profiles; update account activation; read audit metadata |
| STUDENT | Read partner companies; create applications; insert/update submissions; record attendance; read own placements/evaluations |
| ACADEMIC_SUPERVISOR | Review submissions; verify attendance; mark qualifying placements completed; read related records |
| COMPANY_SUPERVISOR | Read assigned interns; insert evaluations; verify attendance |
| OJT_COORDINATOR | Read/review applications; insert companies and placements; update application decisions |
| Startup seeding | Read/insert requirements, companies, users and profiles |

`users.role` controls Java screens and query filtering. All these users share the one JDBC connection. Application roles do **not** automatically become separate PostgreSQL sessions. The database runtime role therefore needs the union of these operations, with column-level UPDATE restrictions. Java uses no normal hard DELETE operation.

`Db.createUser()` wraps account/profile creation in a transaction. Application approval creates a placement and then updates the application in separate calls; that operation is not wrapped in one transaction. No automatic audit trigger or application audit INSERT was found; an audit table alone does not establish working change logging.

## 7. Setup Evidence and Remaining Work

[Schema replay](evidence/schema-replay.txt) shows twelve successful CREATE TABLE statements and both compatibility ALTER TABLE statements, followed by ROLLBACK. [Catalog inspection](evidence/catalog.txt) confirms the real database objects and counts: 5 users, 1 student, 1 company and 3 requirements; workflow tables and audit log were empty after rollback tests. [Java smoke output](evidence/java-smoke.txt) confirms runtime JDBC access and successful authentication/tab queries for all five application roles.

Cross-database connection restrictions remain incomplete; see [verification report](part_d.md). Feedback on the archive, setup gaps, schema mismatches, default demo accounts, transaction handling and missing audit logging is prepared in these findings but has **not been sent** to the owners. This folder supplies the requested Markdown reports, SQL scripts and output evidence; tracker updates, owner messages, commits and a compiled submission PDF have not been performed.
