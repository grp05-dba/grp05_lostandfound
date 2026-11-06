# Verification Report - Test and Verify Access Control

**Filename note:** The requested `part_d.md` records the assignment PDF's **Part E** tests. PDF Part D least privilege is in [part_cd.md](part_cd.md).

## 1. Executed scope and evidence

Executed **6 November 2026 (Asia/Manila)**, PostgreSQL **18.3**, database `boardtrack_g05_activity4`, endpoint `127.0.0.1:55411`. Each login was independently authenticated through SCRAM/psql TCP sessions; ordinary-role restrictions were not merely simulated by SET ROLE inside a superuser session.

**82 database checks passed.** This count includes allowed writes, privilege/connection denials, business-constraint denials, catalog/cleanup and boundary observations; it does not represent 82 separate product features. Exact SQL and expected/actual results are in [verification.json](evidence/verification.json). [verification.txt](evidence/verification.txt) contains actual psql output under the matching test-name marker.

Permission denials required SQLSTATE **42501** or explicit CONNECT rejection. Deliberate business-rule denials required their separate expected SQLSTATE. A syntax error or unrelated constraint failure was not accepted as a permission denial. `WHERE false` probes prove privilege checks, not successful changes to real rows; separate positive workflows changed real records and rolled back.

## 2. Complete database result matrix

| Test / evidence marker | Login account | SQL / operation | Expected | Actual | Result |
|---|---|---|---|---|---|
| `runtime-read-approved-tables` | `boardtrack_app` | `Full SQL in matching evidence marker` | Allowed | Succeeded | PASS |
| `runtime-positive-workflow` | `boardtrack_app` | `Full SQL in matching evidence marker` | Allowed | Succeeded | PASS |
| `runtime-read-v_lease_summary` | `boardtrack_app` | `SELECT count(*) FROM v_lease_summary;` | Allowed | Succeeded | PASS |
| `report-read-v_lease_summary` | `boardtrack_report` | `SELECT count(*) FROM v_lease_summary;` | Allowed | Succeeded | PASS |
| `report-deny-insert-property` | `boardtrack_report` | `BEGIN; INSERT INTO property DEFAULT VALUES; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-update-property` | `boardtrack_report` | `BEGIN; UPDATE property SET property_name=property_name WHERE false; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-delete-property` | `boardtrack_report` | `BEGIN; DELETE FROM property WHERE false; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-insert-room` | `boardtrack_report` | `BEGIN; INSERT INTO room DEFAULT VALUES; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-update-room` | `boardtrack_report` | `BEGIN; UPDATE room SET monthly_rate=monthly_rate WHERE false; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-delete-room` | `boardtrack_report` | `BEGIN; DELETE FROM room WHERE false; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-insert-tenant` | `boardtrack_report` | `BEGIN; INSERT INTO tenant DEFAULT VALUES; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-update-tenant` | `boardtrack_report` | `BEGIN; UPDATE tenant SET full_name=full_name WHERE false; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-delete-tenant` | `boardtrack_report` | `BEGIN; DELETE FROM tenant WHERE false; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-insert-lease` | `boardtrack_report` | `BEGIN; INSERT INTO lease DEFAULT VALUES; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-update-lease` | `boardtrack_report` | `BEGIN; UPDATE lease SET status=status WHERE false; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-delete-lease` | `boardtrack_report` | `BEGIN; DELETE FROM lease WHERE false; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-insert-payment` | `boardtrack_report` | `BEGIN; INSERT INTO payment DEFAULT VALUES; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-update-payment` | `boardtrack_report` | `BEGIN; UPDATE payment SET amount=amount WHERE false; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-delete-payment` | `boardtrack_report` | `BEGIN; DELETE FROM payment WHERE false; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-insert-utility_bill` | `boardtrack_report` | `BEGIN; INSERT INTO utility_bill DEFAULT VALUES; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-update-utility_bill` | `boardtrack_report` | `BEGIN; UPDATE utility_bill SET amount=amount WHERE false; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-delete-utility_bill` | `boardtrack_report` | `BEGIN; DELETE FROM utility_bill WHERE false; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-insert-app_user` | `boardtrack_report` | `BEGIN; INSERT INTO app_user DEFAULT VALUES; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-update-app_user` | `boardtrack_report` | `BEGIN; UPDATE app_user SET username=username WHERE false; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-delete-app_user` | `boardtrack_report` | `BEGIN; DELETE FROM app_user WHERE false; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-insert-schema_migrations` | `boardtrack_report` | `BEGIN; INSERT INTO schema_migrations DEFAULT VALUES; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-update-schema_migrations` | `boardtrack_report` | `BEGIN; UPDATE schema_migrations SET name=name WHERE false; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-delete-schema_migrations` | `boardtrack_report` | `BEGIN; DELETE FROM schema_migrations WHERE false; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `runtime-deny-insert-app_user` | `boardtrack_app` | `BEGIN; INSERT INTO app_user DEFAULT VALUES; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `runtime-deny-update-app_user` | `boardtrack_app` | `BEGIN; UPDATE app_user SET username=username WHERE false; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `runtime-deny-delete-app_user` | `boardtrack_app` | `BEGIN; DELETE FROM app_user WHERE false; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `runtime-deny-insert-schema_migrations` | `boardtrack_app` | `BEGIN; INSERT INTO schema_migrations DEFAULT VALUES; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `runtime-deny-update-schema_migrations` | `boardtrack_app` | `BEGIN; UPDATE schema_migrations SET name=name WHERE false; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `runtime-deny-delete-schema_migrations` | `boardtrack_app` | `BEGIN; DELETE FROM schema_migrations WHERE false; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `runtime-deny-migration-table` | `boardtrack_app` | `SELECT * FROM schema_migrations;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `runtime-deny-account-sequence` | `boardtrack_app` | `SELECT nextval('app_user_user_id_seq');` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-password-hash` | `boardtrack_report` | `SELECT password_hash FROM app_user;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-raw-tenant` | `boardtrack_report` | `SELECT * FROM tenant;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-crypt` | `boardtrack_report` | `SELECT crypt('public-probe','xx');` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `constraint-overlapping-lease` | `boardtrack_app` | `BEGIN; INSERT INTO lease(tenant_id,room_id,start_date,end_date,monthly_rent) VALUES(2,1,'2026-06-01','2026-12-01',100); ROLLBACK;` | Denied (23P01) | Denied 23P01 | PASS |
| `constraint-room-status` | `boardtrack_app` | `BEGIN; UPDATE room SET status='AVAILABLE' WHERE room_id=1; ROLLBACK;` | Denied (P0001) | Denied P0001 | PASS |
| `runtime-shared-account-boundary` | `boardtrack_app` | `SELECT count(*) AS all_tenant_rows FROM tenant;` | Allowed | Succeeded | PASS |
| `boardtrack_app-deny-createdb` | `boardtrack_app` | `CREATE DATABASE g05_forbidden;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `boardtrack_app-deny-createrole` | `boardtrack_app` | `CREATE ROLE g05_forbidden NOLOGIN;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `boardtrack_app-deny-connect-boardtrack_unrelated_lab` | `boardtrack_app` | `SELECT current_database();` | Denied (42501 / CONNECT) | CONNECT denied | PASS |
| `boardtrack_app-deny-connect-postgres` | `boardtrack_app` | `SELECT current_database();` | Denied (42501 / CONNECT) | CONNECT denied | PASS |
| `boardtrack_app-deny-connect-template1` | `boardtrack_app` | `SELECT current_database();` | Denied (42501 / CONNECT) | CONNECT denied | PASS |
| `boardtrack_report-deny-createdb` | `boardtrack_report` | `CREATE DATABASE g05_forbidden;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `boardtrack_report-deny-createrole` | `boardtrack_report` | `CREATE ROLE g05_forbidden NOLOGIN;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `boardtrack_report-deny-connect-boardtrack_unrelated_lab` | `boardtrack_report` | `SELECT current_database();` | Denied (42501 / CONNECT) | CONNECT denied | PASS |
| `boardtrack_report-deny-connect-postgres` | `boardtrack_report` | `SELECT current_database();` | Denied (42501 / CONNECT) | CONNECT denied | PASS |
| `boardtrack_report-deny-connect-template1` | `boardtrack_report` | `SELECT current_database();` | Denied (42501 / CONNECT) | CONNECT denied | PASS |
| `boardtrack_dba-deny-createdb` | `boardtrack_dba` | `CREATE DATABASE g05_forbidden;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `boardtrack_dba-deny-createrole` | `boardtrack_dba` | `CREATE ROLE g05_forbidden NOLOGIN;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `boardtrack_dba-deny-connect-boardtrack_unrelated_lab` | `boardtrack_dba` | `SELECT current_database();` | Denied (42501 / CONNECT) | CONNECT denied | PASS |
| `boardtrack_dba-deny-connect-postgres` | `boardtrack_dba` | `SELECT current_database();` | Denied (42501 / CONNECT) | CONNECT denied | PASS |
| `boardtrack_dba-deny-connect-template1` | `boardtrack_dba` | `SELECT current_database();` | Denied (42501 / CONNECT) | CONNECT denied | PASS |
| `boardtrack_app-deny-schema` | `boardtrack_app` | `BEGIN; CREATE SCHEMA g05_forbidden; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `boardtrack_app-deny-table` | `boardtrack_app` | `BEGIN; CREATE TABLE public.g05_forbidden(id int); ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `boardtrack_app-deny-owner` | `boardtrack_app` | `BEGIN; SET ROLE boardtrack_owner_grp; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `boardtrack_app-deny-truncate` | `boardtrack_app` | `BEGIN; TRUNCATE utility_bill; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `boardtrack_app-deny-alter` | `boardtrack_app` | `BEGIN; ALTER TABLE property ADD COLUMN g05_forbidden int; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `boardtrack_app-deny-sequence-reset` | `boardtrack_app` | `BEGIN; SELECT setval('property_property_id_seq',1); ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `boardtrack_report-deny-schema` | `boardtrack_report` | `BEGIN; CREATE SCHEMA g05_forbidden; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `boardtrack_report-deny-table` | `boardtrack_report` | `BEGIN; CREATE TABLE public.g05_forbidden(id int); ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `boardtrack_report-deny-owner` | `boardtrack_report` | `BEGIN; SET ROLE boardtrack_owner_grp; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `boardtrack_report-deny-truncate` | `boardtrack_report` | `BEGIN; TRUNCATE utility_bill; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `boardtrack_report-deny-alter` | `boardtrack_report` | `BEGIN; ALTER TABLE property ADD COLUMN g05_forbidden int; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `boardtrack_report-deny-sequence-reset` | `boardtrack_report` | `BEGIN; SELECT setval('property_property_id_seq',1); ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `runtime-deny-sequence-state` | `boardtrack_app` | `SELECT last_value FROM property_property_id_seq;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-sequence` | `boardtrack_report` | `SELECT nextval('property_property_id_seq');` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `runtime-deny-membership` | `boardtrack_app` | `GRANT boardtrack_runtime_grp TO boardtrack_report;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `admin-needs-owner-role` | `boardtrack_dba` | `BEGIN; CREATE TABLE public.g05_forbidden(id int); ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `admin-maintenance` | `boardtrack_dba` | `Full SQL in matching evidence marker` | Allowed | Succeeded | PASS |
| `admin-create-future-objects` | `boardtrack_dba` | `SET ROLE boardtrack_owner_grp; CREATE TABLE g05_future_probe(id serial PRIMARY KEY); CREATE FUNCTION g05_future_function() RETURNS int LANGUAGE sql AS 'SELECT 1';` | Allowed | Succeeded | PASS |
| `boardtrack_app-deny-future-table` | `boardtrack_app` | `SELECT * FROM g05_future_probe;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `boardtrack_app-deny-future-function` | `boardtrack_app` | `SELECT g05_future_function();` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `boardtrack_report-deny-future-table` | `boardtrack_report` | `SELECT * FROM g05_future_probe;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `boardtrack_report-deny-future-function` | `boardtrack_report` | `SELECT g05_future_function();` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `admin-future-use` | `boardtrack_dba` | `BEGIN; SET ROLE boardtrack_owner_grp; INSERT INTO g05_future_probe DEFAULT VALUES; SELECT g05_future_function(); ROLLBACK;` | Allowed | Succeeded | PASS |
| `admin-remove-future-objects` | `boardtrack_dba` | `SET ROLE boardtrack_owner_grp; DROP TABLE g05_future_probe; DROP FUNCTION g05_future_function();` | Allowed | Succeeded | PASS |
| `catalog-and-cleanup` | `lab_admin` | `Full SQL in matching evidence marker` | Allowed | Succeeded | PASS |

The positive runtime workflow created and updated all six business entities, then deleted the test rows in dependency order before rollback. Lease insertion changed the room to OCCUPIED; termination restored AVAILABLE. The summary view reflected payment 110 and utilities 25. Overlap returned 23P01 and contradictory room status returned P0001. Runtime app_user writes/ID sequence and schema_migrations access were denied. Reporting read the owner-rights view without base tenant/authentication access.

## 3. Memberships, ownership, default grants and isolation

[Catalog output](evidence/catalog.txt) records all six safe project roles, exactly three planned memberships with no ADMIN OPTION, database/schema/object ACLs, owner-group ownership, functions, triggers, extensions, constraints and default ACLs. Maintenance DDL without SET ROLE was denied; owner activation allowed CREATE/INSERT/ALTER/DROP and rollback.

All three logins were denied CONNECT to `boardtrack_unrelated_lab`, postgres and template1. Isolation is verified for this new dedicated cluster only. Existing services on other ports and remote hosts were not tested or changed.

Future-table/function tests created objects as the owner; runtime and reporting access was denied, maintenance owner access succeeded, and the probes were removed. This verifies effective restrictions after PUBLIC/default/member/ownership review. It does not promise future developers will never change grants.

## 4. Actual application checks using the restricted runtime login

**26 HTTP checks passed**, with Node.js 24.17.0 on loopback 18091. [HTTP evidence](evidence/application-tests.json), [sanitized startup](evidence/application-startup.txt) and [runtime identity](evidence/application-runtime.txt) support this result. Form data, cookies, CSRF tokens, passwords and authentication hashes were not copied into evidence. Locked dependencies were installed with scripts disabled. The runtime uses AUTO_SETUP=false; migrations were performed separately by provisioning.

| Check | Request | Expected HTTP | Actual HTTP | Result |
|---|---|---:|---:|---|
| unauthenticated-home | `GET /` | 302 | 302 | PASS |
| login-form-admin | `GET /login` | 200 | 200 | PASS |
| login-admin | `POST /login` | 302 | 302 | PASS |
| dashboard-admin | `GET /` | 200 | 200 | PASS |
| login-form-staff | `GET /login` | 200 | 200 | PASS |
| login-staff | `POST /login` | 302 | 302 | PASS |
| dashboard-staff | `GET /` | 200 | 200 | PASS |
| login-form-tenant | `GET /login` | 200 | 200 | PASS |
| login-tenant | `POST /login` | 302 | 302 | PASS |
| dashboard-tenant | `GET /` | 200 | 200 | PASS |
| admin-properties | `GET /properties` | 200 | 200 | PASS |
| admin-rooms | `GET /rooms` | 200 | 200 | PASS |
| admin-tenants | `GET /tenants` | 200 | 200 | PASS |
| admin-leases | `GET /leases` | 200 | 200 | PASS |
| admin-payments | `GET /payments` | 200 | 200 | PASS |
| admin-bills | `GET /bills` | 200 | 200 | PASS |
| tenant-own-leases | `GET /leases` | 200 | 200 | PASS |
| tenant-own-payments | `GET /payments` | 200 | 200 | PASS |
| tenant-own-bills | `GET /bills` | 200 | 200 | PASS |
| tenant-denied-properties | `GET /properties` | 403 | 403 | PASS |
| tenant-denied-rooms | `GET /rooms` | 403 | 403 | PASS |
| tenant-denied-tenants | `GET /tenants` | 403 | 403 | PASS |
| staff-denied-property-create | `POST /properties` | 403 | 403 | PASS |
| admin-property-create | `POST /properties` | 302 | 302 | PASS |
| admin-property-update | `POST /properties/4` | 302 | 302 | PASS |
| admin-property-delete | `POST /properties/4/delete` | 302 | 302 | PASS |

The checks cover all three demo logins/dashboard access, administrator business-page reads, tenant approved pages and forbidden pages, staff property-create denial, and actual administrator property create/update/delete. SQL checks confirmed the changed value and removed row. The database trigger and all-six-entity mutations were additionally exercised by the psql workflow.

No interactive browser testing, load/concurrency testing, full security audit, backup/recovery or every product workflow is claimed. The source has no npm test script; these direct tests are not an upstream test-suite claim.

## 5. Findings, cleanup and remaining responsibilities

| Finding | Evaluated resolution / remaining action |
|---|---|
| Default startup performs migrations | Provision first; set AUTO_SETUP=false and give runtime no DDL |
| Role document contains a blanket-grant sketch | Replace with exact runtime matrix, read-only summary view and owner separation |
| No own-project PDF; AI declaration still has completion placeholder | Report documentation gaps; no course submission completion claim |
| No npm test script | Independent SQL/HTTP checks supply evidence; no upstream automated suite claimed |
| Tenant SQL isolation is in application filters | Direct runtime can read all four tenant records; no RLS claim |
| Server source listens without explicit bind host | Local test preload forces loopback only; owning source unchanged |

The service-credential boundary is explicit: the runtime could directly read all four tenants, while tenant-specific visibility relies on server-side application filtering. No database-enforced per-end-user RLS or guarded-routine redesign was implemented or claimed.

SQL mutations rolled back; HTTP-created property rows were removed using the provisioning administrator only within this disposable database. [Final cleanup](evidence/final-cleanup.txt) verifies the original counts recorded in [Part A](part_a.md); temporary future objects are absent. Sequence increments are not transactional and were not reset. Application processes were stopped; the isolated database remains locally available.

**Owner feedback sent:** No. Findings are prepared here; no external message, issue or PR was posted. **Tracker, PDF and repository publication:** not performed in this scoped four-report task. These files provide inputs to those later submissions. Full course-wide Activity 4 completion is not claimed; Group 12 is not evaluated without a repository link.

**AI usage declaration:** OpenAI Codex read the assignment/reference reports, inspected the pinned repository, designed and applied the evaluated SQL, initialized the isolated cluster, executed separate-login psql checks and HTTP workflows, and wrote the reports. Output was validated against source operations, SQLSTATE/exit codes, actual generated-ID mutations, constraints/triggers, catalog ACLs/memberships/ownership, future-object behavior, HTTP responses, database effect checks and final row counts. No human validation is claimed. Real credentials and session tokens remain in private local/process configuration, outside Git and submissions.
