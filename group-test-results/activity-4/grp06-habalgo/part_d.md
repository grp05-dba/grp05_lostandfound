# Verification Report - Test and Verify Access Control

**Filename note:** this is the requested `part_d.md`. Verification is **Part E** in the Activity 4 PDF; least-privilege Part D is covered in [part_cd.md](part_cd.md).

## 1. Execution and overall result

Executed **6 November 2026 (Asia/Manila)** using PostgreSQL 18.6 and psql against `grp00_habalgodb`, schema `habalgo`, at `127.0.0.1:55432`.

**70/70 main privilege checks passed**, plus **8 future-object lifecycle checks** and **4 cross-project isolation/preservation checks**. PHP/API workflow checks also passed. This verifies the implemented role plan, not complete application security: unauthenticated API CRUD and database assignment/feedback consistency gaps remain unresolved and are documented below.

Each main test authenticated as its named login over TCP using a private local password. Identity checks confirmed both session/current user. App/auditor tests did not use superuser impersonation. DBA maintenance intentionally used its granted owner role. The runtime PHP environment was separately verified using the same connection configuration in a CLI PDO diagnostic.

SQL denials were checked for nonzero psql exit status and SQLSTATE `42501`. Initial connection denials do not print SQLSTATE in this client's output, so those checks used the nonzero connection exit status and explicit lack-of-CONNECT message. A zero exit status from a script containing expected failures is not treated as proof that all statements succeeded.

Evidence:

- [Executed setup SQL/output](evidence/setup.txt), [catalog and grants](evidence/catalog.txt), [SCRAM authentication configuration](evidence/authentication.txt).
- [Runtime](evidence/habalgo_app.txt), [auditor](evidence/habalgo_auditor.txt) and [DBA](evidence/habalgo_dba.txt) statements/output.
- [Per-case main results and full SQL](evidence/results.json).
- [Future objects](evidence/future_objects.txt), [reverse isolation/preservation](evidence/cross_project_isolation.txt), [business-rule gaps](evidence/business_rule_gaps.txt).
- [HTTP/API validation](evidence/application_validation.txt), [runtime diagnostic](evidence/application_runtime.txt), [development-server log](evidence/application_server.txt), [final cleanup](evidence/final_cleanup.txt).

## 2. Main verification matrix

Each row identifies its exact block in the relevant account's evidence file. Full multi-statement workflows are preserved in evidence, JSON and submitted verification SQL.

| Test | Account | Statement / operation | Expected | Actual | Status |
|---|---|---|---|---|---|
| `identity-habalgo_app` | `habalgo_app` | SELECT session_user, current_user, current_database() | Allowed | Succeeded | **PASS** |
| `read-habalgo_app` | `habalgo_app` | SELECT actual counts from all eight tables | Allowed | 10 drivers; all other table counts 0 | **PASS** |
| `identity-habalgo_auditor` | `habalgo_auditor` | SELECT session_user, current_user, current_database() | Allowed | Succeeded | **PASS** |
| `read-habalgo_auditor` | `habalgo_auditor` | SELECT actual counts from all eight tables | Allowed | 10 drivers; all other table counts 0 | **PASS** |
| `identity-habalgo_dba` | `habalgo_dba` | SELECT session_user, current_user, current_database() | Allowed | Succeeded | **PASS** |
| `read-habalgo_dba` | `habalgo_dba` | SELECT actual counts from all eight tables | Allowed | 10 drivers; all other table counts 0 | **PASS** |
| `runtime-full-workflow` | `habalgo_app` | Actual customer, vehicle, assignment, locations, booking, payment and rating workflow; update/delete permitted records; ROLLBACK | Allowed | All allowed operations succeeded; amount 175.00; baseline restored | **PASS** |
| `runtime-deny-driver-insert` | `habalgo_app` | BEGIN; INSERT INTO habalgo.driver(name,phone,license_no) VALUES ('E4 forbidden','09000000000','E4-FORBIDDEN'); ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `runtime-deny-driver-update` | `habalgo_app` | BEGIN; UPDATE habalgo.driver SET name=name WHERE driver_id=1; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `runtime-deny-driver-delete` | `habalgo_app` | BEGIN; DELETE FROM habalgo.driver WHERE driver_id=1; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `runtime-deny-location-update` | `habalgo_app` | BEGIN; UPDATE habalgo.location SET address=address WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `runtime-deny-location-delete` | `habalgo_app` | BEGIN; DELETE FROM habalgo.location WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `runtime-deny-truncate` | `habalgo_app` | BEGIN; TRUNCATE habalgo.payment; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `runtime-deny-create-table` | `habalgo_app` | BEGIN; CREATE TABLE habalgo.e4_forbidden(id integer); ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `runtime-deny-create-schema` | `habalgo_app` | BEGIN; CREATE SCHEMA e4_forbidden; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `runtime-deny-public-create` | `habalgo_app` | BEGIN; CREATE TABLE public.e4_forbidden(id integer); ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `runtime-deny-create-temp` | `habalgo_app` | BEGIN; CREATE TEMP TABLE e4_forbidden(id integer); ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `runtime-deny-alter-table` | `habalgo_app` | BEGIN; ALTER TABLE habalgo.customer ADD COLUMN e4_forbidden integer; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `runtime-deny-driver-sequence` | `habalgo_app` | BEGIN; SELECT nextval('habalgo.driver_driver_id_seq'); ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `runtime-deny-sequence-reset` | `habalgo_app` | BEGIN; SELECT setval('habalgo.booking_booking_id_seq',1); ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `runtime-deny-owner-escalation` | `habalgo_app` | BEGIN; SET ROLE habalgo_owner_grp; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `auditor-deny-insert-customer` | `habalgo_auditor` | BEGIN; INSERT INTO habalgo.customer DEFAULT VALUES; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `auditor-deny-update-customer` | `habalgo_auditor` | BEGIN; UPDATE habalgo.customer SET name=name WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `auditor-deny-delete-customer` | `habalgo_auditor` | BEGIN; DELETE FROM habalgo.customer WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `auditor-deny-insert-driver` | `habalgo_auditor` | BEGIN; INSERT INTO habalgo.driver DEFAULT VALUES; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `auditor-deny-update-driver` | `habalgo_auditor` | BEGIN; UPDATE habalgo.driver SET name=name WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `auditor-deny-delete-driver` | `habalgo_auditor` | BEGIN; DELETE FROM habalgo.driver WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `auditor-deny-insert-vehicle` | `habalgo_auditor` | BEGIN; INSERT INTO habalgo.vehicle DEFAULT VALUES; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `auditor-deny-update-vehicle` | `habalgo_auditor` | BEGIN; UPDATE habalgo.vehicle SET model=model WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `auditor-deny-delete-vehicle` | `habalgo_auditor` | BEGIN; DELETE FROM habalgo.vehicle WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `auditor-deny-insert-driver_vehicle` | `habalgo_auditor` | BEGIN; INSERT INTO habalgo.driver_vehicle DEFAULT VALUES; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `auditor-deny-update-driver_vehicle` | `habalgo_auditor` | BEGIN; UPDATE habalgo.driver_vehicle SET assigned_from=assigned_from WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `auditor-deny-delete-driver_vehicle` | `habalgo_auditor` | BEGIN; DELETE FROM habalgo.driver_vehicle WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `auditor-deny-insert-location` | `habalgo_auditor` | BEGIN; INSERT INTO habalgo.location DEFAULT VALUES; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `auditor-deny-update-location` | `habalgo_auditor` | BEGIN; UPDATE habalgo.location SET address=address WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `auditor-deny-delete-location` | `habalgo_auditor` | BEGIN; DELETE FROM habalgo.location WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `auditor-deny-insert-booking` | `habalgo_auditor` | BEGIN; INSERT INTO habalgo.booking DEFAULT VALUES; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `auditor-deny-update-booking` | `habalgo_auditor` | BEGIN; UPDATE habalgo.booking SET booking_status=booking_status WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `auditor-deny-delete-booking` | `habalgo_auditor` | BEGIN; DELETE FROM habalgo.booking WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `auditor-deny-insert-payment` | `habalgo_auditor` | BEGIN; INSERT INTO habalgo.payment DEFAULT VALUES; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `auditor-deny-update-payment` | `habalgo_auditor` | BEGIN; UPDATE habalgo.payment SET amount=amount WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `auditor-deny-delete-payment` | `habalgo_auditor` | BEGIN; DELETE FROM habalgo.payment WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `auditor-deny-insert-rating_feedback` | `habalgo_auditor` | BEGIN; INSERT INTO habalgo.rating_feedback DEFAULT VALUES; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `auditor-deny-update-rating_feedback` | `habalgo_auditor` | BEGIN; UPDATE habalgo.rating_feedback SET rating=rating WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `auditor-deny-delete-rating_feedback` | `habalgo_auditor` | BEGIN; DELETE FROM habalgo.rating_feedback WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `auditor-deny-sequence` | `habalgo_auditor` | SELECT nextval('habalgo.customer_customer_id_seq'); | Denied | Permission error 42501 | **PASS** |
| `auditor-deny-create` | `habalgo_auditor` | BEGIN; CREATE TABLE habalgo.e4_forbidden(id integer); ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `auditor-deny-owner` | `habalgo_auditor` | SET ROLE habalgo_owner_grp; | Denied | Permission error 42501 | **PASS** |
| `dba-maintenance` | `habalgo_dba` | SET ROLE owner; insert driver; ALTER table; CREATE/DROP probe; ROLLBACK | Allowed | INSERT/ALTER/CREATE/DROP succeeded; probes removed | **PASS** |
| `deny-createdb-habalgo_app` | `habalgo_app` | CREATE DATABASE habalgo_e4_forbidden; | Denied | Permission error 42501 | **PASS** |
| `deny-createrole-habalgo_app` | `habalgo_app` | CREATE ROLE habalgo_e4_forbidden NOLOGIN; | Denied | Permission error 42501 | **PASS** |
| `isolation-habalgo_app-habalgo_unrelateddb` | `habalgo_app` | Connect to `habalgo_unrelateddb` and attempt SELECT current_database() | Denied | Connection rejected: lacks CONNECT | **PASS** |
| `isolation-habalgo_app-grp_brewposdb` | `habalgo_app` | Connect to `grp_brewposdb` and attempt SELECT current_database() | Denied | Connection rejected: lacks CONNECT | **PASS** |
| `isolation-habalgo_app-brewpos_unrelateddb` | `habalgo_app` | Connect to `brewpos_unrelateddb` and attempt SELECT current_database() | Denied | Connection rejected: lacks CONNECT | **PASS** |
| `isolation-habalgo_app-postgres` | `habalgo_app` | Connect to `postgres` and attempt SELECT current_database() | Denied | Connection rejected: lacks CONNECT | **PASS** |
| `isolation-habalgo_app-template1` | `habalgo_app` | Connect to `template1` and attempt SELECT current_database() | Denied | Connection rejected: lacks CONNECT | **PASS** |
| `deny-createdb-habalgo_auditor` | `habalgo_auditor` | CREATE DATABASE habalgo_e4_forbidden; | Denied | Permission error 42501 | **PASS** |
| `deny-createrole-habalgo_auditor` | `habalgo_auditor` | CREATE ROLE habalgo_e4_forbidden NOLOGIN; | Denied | Permission error 42501 | **PASS** |
| `isolation-habalgo_auditor-habalgo_unrelateddb` | `habalgo_auditor` | Connect to `habalgo_unrelateddb` and attempt SELECT current_database() | Denied | Connection rejected: lacks CONNECT | **PASS** |
| `isolation-habalgo_auditor-grp_brewposdb` | `habalgo_auditor` | Connect to `grp_brewposdb` and attempt SELECT current_database() | Denied | Connection rejected: lacks CONNECT | **PASS** |
| `isolation-habalgo_auditor-brewpos_unrelateddb` | `habalgo_auditor` | Connect to `brewpos_unrelateddb` and attempt SELECT current_database() | Denied | Connection rejected: lacks CONNECT | **PASS** |
| `isolation-habalgo_auditor-postgres` | `habalgo_auditor` | Connect to `postgres` and attempt SELECT current_database() | Denied | Connection rejected: lacks CONNECT | **PASS** |
| `isolation-habalgo_auditor-template1` | `habalgo_auditor` | Connect to `template1` and attempt SELECT current_database() | Denied | Connection rejected: lacks CONNECT | **PASS** |
| `deny-createdb-habalgo_dba` | `habalgo_dba` | CREATE DATABASE habalgo_e4_forbidden; | Denied | Permission error 42501 | **PASS** |
| `deny-createrole-habalgo_dba` | `habalgo_dba` | CREATE ROLE habalgo_e4_forbidden NOLOGIN; | Denied | Permission error 42501 | **PASS** |
| `isolation-habalgo_dba-habalgo_unrelateddb` | `habalgo_dba` | Connect to `habalgo_unrelateddb` and attempt SELECT current_database() | Denied | Connection rejected: lacks CONNECT | **PASS** |
| `isolation-habalgo_dba-grp_brewposdb` | `habalgo_dba` | Connect to `grp_brewposdb` and attempt SELECT current_database() | Denied | Connection rejected: lacks CONNECT | **PASS** |
| `isolation-habalgo_dba-brewpos_unrelateddb` | `habalgo_dba` | Connect to `brewpos_unrelateddb` and attempt SELECT current_database() | Denied | Connection rejected: lacks CONNECT | **PASS** |
| `isolation-habalgo_dba-postgres` | `habalgo_dba` | Connect to `postgres` and attempt SELECT current_database() | Denied | Connection rejected: lacks CONNECT | **PASS** |
| `isolation-habalgo_dba-template1` | `habalgo_dba` | Connect to `template1` and attempt SELECT current_database() | Denied | Connection rejected: lacks CONNECT | **PASS** |

## 3. Allowed operations and cleanup evidence

The runtime workflow inserted a customer, vehicle, driver assignment, two locations, completed booking, payment and feedback with generated IDs. It updated the six writable entity types, selected the joined result, deleted the permitted temporary entities in child-to-parent order, then rolled the whole transaction back. The joined output contained payment amount `175.00` and rating `4`. This tests actual row writes, not solely empty-table privilege checks. The six required SERIAL sequences were exercised by those inserts.

Driver provisioning was tested separately through a DBA INSERT under the owner role. The DBA also altered a table and created/dropped a temporary test table in a rollback transaction. The runtime was denied the same administrative operations.

Auditor INSERT/UPDATE/DELETE was attempted on every table. Its UPDATE/DELETE statements use `WHERE false` to establish permission rejection without changing records. Denied operations reported SQLSTATE `42501`, not a missing-column or foreign-key error. Runtime driver/location restrictions, sequence reset, ownership escalation, temporary table creation and DDL also failed with permission errors.

Post-test baseline:

```text
customer driver vehicle driver_vehicle location booking payment rating_feedback
       0     10       0              0        0       0       0               0
```

Probe tables and forbidden database/role names were absent. All marked HTTP data and unused HTTP pickup/dropoff locations were removed. SERIAL increments are not rolled back and were not reset, so later generated IDs are expected to contain gaps. No persistent edits were made to the ten supplied drivers.

## 4. Database isolation, PUBLIC and future objects

All three Group 6 logins were actually denied connections to `habalgo_unrelateddb`, `grp_brewposdb`, `brewpos_unrelateddb`, `postgres` and `template1`. Representative output:

```text
FATAL: permission denied for database "grp_brewposdb"
DETAIL: User does not have CONNECT privilege.
```

Three reverse tests confirmed that the Group 4 runtime, auditor and DBA cannot connect to `grp00_habalgodb`. A fourth additional test confirmed the Group 4 runtime still connects to its own database. This tests both isolation and preservation of legitimate existing access. The user's other PostgreSQL instance on port 5432 was not tested or changed.

Catalog results confirmed all eight tables and seven sequences are owned by `habalgo_owner_grp`. Runtime/auditor own none of these objects and inherit no owner role. Each login has only its assigned group, with no ADMIN OPTION and no elevated attributes. PUBLIC database/schema/object ACLs were reviewed alongside direct grants and memberships. The `public` schema is not an alternate route for runtime DDL.

Eight additional future-object lifecycle checks:

| Operation | Actual |
|---|---|
| Owner creates new serial-key table and SQL function | Allowed |
| Runtime SELECT new table | Denied, 42501 |
| Runtime execute new function | Denied, 42501 |
| Auditor SELECT new table | Denied, 42501 |
| Auditor execute new function | Denied, 42501 |
| DBA uses owner role to INSERT and execute the function | Allowed; data rolled back |
| Owner drops both probes | Allowed |
| Verify both probes absent | Both true |

No blanket future table/sequence grants are applied. PUBLIC EXECUTE is removed for future functions created by the designated owner. Other creators require their own defaults reviewed; defaults do not automatically apply to every role.

## 5. Application validation

The unmodified source ran on PHP 8.2.12 with PDO_PGSQL, using `habalgo_app` and private environment configuration. No authentication cookie, session or authorization header was supplied during the following HTTP operations:

| Test | Actual result |
|---|---|
| Landing page and dashboard | HTTP 200 |
| Options and all five entity lists | HTTP 200; 10 drivers; initially empty entity lists |
| Unknown resource | HTTP 404 |
| Create customer and vehicle with driver assignment | Successful JSON responses |
| Create booking with driver while requesting Pending | API automatically changed status to Confirmed |
| Rate non-completed booking | HTTP 400 with the completed-booking restriction |
| Complete booking; create payment and rating | Successful JSON responses |
| Update customer/vehicle/payment/rating | Successful; rating PUT included booking_id as required by the API |
| Dashboard after updates | 1 customer, revenue 175, average rating 4 |
| Delete rating/payment/booking/vehicle/customer | Successful; vehicle path also removed driver assignment |
| Provisioning cleanup of unused test locations and final counts | Original driver-only baseline restored |

HTTP create responses use the application's existing HTTP 200 convention; no HTTP 201 is claimed. The separate [PDO diagnostic](evidence/application_runtime.txt) confirmed `session_user = current_user = habalgo_app` and `current_database = grp00_habalgodb` with the same environment/configuration as the server. These are API and CLI checks, not interactive browser testing or an upstream automated test suite.

## 6. Unresolved findings and owner feedback draft

### 6.1 Missing web authentication and authorization

The reviewed API does not authenticate HTTP callers or check a role before CRUD. The successful no-credential HTTP write tests confirm this scope. Separate PostgreSQL logins constrain service/inspection/DBA access, but do not distinguish individual web customers, drivers or staff. Recommended owner work: add authenticated identities and server-side authorization before exposing operational writes beyond this local demonstration.

### 6.2 Multiple active drivers for one vehicle

An actual runtime transaction inserted two different drivers for the same vehicle with `assigned_to IS NULL`. `INSERT 0 2` succeeded and the active-assignment count was **2**. The composite primary key only prevents duplicate driver/vehicle pairs; it does not enforce one active driver per vehicle.

PHP's `assign()` helper closes other active assignments during normal vehicle handling, but that behavior is not a standalone database invariant. Recommended owner work is to confirm the intended assignment rule and enforce it with suitable uniqueness/transactional concurrency controls. No new constraint was added during this evaluation.

### 6.3 Feedback consistency enforced only in PHP

The same direct-login probe created a Pending booking for one customer and inserted a rating belonging to another customer. PostgreSQL accepted it; the selected result showed `booking_status = Pending` and `mismatched_customer = t`. Independent valid foreign keys do not establish that the rating customer owns that booking, nor that the booking is Completed.

PHP normally rejects non-completed bookings and derives the feedback customer from the booking; that rejection was verified through HTTP. Direct SQL using the permitted service account bypasses those application rules. Recommended owner work is to add appropriate database-level consistency enforcement if those are required invariants, while preserving valid application operations. All business-gap probe rows were rolled back.

### 6.4 Setup and role-script corrections

Recommended documentation fixes: explain that PHP needs exported/process environment variables or an actual loader; align the password key with `DB_PASS`; align the default database with the documented database; fix the malformed clone command; distinguish the two seed files; and replace committed fixed password literals with local credential provisioning. The broader generic-group/blanket-future-grant role script was not run in this evaluation.

**Feedback sent to owners: No.** Findings are prepared for review; no issue, message or pull request was posted. No class tracker or consolidated PDF submission was changed. All evaluation changes are local to Group 5's Group 6 result folder, not the owning project's tracked source.

## 7. Limits and AI usage

The tested privilege plan and specified isolation paths passed. The application is not declared production-secure because the unresolved findings above remain. Tests do not establish backup/recovery, production concurrency, all constraint edge cases, remote-host authentication, or every possible browser workflow. Base demo tables are mostly empty, but transaction and HTTP tests inserted and modified real synthetic records to exercise their required permissions.

**AI usage declaration:** OpenAI Codex reviewed the Activity 4 assignment and upstream source; designed and executed the SQL; configured the isolated database and PHP process; performed psql/HTTP tests; and wrote these reports. Validation used actual direct-account results, SQLSTATE errors, ACL/ownership/membership catalogs, generated-ID operations, rollback/final-cleanup checks, cross-project connections and actual API responses. AI output was checked against source rather than treated as evidence by itself. No human review is claimed. The HTTP rating-update request was aligned with the actual API's requirement to include booking_id before recording the successful workflow.

No generated passwords, upstream fixed password values or password hashes are reproduced in the deliverables. Ordinary application access uses the dedicated runtime account. Full course submission, external feedback and publication remain outside this four-report task.
