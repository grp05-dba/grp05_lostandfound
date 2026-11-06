# Verification Report - Test and Verify Access Control

**Filename mapping:** requested `part_d.md`; verification is Part E in the Activity 4 assignment PDF. Its Part D least-privilege review is in [part_cd.md](part_cd.md).

## 1. Execution and qualified result

Executed **6 November 2026 (Asia/Manila)** using PostgreSQL 18.6/psql against `grp07_campussafedb`, public schema, on `127.0.0.1:55432`.

**133/133 main database access checks passed.** Additional checks passed for 10 future-object lifecycle operations, 8 cross-project isolation/preservation operations, one actual logical-backup capability test and two CHECK-constraint rejections. The full HTTP hazard lifecycle also completed. However, **three web authorization expectations failed** and remain unresolved: Auditor submission, unassigned-technician start-work and anonymous attachment retrieval. The application must not be described as fully secure based on the database passes.

Each database case used a direct TCP login with private local credentials. Identity queries verified session/current user for all four logins. Runtime/auditor/backup tests did not use superuser impersonation; the DBA deliberately exercised its owner membership. SQL errors were matched to nonzero exit status and SQLSTATE 42501. Initial connection failures omit SQLSTATE in this psql output, so isolation checks matched explicit lack-of-CONNECT text and a failed connection status.

## 2. Evidence index

- [Setup and fresh-database guard](evidence/setup.txt), [catalog/ACLs](evidence/catalog.txt), [authentication configuration](evidence/authentication.txt).
- [Runtime](evidence/campussafe_app.txt), [SQL auditor](evidence/campussafe_report.txt), [backup operator](evidence/campussafe_backup.txt), [DBA](evidence/campussafe_dba.txt).
- [Full main-case SQL and results](evidence/results.json), [future objects](evidence/future_objects.txt), [reverse isolation/preservation](evidence/cross_project_isolation.txt).
- [Backup metadata](evidence/backup_capability.txt), [CHECK rejection tests](evidence/schema_constraints.txt), [upstream sanity verification](evidence/upstream_verification.txt).
- [HTTP workflow and web findings](evidence/application_validation.txt), [PHP connection diagnostic](evidence/application_runtime.txt), [server log](evidence/application_server.txt), [final cleanup](evidence/final_cleanup.txt).

Seed echo, credential values, actual password hashes, raw login HTML, session cookies and CSRF tokens are excluded. The actual full backup is sensitive and retained only in scratch storage; it is not a submitted artifact.

## 3. Main database test matrix

Each ID maps to its block in that account's evidence file. Longer SQL is preserved in the linked JSON and account verification scripts.

| Test | Account | Statement / operation | Expected | Actual | Status |
|---|---|---|---|---|---|
| `identity-campussafe_app` | `campussafe_app` | SELECT session_user, current_user, current_database() | Allowed | Succeeded | **PASS** |
| `read-campussafe_app` | `campussafe_app` | SELECT actual counts from approved tables | Allowed | Seed baseline returned; SQL auditor excludes app_user | **PASS** |
| `identity-campussafe_report` | `campussafe_report` | SELECT session_user, current_user, current_database() | Allowed | Succeeded | **PASS** |
| `read-campussafe_report` | `campussafe_report` | SELECT actual counts from approved tables | Allowed | Seed baseline returned; SQL auditor excludes app_user | **PASS** |
| `identity-campussafe_backup` | `campussafe_backup` | SELECT session_user, current_user, current_database() | Allowed | Succeeded | **PASS** |
| `read-campussafe_backup` | `campussafe_backup` | SELECT actual counts from approved tables | Allowed | Seed baseline returned; SQL auditor excludes app_user | **PASS** |
| `identity-campussafe_dba` | `campussafe_dba` | SELECT session_user, current_user, current_database() | Allowed | Succeeded | **PASS** |
| `read-campussafe_dba` | `campussafe_dba` | SELECT actual counts from approved tables | Allowed | Seed baseline returned; SQL auditor excludes app_user | **PASS** |
| `runtime-workflow` | `campussafe_app` | Actual inserts for eight mutable entities; five updates; attachment delete; joined read; ROLLBACK | Allowed | Allowed writes succeeded; baseline restored | **PASS** |
| `runtime-deny-role-insert` | `campussafe_app` | BEGIN; INSERT INTO role(role_name) VALUES ('E4 forbidden'); ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `runtime-deny-role-update` | `campussafe_app` | BEGIN; UPDATE role SET description=description WHERE role_id=1; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `runtime-deny-role-delete` | `campussafe_app` | BEGIN; DELETE FROM role WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `runtime-deny-user-delete` | `campussafe_app` | BEGIN; DELETE FROM app_user WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `runtime-deny-category-delete` | `campussafe_app` | BEGIN; DELETE FROM hazard_category WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `runtime-deny-location-delete` | `campussafe_app` | BEGIN; DELETE FROM campus_location WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `runtime-deny-report-delete` | `campussafe_app` | BEGIN; DELETE FROM hazard_report WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `runtime-deny-assignment-delete` | `campussafe_app` | BEGIN; DELETE FROM assignment WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `runtime-deny-history-update` | `campussafe_app` | BEGIN; UPDATE report_status_history SET notes=notes WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `runtime-deny-history-delete` | `campussafe_app` | BEGIN; DELETE FROM report_status_history WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `runtime-deny-action-update` | `campussafe_app` | BEGIN; UPDATE maintenance_action SET notes=notes WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `runtime-deny-action-delete` | `campussafe_app` | BEGIN; DELETE FROM maintenance_action WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `runtime-deny-attachment-update` | `campussafe_app` | BEGIN; UPDATE attachment SET file_name=file_name WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `runtime-deny-truncate` | `campussafe_app` | BEGIN; TRUNCATE report_status_history; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `runtime-deny-create-table` | `campussafe_app` | BEGIN; CREATE TABLE public.e4_forbidden(id integer); ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `runtime-deny-create-schema` | `campussafe_app` | BEGIN; CREATE SCHEMA e4_forbidden; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `runtime-deny-create-temp` | `campussafe_app` | BEGIN; CREATE TEMP TABLE e4_forbidden(id integer); ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `runtime-deny-alter-table` | `campussafe_app` | BEGIN; ALTER TABLE role ADD COLUMN e4_forbidden integer; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `runtime-deny-role-sequence` | `campussafe_app` | BEGIN; SELECT nextval('role_role_id_seq'); ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `runtime-deny-sequence-reset` | `campussafe_app` | BEGIN; SELECT setval('hazard_report_report_id_seq',1); ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `runtime-deny-owner-escalation` | `campussafe_app` | BEGIN; SET ROLE campussafe_owner_grp; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `auditor-deny-users` | `campussafe_report` | SELECT user_id FROM app_user LIMIT 0; | Denied | Permission error 42501 | **PASS** |
| `auditor-deny-hashes` | `campussafe_report` | SELECT password_hash FROM app_user LIMIT 0; | Denied | Permission error 42501 | **PASS** |
| `backup-hash-column-readable` | `campussafe_backup` | SELECT password_hash IS NOT NULL ... LIMIT 1 | Allowed | Read permitted; boolean only, no hash output | **PASS** |
| `backup-sequence-state` | `campussafe_backup` | SELECT last_value FROM role_role_id_seq; | Allowed | Succeeded | **PASS** |
| `campussafe_report-deny-insert-role` | `campussafe_report` | BEGIN; INSERT INTO role DEFAULT VALUES; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_report-deny-update-role` | `campussafe_report` | BEGIN; UPDATE role SET description=description WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_report-deny-delete-role` | `campussafe_report` | BEGIN; DELETE FROM role WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_report-deny-insert-app_user` | `campussafe_report` | BEGIN; INSERT INTO app_user DEFAULT VALUES; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_report-deny-update-app_user` | `campussafe_report` | BEGIN; UPDATE app_user SET full_name=full_name WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_report-deny-delete-app_user` | `campussafe_report` | BEGIN; DELETE FROM app_user WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_report-deny-insert-hazard_category` | `campussafe_report` | BEGIN; INSERT INTO hazard_category DEFAULT VALUES; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_report-deny-update-hazard_category` | `campussafe_report` | BEGIN; UPDATE hazard_category SET description=description WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_report-deny-delete-hazard_category` | `campussafe_report` | BEGIN; DELETE FROM hazard_category WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_report-deny-insert-campus_location` | `campussafe_report` | BEGIN; INSERT INTO campus_location DEFAULT VALUES; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_report-deny-update-campus_location` | `campussafe_report` | BEGIN; UPDATE campus_location SET building=building WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_report-deny-delete-campus_location` | `campussafe_report` | BEGIN; DELETE FROM campus_location WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_report-deny-insert-hazard_report` | `campussafe_report` | BEGIN; INSERT INTO hazard_report DEFAULT VALUES; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_report-deny-update-hazard_report` | `campussafe_report` | BEGIN; UPDATE hazard_report SET description=description WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_report-deny-delete-hazard_report` | `campussafe_report` | BEGIN; DELETE FROM hazard_report WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_report-deny-insert-assignment` | `campussafe_report` | BEGIN; INSERT INTO assignment DEFAULT VALUES; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_report-deny-update-assignment` | `campussafe_report` | BEGIN; UPDATE assignment SET assignment_status=assignment_status WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_report-deny-delete-assignment` | `campussafe_report` | BEGIN; DELETE FROM assignment WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_report-deny-insert-report_status_history` | `campussafe_report` | BEGIN; INSERT INTO report_status_history DEFAULT VALUES; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_report-deny-update-report_status_history` | `campussafe_report` | BEGIN; UPDATE report_status_history SET notes=notes WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_report-deny-delete-report_status_history` | `campussafe_report` | BEGIN; DELETE FROM report_status_history WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_report-deny-insert-maintenance_action` | `campussafe_report` | BEGIN; INSERT INTO maintenance_action DEFAULT VALUES; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_report-deny-update-maintenance_action` | `campussafe_report` | BEGIN; UPDATE maintenance_action SET notes=notes WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_report-deny-delete-maintenance_action` | `campussafe_report` | BEGIN; DELETE FROM maintenance_action WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_report-deny-insert-attachment` | `campussafe_report` | BEGIN; INSERT INTO attachment DEFAULT VALUES; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_report-deny-update-attachment` | `campussafe_report` | BEGIN; UPDATE attachment SET file_name=file_name WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_report-deny-delete-attachment` | `campussafe_report` | BEGIN; DELETE FROM attachment WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_report-deny-nextval` | `campussafe_report` | SELECT nextval('hazard_report_report_id_seq'); | Denied | Permission error 42501 | **PASS** |
| `campussafe_report-deny-setval` | `campussafe_report` | SELECT setval('hazard_report_report_id_seq',1); | Denied | Permission error 42501 | **PASS** |
| `campussafe_report-deny-create` | `campussafe_report` | BEGIN; CREATE TABLE public.e4_forbidden(id integer); ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_report-deny-owner` | `campussafe_report` | SET ROLE campussafe_owner_grp; | Denied | Permission error 42501 | **PASS** |
| `campussafe_backup-deny-insert-role` | `campussafe_backup` | BEGIN; INSERT INTO role DEFAULT VALUES; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_backup-deny-update-role` | `campussafe_backup` | BEGIN; UPDATE role SET description=description WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_backup-deny-delete-role` | `campussafe_backup` | BEGIN; DELETE FROM role WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_backup-deny-insert-app_user` | `campussafe_backup` | BEGIN; INSERT INTO app_user DEFAULT VALUES; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_backup-deny-update-app_user` | `campussafe_backup` | BEGIN; UPDATE app_user SET full_name=full_name WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_backup-deny-delete-app_user` | `campussafe_backup` | BEGIN; DELETE FROM app_user WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_backup-deny-insert-hazard_category` | `campussafe_backup` | BEGIN; INSERT INTO hazard_category DEFAULT VALUES; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_backup-deny-update-hazard_category` | `campussafe_backup` | BEGIN; UPDATE hazard_category SET description=description WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_backup-deny-delete-hazard_category` | `campussafe_backup` | BEGIN; DELETE FROM hazard_category WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_backup-deny-insert-campus_location` | `campussafe_backup` | BEGIN; INSERT INTO campus_location DEFAULT VALUES; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_backup-deny-update-campus_location` | `campussafe_backup` | BEGIN; UPDATE campus_location SET building=building WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_backup-deny-delete-campus_location` | `campussafe_backup` | BEGIN; DELETE FROM campus_location WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_backup-deny-insert-hazard_report` | `campussafe_backup` | BEGIN; INSERT INTO hazard_report DEFAULT VALUES; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_backup-deny-update-hazard_report` | `campussafe_backup` | BEGIN; UPDATE hazard_report SET description=description WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_backup-deny-delete-hazard_report` | `campussafe_backup` | BEGIN; DELETE FROM hazard_report WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_backup-deny-insert-assignment` | `campussafe_backup` | BEGIN; INSERT INTO assignment DEFAULT VALUES; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_backup-deny-update-assignment` | `campussafe_backup` | BEGIN; UPDATE assignment SET assignment_status=assignment_status WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_backup-deny-delete-assignment` | `campussafe_backup` | BEGIN; DELETE FROM assignment WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_backup-deny-insert-report_status_history` | `campussafe_backup` | BEGIN; INSERT INTO report_status_history DEFAULT VALUES; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_backup-deny-update-report_status_history` | `campussafe_backup` | BEGIN; UPDATE report_status_history SET notes=notes WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_backup-deny-delete-report_status_history` | `campussafe_backup` | BEGIN; DELETE FROM report_status_history WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_backup-deny-insert-maintenance_action` | `campussafe_backup` | BEGIN; INSERT INTO maintenance_action DEFAULT VALUES; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_backup-deny-update-maintenance_action` | `campussafe_backup` | BEGIN; UPDATE maintenance_action SET notes=notes WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_backup-deny-delete-maintenance_action` | `campussafe_backup` | BEGIN; DELETE FROM maintenance_action WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_backup-deny-insert-attachment` | `campussafe_backup` | BEGIN; INSERT INTO attachment DEFAULT VALUES; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_backup-deny-update-attachment` | `campussafe_backup` | BEGIN; UPDATE attachment SET file_name=file_name WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_backup-deny-delete-attachment` | `campussafe_backup` | BEGIN; DELETE FROM attachment WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_backup-deny-nextval` | `campussafe_backup` | SELECT nextval('hazard_report_report_id_seq'); | Denied | Permission error 42501 | **PASS** |
| `campussafe_backup-deny-setval` | `campussafe_backup` | SELECT setval('hazard_report_report_id_seq',1); | Denied | Permission error 42501 | **PASS** |
| `campussafe_backup-deny-create` | `campussafe_backup` | BEGIN; CREATE TABLE public.e4_forbidden(id integer); ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `campussafe_backup-deny-owner` | `campussafe_backup` | SET ROLE campussafe_owner_grp; | Denied | Permission error 42501 | **PASS** |
| `dba-maintenance` | `campussafe_dba` | SET ROLE owner; insert role; ALTER table; CREATE/DROP probe; ROLLBACK | Allowed | Succeeded; probe/role absent after rollback | **PASS** |
| `deny-createdb-campussafe_app` | `campussafe_app` | CREATE DATABASE campussafe_e4_forbidden; | Denied | Permission error 42501 | **PASS** |
| `deny-createrole-campussafe_app` | `campussafe_app` | CREATE ROLE campussafe_e4_forbidden NOLOGIN; | Denied | Permission error 42501 | **PASS** |
| `isolation-campussafe_app-campussafe_unrelateddb` | `campussafe_app` | Connect to `campussafe_unrelateddb` and attempt SELECT current_database() | Denied | Connection rejected: lacks CONNECT | **PASS** |
| `isolation-campussafe_app-grp00_habalgodb` | `campussafe_app` | Connect to `grp00_habalgodb` and attempt SELECT current_database() | Denied | Connection rejected: lacks CONNECT | **PASS** |
| `isolation-campussafe_app-habalgo_unrelateddb` | `campussafe_app` | Connect to `habalgo_unrelateddb` and attempt SELECT current_database() | Denied | Connection rejected: lacks CONNECT | **PASS** |
| `isolation-campussafe_app-grp_brewposdb` | `campussafe_app` | Connect to `grp_brewposdb` and attempt SELECT current_database() | Denied | Connection rejected: lacks CONNECT | **PASS** |
| `isolation-campussafe_app-brewpos_unrelateddb` | `campussafe_app` | Connect to `brewpos_unrelateddb` and attempt SELECT current_database() | Denied | Connection rejected: lacks CONNECT | **PASS** |
| `isolation-campussafe_app-postgres` | `campussafe_app` | Connect to `postgres` and attempt SELECT current_database() | Denied | Connection rejected: lacks CONNECT | **PASS** |
| `isolation-campussafe_app-template1` | `campussafe_app` | Connect to `template1` and attempt SELECT current_database() | Denied | Connection rejected: lacks CONNECT | **PASS** |
| `deny-createdb-campussafe_report` | `campussafe_report` | CREATE DATABASE campussafe_e4_forbidden; | Denied | Permission error 42501 | **PASS** |
| `deny-createrole-campussafe_report` | `campussafe_report` | CREATE ROLE campussafe_e4_forbidden NOLOGIN; | Denied | Permission error 42501 | **PASS** |
| `isolation-campussafe_report-campussafe_unrelateddb` | `campussafe_report` | Connect to `campussafe_unrelateddb` and attempt SELECT current_database() | Denied | Connection rejected: lacks CONNECT | **PASS** |
| `isolation-campussafe_report-grp00_habalgodb` | `campussafe_report` | Connect to `grp00_habalgodb` and attempt SELECT current_database() | Denied | Connection rejected: lacks CONNECT | **PASS** |
| `isolation-campussafe_report-habalgo_unrelateddb` | `campussafe_report` | Connect to `habalgo_unrelateddb` and attempt SELECT current_database() | Denied | Connection rejected: lacks CONNECT | **PASS** |
| `isolation-campussafe_report-grp_brewposdb` | `campussafe_report` | Connect to `grp_brewposdb` and attempt SELECT current_database() | Denied | Connection rejected: lacks CONNECT | **PASS** |
| `isolation-campussafe_report-brewpos_unrelateddb` | `campussafe_report` | Connect to `brewpos_unrelateddb` and attempt SELECT current_database() | Denied | Connection rejected: lacks CONNECT | **PASS** |
| `isolation-campussafe_report-postgres` | `campussafe_report` | Connect to `postgres` and attempt SELECT current_database() | Denied | Connection rejected: lacks CONNECT | **PASS** |
| `isolation-campussafe_report-template1` | `campussafe_report` | Connect to `template1` and attempt SELECT current_database() | Denied | Connection rejected: lacks CONNECT | **PASS** |
| `deny-createdb-campussafe_backup` | `campussafe_backup` | CREATE DATABASE campussafe_e4_forbidden; | Denied | Permission error 42501 | **PASS** |
| `deny-createrole-campussafe_backup` | `campussafe_backup` | CREATE ROLE campussafe_e4_forbidden NOLOGIN; | Denied | Permission error 42501 | **PASS** |
| `isolation-campussafe_backup-campussafe_unrelateddb` | `campussafe_backup` | Connect to `campussafe_unrelateddb` and attempt SELECT current_database() | Denied | Connection rejected: lacks CONNECT | **PASS** |
| `isolation-campussafe_backup-grp00_habalgodb` | `campussafe_backup` | Connect to `grp00_habalgodb` and attempt SELECT current_database() | Denied | Connection rejected: lacks CONNECT | **PASS** |
| `isolation-campussafe_backup-habalgo_unrelateddb` | `campussafe_backup` | Connect to `habalgo_unrelateddb` and attempt SELECT current_database() | Denied | Connection rejected: lacks CONNECT | **PASS** |
| `isolation-campussafe_backup-grp_brewposdb` | `campussafe_backup` | Connect to `grp_brewposdb` and attempt SELECT current_database() | Denied | Connection rejected: lacks CONNECT | **PASS** |
| `isolation-campussafe_backup-brewpos_unrelateddb` | `campussafe_backup` | Connect to `brewpos_unrelateddb` and attempt SELECT current_database() | Denied | Connection rejected: lacks CONNECT | **PASS** |
| `isolation-campussafe_backup-postgres` | `campussafe_backup` | Connect to `postgres` and attempt SELECT current_database() | Denied | Connection rejected: lacks CONNECT | **PASS** |
| `isolation-campussafe_backup-template1` | `campussafe_backup` | Connect to `template1` and attempt SELECT current_database() | Denied | Connection rejected: lacks CONNECT | **PASS** |
| `deny-createdb-campussafe_dba` | `campussafe_dba` | CREATE DATABASE campussafe_e4_forbidden; | Denied | Permission error 42501 | **PASS** |
| `deny-createrole-campussafe_dba` | `campussafe_dba` | CREATE ROLE campussafe_e4_forbidden NOLOGIN; | Denied | Permission error 42501 | **PASS** |
| `isolation-campussafe_dba-campussafe_unrelateddb` | `campussafe_dba` | Connect to `campussafe_unrelateddb` and attempt SELECT current_database() | Denied | Connection rejected: lacks CONNECT | **PASS** |
| `isolation-campussafe_dba-grp00_habalgodb` | `campussafe_dba` | Connect to `grp00_habalgodb` and attempt SELECT current_database() | Denied | Connection rejected: lacks CONNECT | **PASS** |
| `isolation-campussafe_dba-habalgo_unrelateddb` | `campussafe_dba` | Connect to `habalgo_unrelateddb` and attempt SELECT current_database() | Denied | Connection rejected: lacks CONNECT | **PASS** |
| `isolation-campussafe_dba-grp_brewposdb` | `campussafe_dba` | Connect to `grp_brewposdb` and attempt SELECT current_database() | Denied | Connection rejected: lacks CONNECT | **PASS** |
| `isolation-campussafe_dba-brewpos_unrelateddb` | `campussafe_dba` | Connect to `brewpos_unrelateddb` and attempt SELECT current_database() | Denied | Connection rejected: lacks CONNECT | **PASS** |
| `isolation-campussafe_dba-postgres` | `campussafe_dba` | Connect to `postgres` and attempt SELECT current_database() | Denied | Connection rejected: lacks CONNECT | **PASS** |
| `isolation-campussafe_dba-template1` | `campussafe_dba` | Connect to `template1` and attempt SELECT current_database() | Denied | Connection rejected: lacks CONNECT | **PASS** |

## 4. Operational and credential-protection verification

The actual runtime transaction inserted a synthetic user, category, location, report, history, assignment, maintenance action and attachment, exercising all eight permitted insert sequences. It updated the five mutable entities and deleted its attachment, then rolled back. The joined result showed Verified/High and an In Progress assignment; baseline counts were restored. The test user used a visibly non-credential test marker rather than a real password hash.

History/action UPDATE and DELETE were denied. User/report/category/location/assignment/role DELETE, role writes, attachment UPDATE, TRUNCATE, sequence reset, role-sequence generation and administrative DDL were also denied as planned.

The SQL auditor could read approved records but failed to SELECT even user_id from app_user and separately failed to SELECT password_hash. Backup hash-column access was tested using `password_hash IS NOT NULL`, returning only a boolean. Neither test printed a hash. Both auditor and backup INSERT/UPDATE/DELETE attempts were denied for every one of nine tables. Their nextval/setval and owner-role escalation were denied.

DBA owner maintenance succeeded for a real role INSERT and table ALTER/CREATE/DROP within a rollback transaction, while all four logins were denied CREATE DATABASE and CREATE ROLE outside transaction blocks. WHERE-false tests establish privilege boundaries; the actual runtime/DBA inserts and mutations supplement those checks.

## 5. Isolation, ownership and future objects

All four CampusSafe accounts were denied connections to seven targets: campussafe_unrelateddb, grp00_habalgodb, habalgo_unrelateddb, grp_brewposdb, brewpos_unrelateddb, postgres and template1. Six reverse tests denied the previous Group 4/6 logins access to CampusSafe. Two preservation tests confirmed Group 4 and Group 6 runtime accounts still connected to their own databases. These eight supplemental results are recorded separately.

Catalog evidence confirms project objects belong to campussafe_owner_grp, with only intended memberships, no ADMIN OPTION, no elevated attributes, no runtime/auditor ownership and reviewed PUBLIC ACLs. Existing service databases on port 5432 were not inspected or changed.

Ten future-object lifecycle checks:

| Check | Actual |
|---|---|
| Owner creates a new serial-key table and SQL function | Allowed |
| Runtime reads new table / executes function | Both denied, 42501 |
| SQL auditor reads new table / executes function | Both denied, 42501 |
| Backup reads new table / executes function | Both denied, 42501 |
| DBA uses owner to INSERT and execute | Allowed; data rolled back |
| Owner drops both probes | Allowed |
| Verify both objects absent | Both true |

No role automatically receives future table access. Owner-created future functions lose PUBLIC EXECUTE. Backup permissions must be reviewed when adding objects; the successful current-schema dump is not a promise of automatic future backup access.

## 6. Backup and schema checks

An actual `pg_dump -Fc` connection as campussafe_backup completed with exit code zero. pg_restore's archive list contained all **nine TABLE DATA entries** and sequence SET metadata. Only archive metadata is submitted. The full local dump contains application credential data and is excluded from the report bundle. No restore or recovery claim is made from this capability check.

Two runtime INSERTs intentionally violated the verifier/time pair and the Resolved-with-timestamp requirement. Both failed with SQLSTATE **23514**, proving real CHECK enforcement rather than privilege rejection. The upstream `database/verify.sql` also completed successfully; its output covers counts, status distribution, integrity checks, joins and indexes. These checks do not establish every possible lifecycle or actor rule at database level.

## 7. HTTP controls and hazard lifecycle

Real form sessions authenticated the seeded student, administrator, both technicians and Auditor. Credentials were used privately; evidence records sanitized endpoint/status/assertion summaries rather than secret-bearing HTML or session data. Test-created report/file IDs refer only to synthetic local fixtures.

| Test | Expected | Actual / status |
|---|---|---|
| Guest opens report creation | Login required | Redirect to login - PASS |
| Student opens user-admin page | Denied | HTTP 403 - PASS |
| Auditor opens admin verification | Denied | HTTP 403 - PASS |
| Auditor opens statistics | Allowed | HTTP 200 - PASS |
| Student requests another reporter's seed report | Denied | Redirect to own-report list - PASS |
| Student submits without CSRF token | Denied | HTTP 403 - PASS |
| Student submits synthetic report and PNG | Allowed | Report/attachment created - PASS |
| Administrator verifies and assigns | Allowed | Verified, then Assigned - PASS |
| Unassigned technician opens dedicated update route | Denied | Redirect to work queue - PASS |
| Unassigned technician POSTs start-work from work queue | Denied | Report changed to In Progress - **FAIL, unresolved** |
| Assigned technician resolves; administrator closes | Allowed | Closed with resolved_at and six history rows - PASS |
| Web Auditor submits a new report | Denied for documented read-only responsibility | Submitted report/history created - **FAIL, unresolved** |
| Guest retrieves synthetic uploaded attachment | Denied for protected report evidence | HTTP 200 with actual PNG bytes - **FAIL, unresolved** |

The separate [PDO CLI diagnostic](evidence/application_runtime.txt) used the same ignored .env and unmodified Database.php as the HTTP server and confirmed campussafe_app as both session/current user. These are direct HTTP tests, not an interactive browser or full automated application suite.

## 8. Unresolved findings and recommended owner fixes

### 8.1 Web Auditor can submit reports

The submission route calls requireLogin but does not exclude Auditor. A real authenticated Auditor session created a Submitted report with reporter_user_id 6 and one initial history row. Its database connection remained the shared campussafe_app, not campussafe_report.

Recommended fix: enforce allowed submission roles on both page access and POST handling, and test every write route against the documented read-only Auditor responsibility. If Auditors should be allowed to report hazards, change that documented responsibility explicitly rather than claiming they are universally read-only. PostgreSQL's separate read-only account cannot by itself correct shared-runtime web authorization.

### 8.2 Unassigned technician can start another technician's report

The dedicated maintenance-update route correctly rejected the unassigned technician. However, the work-queue POST passed its supplied report ID to Report.startProgress without validating ownership. The model updated the report status and appended a history row even though its assignment UPDATE matched no row for that caller.

Observed synthetic evidence: assigned technician remained user 2 with assignment_status Assigned, while report status became In Progress and latest history changed_by_user_id was user 3. Recommended fix: validate caller assignment inside the same transaction as the status change, check affected rows, and apply that check consistently to all start-work entry points. Do not rely on the queue's displayed rows as the authorization boundary.

### 8.3 Attachment viewer serves files to anonymous callers

The viewer starts a session but does not require authentication or check report ownership/role before serving a file. A guest request returned HTTP 200 and the actual bytes of the synthetic PNG uploaded during this test. No existing person's real attachment was accessed in the probe.

Recommended fix: authenticate and authorize attachment access consistently with report access, and prevent direct public upload paths from bypassing that decision. Random filenames do not replace access checks. Review the viewer and both upload-storage locations together. The synthetic file copies were deleted after testing.

### 8.4 Provisioning and documentation alignment

The upstream script's generic groups and blanket future SELECT/INSERT/UPDATE grants can blur append-only and credential restrictions. This evaluation instead requires explicit future-object grants. Documentation also simplifies current privileges as writes on all tables, even though the actual script/code distinguishes role definitions and immutable logs. Recommend aligning the matrix, mapping the shared web runtime accurately, and explicitly provisioning an owner/DBA if that account is required by the instructions.

**Feedback sent to owners: No.** Findings are prepared for the user's review; no external issue, message or pull request was posted. The owning source remains unchanged. These are open findings, not completed fixes or a claim of comprehensive application security.

## 9. Cleanup, scope and AI usage

Final counts are **5 roles, 6 users, 6 categories, 10 locations, 16 reports, 12 assignments, 60 history rows, 9 actions and 5 attachments**. Main SQL probes rolled back, denied operations created no objects, and future probes were removed. A provisioning DELETE targeted only report descriptions reserved for the HTTP tests, cascading their dependent records; both copies of the synthetic PNG were removed using validated paths. No seed report or user was intentionally altered. SERIAL values advanced during successful tests and were not reset.

The evaluator-created full backup and local credentials remain in private scratch storage outside the submitted folder. The deliverable contains neither the dump, passwords, password hashes, cookies nor CSRF tokens. Manual setup does not guarantee optional seeded photo files exist; the real synthetic upload path was exercised. No backup restore, production concurrency, every upload edge case or every application route is claimed tested.

**AI usage declaration:** OpenAI Codex reviewed the assignment, source, documentation and relevant Activity 3 progress material; designed the access plan; initialized the isolated database; executed psql, backup-metadata and HTTP checks; and wrote the reports. Validation used actual direct-login identities, SQLSTATEs, catalogs, generated-ID mutations, transaction cleanup, reverse connections and authenticated controller responses. Source claims were not treated as test results. No human review is claimed.

The four Markdown reports, SQL scripts and sanitized evidence are saved in Group 5's Group 7 evaluation folder. External feedback, tracker edits, commits/pushes and a consolidated submission PDF were not part of this scoped task.
