# Part A - Database Setup and Assessment

## 1. Objective and scope

Set up Group 7's CampusSafe database and application, inventory database objects and operations, and prepare a least-privilege access plan for Activity 4. Group 2's files provide the report structure; findings are based on CampusSafe's reviewed source and actual local execution.

Reviewed/tested **6 November 2026 (Asia/Manila)**. These four requested Markdown files cover assessment, role planning, implementation/least privilege and verification. The requested `part_d.md` contains the PDF assignment's **Part E** verification; its Part D is included in [part_cd.md](part_cd.md).

| Item | Verified detail |
|---|---|
| Project | CampusSafe: Campus Hazard & Safety Reporting System, Group 7 |
| Repository | [https://github.com/jeffersonorpesa2-ops/grp07-campussafe](https://github.com/jeffersonorpesa2-ops/grp07-campussafe) |
| Branch | `main` |
| Reviewed commit | `3684b97cfa8b8c6624d039eda461551ade774701` |
| Database / schema | `grp07_campussafedb` / `public` |
| Tables / SERIAL sequences / indexes | 9 / 9 / 24 |
| Evaluated platform | PostgreSQL 18.6, psql, Windows x64 |
| Database endpoint | `127.0.0.1:55432`, isolated evaluation cluster |
| PHP | 8.2.12 with PDO_PGSQL |
| HTTP endpoint | `http://127.0.0.1:18083`, PHP development server bound to loopback |
| Runtime login | `campussafe_app`, non-superuser |
| Setup result | **Success with issues**: database and lifecycle workflow work; web authorization findings remain |

The existing Group 4 and Group 6 databases remain separate in the evaluation cluster. The user's PostgreSQL service on port 5432 was not changed.

## 2. Reviewed sources

- [README/manual installation](https://github.com/jeffersonorpesa2-ops/grp07-campussafe/blob/3684b97cfa8b8c6624d039eda461551ade774701/README.md), [database dictionary](https://github.com/jeffersonorpesa2-ops/grp07-campussafe/blob/3684b97cfa8b8c6624d039eda461551ade774701/docs/database.md) and [ERD](https://github.com/jeffersonorpesa2-ops/grp07-campussafe/blob/3684b97cfa8b8c6624d039eda461551ade774701/docs/erd.md).
- [Application-user/database-role mapping](https://github.com/jeffersonorpesa2-ops/grp07-campussafe/blob/3684b97cfa8b8c6624d039eda461551ade774701/docs/user-roles.md) and [database role setup guide](https://github.com/jeffersonorpesa2-ops/grp07-campussafe/blob/3684b97cfa8b8c6624d039eda461551ade774701/docs/db-user-role-setup.md).
- [Schema](https://github.com/jeffersonorpesa2-ops/grp07-campussafe/blob/3684b97cfa8b8c6624d039eda461551ade774701/database/01_schema.sql), [seed](https://github.com/jeffersonorpesa2-ops/grp07-campussafe/blob/3684b97cfa8b8c6624d039eda461551ade774701/database/02_seed.sql), [existing privilege script](https://github.com/jeffersonorpesa2-ops/grp07-campussafe/blob/3684b97cfa8b8c6624d039eda461551ade774701/database/03_roles_and_privileges.sql) and [sanity queries](https://github.com/jeffersonorpesa2-ops/grp07-campussafe/blob/3684b97cfa8b8c6624d039eda461551ade774701/database/verify.sql).
- [Database connection](https://github.com/jeffersonorpesa2-ops/grp07-campussafe/blob/3684b97cfa8b8c6624d039eda461551ade774701/src/config/Database.php), [environment loader](https://github.com/jeffersonorpesa2-ops/grp07-campussafe/blob/3684b97cfa8b8c6624d039eda461551ade774701/src/config/Env.php), [authentication](https://github.com/jeffersonorpesa2-ops/grp07-campussafe/blob/3684b97cfa8b8c6624d039eda461551ade774701/src/auth/Auth.php), CSRF implementation, models and public controllers.
- [Activity 3 progress PDF](https://github.com/jeffersonorpesa2-ops/grp07-campussafe/blob/3684b97cfa8b8c6624d039eda461551ade774701/progress-report/ACTIVITY_03_PROGRESS_REPORT.pdf) and its Markdown companion, particularly the system scope and application-role mapping. The PDF has eight pages.

The Activity 4 instructions are in the parent evaluation folder's assignment PDF. The owning project's progress claims were treated as context, not proof; permissions and web guards were tested independently.

## 3. Executed setup

The documented manual procedure creates the database and executes schema, seed and role SQL in order. The upstream schema contains DROP statements and the seed TRUNCATEs all nine tables. Therefore they were executed **only after creating a new database and confirming it contained zero public tables**. No reset script was run against an existing project database.

Steps performed:

1. Run [01_roles_database.sql](sql/01_roles_database.sql) to create project-specific NOLOGIN groups, four login roles, the project database and an unrelated test database.
2. Apply [03_lab_isolation.sql](sql/03_lab_isolation.sql) only in the owned evaluation cluster, preserving existing explicit access grants.
3. Connect to the fresh project database, use `SET ROLE campussafe_owner_grp`, set search_path to public, and load upstream `01_schema.sql` and `02_seed.sql` unchanged.
4. Apply [02_privileges.sql](sql/02_privileges.sql) instead of the broader upstream role script.
5. Assign random local passwords privately and write an ignored local `.env` in the scratch source checkout selecting `campussafe_app` and port 55432.
6. Start PHP with `public/` as document root and workspace-local session storage; test TCP logins, HTTP sessions, lifecycle operations and authorization.

Seed SQL echo was disabled because it contains demo credential values and password hashes. [Setup output](evidence/setup.txt) records source SHA-256 fingerprints, command results and the empty-database guard without reproducing those secrets. No credentials or hashes are included in the submitted reports/evidence.

Application startup and the full Submitted -> Verified -> Assigned -> In Progress -> Resolved -> Closed workflow succeeded. [Runtime identity](evidence/application_runtime.txt) confirms the local PHP connection uses `campussafe_app`. [HTTP evidence](evidence/application_validation.txt) records controls and failures separately, without cookies, passwords, CSRF tokens or HTML bodies.

## 4. Inventory and seeded baseline

| Table | Purpose | Primary key | Rows after cleanup |
|---|---|---|---:|
| `role` | Five application role definitions | `role_id` | 5 |
| `app_user` | Profiles, account status and password hashes | `user_id` | 6 |
| `hazard_category` | Hazard classifications and active flag | `category_id` | 6 |
| `campus_location` | Building/floor/room master data | `location_id` | 10 |
| `hazard_report` | Reporter, category, location and lifecycle state | `report_id` | 16 |
| `assignment` | Technician dispatch and work state | `assignment_id` | 12 |
| `report_status_history` | Status-transition records | `history_id` | 60 |
| `maintenance_action` | Repair/action records | `action_id` | 9 |
| `attachment` | Evidence-file metadata | `attachment_id` | 5 |

All tables use SERIAL IDs, producing nine sequences. Twenty-four indexes consist of nine primary-key indexes, five unique-constraint indexes and ten explicit lookup/filter indexes. No application-defined view, materialized view, function, procedure or trigger is imported by the schema. Temporary future-object probes were removed.

Fourteen foreign keys connect users to roles, reports to users/category/location, and assignments/history/actions/attachments to reports and users. Deleting a hazard report cascades to its dependent operational records; ordinary runtime report DELETE is denied to preserve those records. Unique constraints cover role name, user email/username, category name and report/technician assignment pairs.

CHECK constraints restrict account/status/priority labels, require verifier ID and verification time to be both present or both absent, and require a resolution timestamp for Resolved/Closed reports. Actual invalid verifier-pair and missing-resolution-timestamp INSERTs were rejected with SQLSTATE 23514. These are not a complete state-transition or actor-authorization mechanism.

The seed spans all six states: 2 Submitted, 2 Verified and 3 each Assigned, In Progress, Resolved and Closed. [Catalog evidence](evidence/catalog.txt), [upstream sanity queries](evidence/upstream_verification.txt) and [final cleanup](evidence/final_cleanup.txt) verify the inventory and retained baseline. Manual setup did not generate optional demo photo files; a real synthetic PNG upload/retrieval was tested separately and then removed.

## 5. Database operations required by current code

| Feature / implementation | Required operations |
|---|---|
| Authentication / Auth | SELECT app_user password hash and joined role; verify password in PHP |
| User management / User model | SELECT/INSERT/UPDATE app_user; SELECT role; deactivate rather than delete |
| Category/location management | SELECT/INSERT/UPDATE; soft deactivate, no hard DELETE |
| New report / Report.create | INSERT report and status history, optional attachment, in a transaction |
| Verify, assign, start, resolve, close | SELECT/UPDATE report; INSERT history; INSERT/UPDATE assignment; INSERT action |
| Report search, details, statistics | SELECT and joins across operational/master/user tables |
| Attachments | SELECT/INSERT; Attachment model also provides DELETE |
| External auditor | Read approved operational/master records without app_user |
| Backup operator | Read all current tables and sequence state for a complete logical dump |

There is no normal role-definition write path or assignment DELETE in the reviewed models. Runtime privileges therefore omit role writes, the role sequence, assignment DELETE and blanket sequence SELECT. History and maintenance actions are append-only for the runtime: INSERT allowed, UPDATE/DELETE denied.

## 6. Application-role distinction and assessment findings

CampusSafe has real session authentication with Student, Faculty/Staff, Maintenance, Administrator and Auditor roles. All web sessions nevertheless share the single PDO login configured in `.env`. Logging in as the web Auditor does not switch the connection to `campussafe_report`. PostgreSQL read-only guarantees apply to the separate database account, while web role restrictions must be enforced by controllers.

The upstream role script uses generic group names, local password placeholders, an unused assignment DELETE grant and blanket future table grants including UPDATE. Our evaluated implementation uses project-specific groups, explicit role attributes, narrower current grants and reviewed future grants. Documentation mentions an owner account but the supplied role script does not provision it; the evaluation implements an actual owner group/DBA membership.

**Verified unresolved web findings:** the Auditor can submit a report; an unassigned maintenance user can start another user's report through the work-queue POST route; and an anonymous caller can retrieve an actual uploaded synthetic attachment. Other tested guards, including admin-page role denial, CSRF denial and student own-report restriction, worked. See [part_d.md](part_d.md) for evidence and recommendations.

No tracked source files were changed in the owning repository. All reports/SQL/evidence are local Group 5 work. No owner feedback, tracker update, external publication or consolidated course-submission PDF was performed in this scoped task.
