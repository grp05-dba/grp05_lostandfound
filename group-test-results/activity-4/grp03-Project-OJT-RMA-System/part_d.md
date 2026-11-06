# Verification Report – Test and Verify Access Control

## 1. Scope and Naming

This report is saved as **`part_d.md` as requested**. It covers the Activity 4 PDF's **Part E – Test and Verify Access Control**. The PDF's Part D least-privilege review is included in [part_cd.md](part_cd.md), following the grp02 report structure.

Tests were executed on **6 November 2026** against local PostgreSQL 18.6 and `ojt_managementdb`. These are observed results, not illustrative outcomes.

Each database login connected independently:

```sh
psql -X -w -a -U grp03_ojt_app -d ojt_managementdb -f sql/05_test_runtime.sql
psql -X -w -a -U grp03_ojt_auditor -d ojt_managementdb -f sql/06_test_auditor.sql
psql -X -w -a -U grp03_ojt_dba -d ojt_managementdb -f sql/07_test_dba.sql
```

`SELECT current_database(), session_user, current_user;` confirmed the requested login as both session and current user in each test. psql used the local Unix socket with no password in its command. PostgreSQL role impersonation by the superuser was not used for these three test sessions. The DBA's deliberate SET ROLE during the future-object test is identified in its script. The Java smoke test additionally used JDBC over the locally configured connection; remote authentication was not tested.

Expected errors were allowed to continue. Success was assessed from individual outputs and SQLSTATE values, not the psql process exit code. Every expected SQL privilege denial below returned **`42501`**. Each denied data/schema statement had its own BEGIN/ROLLBACK; CREATE DATABASE and CREATE ROLE ran outside transaction blocks so their errors tested privileges.

## 2. Runtime Results

Full statements and output: [runtime.txt](evidence/runtime.txt). Reproducible script: [05_test_runtime.sql](sql/05_test_runtime.sql).

| Test | Account | SQL statement / operation | Expected | Actual | Result |
|---|---|---|---|---|---|
| A01 | `grp03_ojt_app` | `SELECT count(*) FROM users;` and `audit_log` | Allowed | 5 users, 0 audit records | PASS |
| A02 | `grp03_ojt_app` | Linked INSERTs into all 11 insertable tables using default SERIAL IDs | Allowed | 13 successful `INSERT 0 1` results; all 11 allowed sequences exercised | PASS |
| A03 | `grp03_ojt_app` | UPDATE inserted `users`, `ojt_applications`, `student_requirements`, `ojt_placements`, `attendance` through approved columns | Allowed | Five `UPDATE 1` results; ROLLBACK; 0 remaining probe users | PASS |
| A04 | `grp03_ojt_app` | `UPDATE users SET role=role WHERE false;` | Denied | Permission denied for table users | PASS |
| A05 | `grp03_ojt_app` | `UPDATE attendance SET hours_rendered=hours_rendered WHERE false;` | Denied | Permission denied for table attendance | PASS |
| A06 | `grp03_ojt_app` | `INSERT INTO audit_log(table_name,action,row_id) VALUES ('test','test',0);` | Denied | Permission denied for table audit_log | PASS |
| A07 | `grp03_ojt_app` | `DELETE FROM companies WHERE false;` | Denied | Permission denied for table companies | PASS |
| A08 | `grp03_ojt_app` | `TRUNCATE audit_log;` | Denied | Permission denied for table audit_log | PASS |
| A09 | `grp03_ojt_app` | `SELECT nextval('audit_log_audit_id_seq');` | Denied | Permission denied for sequence | PASS |
| A10 | `grp03_ojt_app` | `CREATE TABLE public.a4_forbidden(id int);` | Denied | Permission denied for schema public | PASS |
| A11 | `grp03_ojt_app` | `SET ROLE grp03_ojt_admin_grp;` | Denied | Permission denied to set role | PASS |
| A12a | `grp03_ojt_app` | `CREATE DATABASE grp03_a4_forbidden;` | Denied | Permission denied to create database | PASS |
| A12b | `grp03_ojt_app` | `CREATE ROLE grp03_a4_forbidden NOLOGIN;` | Denied | Permission denied to create role | PASS |

A02 created three temporary application users plus student/academic/company profiles, a company, a requirement, an application, a submission, a placement, attendance and an evaluation in one transaction. The foreign-key chain used returned generated IDs, rather than assumed seed IDs. A03 modified real temporary rows, not only zero-row privilege probes.

The five allowed UPDATE operations produced:

```text
UPDATE 1
UPDATE 1
UPDATE 1
UPDATE 1
UPDATE 1
ROLLBACK
 remaining_probe_users
-----------------------
                     0
```

The forbidden UPDATE/DELETE probes with `WHERE false` verify statement privileges, not record-level authorization. They still require the relevant permissions even when no row qualifies.

## 3. Auditor Results

Full statements and output: [auditor.txt](evidence/auditor.txt). Script: [06_test_auditor.sql](sql/06_test_auditor.sql).

| Test | Account | SQL statement / operation | Expected | Actual | Result |
|---|---|---|---|---|---|
| R01 | `grp03_ojt_auditor` | SELECT approved user/audit columns and counts from companies/students/attendance | Allowed | 5 approved user rows; companies 1, students 1, attendance 0; audit projection succeeded | PASS |
| R02 | `grp03_ojt_auditor` | `SELECT password_hash FROM users LIMIT 0;` | Denied | Permission denied for table users | PASS |
| R03 | `grp03_ojt_auditor` | `SELECT details FROM audit_log LIMIT 0;` | Denied | Permission denied for table audit_log | PASS |
| R04 | `grp03_ojt_auditor` | `UPDATE companies SET company_name=company_name WHERE false;` | Denied | Permission denied for table companies | PASS |
| R05 | `grp03_ojt_auditor` | `INSERT INTO requirements(title) VALUES ('Activity4 denied');` | Denied | Permission denied for table requirements | PASS |
| R06 | `grp03_ojt_auditor` | `DELETE FROM attendance WHERE false;` | Denied | Permission denied for table attendance | PASS |
| R07 | `grp03_ojt_auditor` | `SELECT nextval('requirements_req_id_seq');` | Denied | Permission denied for sequence | PASS |
| R08 | `grp03_ojt_auditor` | `CREATE TABLE public.a4_forbidden(id int);` | Denied | Permission denied for schema public | PASS |
| R09 | `grp03_ojt_auditor` | `SET ROLE grp03_ojt_runtime_grp;` | Denied | Permission denied to set role | PASS |
| R10a | `grp03_ojt_auditor` | `CREATE DATABASE grp03_a4_forbidden;` | Denied | Permission denied to create database | PASS |
| R10b | `grp03_ojt_auditor` | `CREATE ROLE grp03_a4_forbidden NOLOGIN;` | Denied | Permission denied to create role | PASS |

`LIMIT 0` checks column privileges without printing sensitive values. The ordinary user read returned actual approved records, rather than relying exclusively on empty projections.

## 4. Database Administrator Results

Full statements and output: [dba.txt](evidence/dba.txt). Script: [07_test_dba.sql](sql/07_test_dba.sql).

| Test | Account | SQL statement / operation | Expected | Actual | Result |
|---|---|---|---|---|---|
| D01 | `grp03_ojt_dba` | CREATE SERIAL table; INSERT, UPDATE, DELETE; ALTER TABLE; GRANT and REVOKE SELECT | Allowed | All succeeded; ROLLBACK; `probe_removed = t` | PASS |
| D02 | `grp03_ojt_dba` | SELECT restricted `users.password_hash` and `audit_log.details`, each `LIMIT 0` | Allowed for database maintenance | Both projections succeeded; no sensitive values printed | PASS |
| D03a | `grp03_ojt_dba` | `CREATE DATABASE grp03_a4_forbidden;` | Denied | Permission denied to create database | PASS |
| D03b | `grp03_ojt_dba` | `CREATE ROLE grp03_a4_forbidden NOLOGIN;` | Denied | Permission denied to create role | PASS |
| D04 | `grp03_ojt_dba`, then `SET ROLE grp03_ojt_admin_grp` | Create future table, SERIAL sequence and function; query runtime privileges with `has_*_privilege` | Runtime has no automatic SELECT/USAGE/EXECUTE | `f`, `f`, `f`; all objects rolled back | PASS |

The DBA is scoped through project ownership. Absence of CREATEROLE is intentional; the separate cluster administrator provisions accounts.

## 5. Cross-Database Isolation – Unresolved Failure

Each of the three logins ran the following command, substituting its own account name:

```sh
psql -X -w -U grp03_ojt_app -d grp_parkitdb -c 'SELECT current_database(), session_user, current_user;'
```

| Test | Account | Operation | Expected | Actual | Result / evidence |
|---|---|---|---|---|---|
| X01 | `grp03_ojt_app` | Connect to unrelated `grp_parkitdb` | Denied | Connected successfully as itself | **FAIL** – [output](evidence/isolation-grp03_ojt_app.txt) |
| X02 | `grp03_ojt_auditor` | Connect to unrelated `grp_parkitdb` | Denied | Connected successfully as itself | **FAIL** – [output](evidence/isolation-grp03_ojt_auditor.txt) |
| X03 | `grp03_ojt_dba` | Connect to unrelated `grp_parkitdb` | Denied for project-scoped maintenance | Connected successfully as itself | **FAIL** – [output](evidence/isolation-grp03_ojt_dba.txt) |

The PostgreSQL database ACL inspection showed PUBLIC CONNECT on Park It. The role membership inspection showed only each login's intended grp03 group. [Catalog inspection](evidence/catalog.txt) also reported effective CONNECT on several other databases, including `postgres`, `company_db`, `grp_brewposdb`, and the lost-and-found databases. For those additional databases, the catalog result is a privilege finding; actual connection attempts were made only to `grp_parkitdb` in this report. CONNECT does not itself imply table-read or table-write permission there; unrelated table access was not tested.

Cause: access is inherited from PUBLIC at each unrelated database, despite no grp03-specific grants there. PostgreSQL has no per-role negative grant that overrides PUBLIC. Removing PUBLIC privileges only from `ojt_managementdb` does not restrict other databases.

Recommended correction: inventory the legitimate clients of each unrelated database, explicitly grant their intended CONNECT rights, and then revoke CONNECT from PUBLIC there; or isolate the projects in separate clusters or apply reviewed `pg_hba.conf` restrictions. Those cross-project ACL and server changes remain unapplied. **Overall least-privilege verification remains incomplete.**

## 6. Schema and Java Verification

[Schema replay](evidence/schema-replay.txt) proves that the corrected PDF DDL plus the four Java compatibility columns created all 12 tables successfully in a temporary schema. The entire probe transaction was rolled back. [Catalog evidence](evidence/catalog.txt) confirms the existing database's 12 tables, 12 sequences, ownership, schema privileges, column grants, attributes, memberships, defaults, absent RLS policies and zero user-defined triggers.

The unchanged owning-group Java sources compiled successfully using Java 21. [Smoke.java](verification/Smoke.java) then exercised `Db.init()`, real application login and initial tab/query construction for each role using the local JDBC configuration. [Captured output](evidence/java-smoke.txt):

```text
JDBC session: {current_user=grp03_ojt_app, current_database=ojt_managementdb}
PASS ADMIN: login and 2 tabs constructed
PASS STUDENT: login and 6 tabs constructed
PASS ACADEMIC_SUPERVISOR: login and 4 tabs constructed
PASS COMPANY_SUPERVISOR: login and 3 tabs constructed
PASS OJT_COORDINATOR: login and 3 tabs constructed
PASS application startup, authentication and initial tab queries; interactive actions not exercised
```

No buttons or modal workflows were driven. The separate SQL tests exercised representative real linked records and column updates; they do not prove every Java workflow, business rule or per-student restriction.

## 7. Data Preservation, Status and AI Declaration

All test data changes and DDL probes were rolled back. Schema and privilege changes intentionally applied by `03_privileges.sql` persist. The final catalog count shows the original seed state: 5 users, 1 student, 1 company, 3 requirements, and no applications, submissions, placements, attendance, evaluations or audit entries. SERIAL sequence increments are not rolled back, so test inserts consumed sequence values without leaving records. Existing application data was not deleted.

Database setup result: **Success with issues**. Access-control status: **Privileges tested; cross-database isolation unresolved**. The prepared setup/security feedback has not been sent to the owners. No tracker update, Git commit/push or submission PDF is claimed.

AI assistance (OpenAI Codex) reviewed the PDF and source, prepared local schema adaptations and SQL/report files, executed psql checks and the Java smoke test, and interpreted the output. Validation used the fetched repository commit, real PostgreSQL catalog results, separate login connections, SQLSTATE errors, actual inserted/updated records, rollback checks and Java JDBC execution. No real passwords or password hashes are included in this folder's reports, scripts or evidence.
