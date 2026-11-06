# Verification Report - Test and Verify Access Control

**Filename note:** `part_d.md` is the requested filename. It records the assignment PDF's **Part E** verification; PDF Part D is covered in [part_cd.md](part_cd.md).

## 1. Execution and evidence

Executed on **6 November 2026 (Asia/Manila)** using PostgreSQL **18.3** and independent, SCRAM-authenticated psql TCP connections to `127.0.0.1:55408`. Database: `canteen_g05_activity4`. The accounts were authenticated separately; runtime/reporting tests were not simulated solely by SET ROLE inside a superuser session. Maintenance uses its own authenticated connection and explicitly assumes the non-login owner role when required.

**82 database checks passed**, including positive operations, permission denials, isolation, metadata/cleanup checks and boundary observations. This total includes setup/observation checks, not 82 distinct business features. [verification.json](evidence/verification.json) stores the result matrix and exact SQL. [verification.txt](evidence/verification.txt) contains account, target database, statement, expected result, exit code and actual psql output under each matching test-name marker.

## 2. Complete database test matrix

Denied SQL operations required SQLSTATE **42501**, or an explicit CONNECT privilege denial for database connection tests. A syntax error, constraint error or empty successful query was not counted as a privilege denial. `WHERE false` probes establish privilege enforcement, not effects on populated records; the positive workflow performed actual changes under rollback.

| Test / evidence marker | Login | SQL or operation | Expected | Actual | Result |
|---|---|---|---|---|---|
| `runtime-read-seven-tables` | `canteen_app` | `Full SQL in evidence marker runtime-read-seven-tables` | Allowed | Succeeded | PASS |
| `runtime-generated-id-workflow` | `canteen_app` | `Full SQL in evidence marker runtime-generated-id-workflow` | Allowed | Succeeded | PASS |
| `runtime-menu-delete` | `canteen_app` | `BEGIN; INSERT INTO menu_item(vendor_id,item_name,price) SELECT min(vendor_id),'G05 delete probe',1 FROM vendor; DELETE FROM menu_item WHERE item_name='G05 delete probe'; ROLLBACK;` | Allowed | Succeeded | PASS |
| `readonly-sales-query` | `canteen_readonly` | `Full SQL in evidence marker readonly-sales-query` | Allowed | Succeeded | PASS |
| `readonly-deny-insert-student` | `canteen_readonly` | `BEGIN; INSERT INTO student DEFAULT VALUES; ROLLBACK;` | Denied | 42501 permission denied | PASS |
| `readonly-deny-update-student` | `canteen_readonly` | `BEGIN; UPDATE student SET full_name=full_name WHERE false; ROLLBACK;` | Denied | 42501 permission denied | PASS |
| `readonly-deny-delete-student` | `canteen_readonly` | `BEGIN; DELETE FROM student WHERE false; ROLLBACK;` | Denied | 42501 permission denied | PASS |
| `runtime-deny-delete-student` | `canteen_app` | `BEGIN; DELETE FROM student WHERE false; ROLLBACK;` | Denied | 42501 permission denied | PASS |
| `readonly-deny-insert-vendor` | `canteen_readonly` | `BEGIN; INSERT INTO vendor DEFAULT VALUES; ROLLBACK;` | Denied | 42501 permission denied | PASS |
| `readonly-deny-update-vendor` | `canteen_readonly` | `BEGIN; UPDATE vendor SET vendor_name=vendor_name WHERE false; ROLLBACK;` | Denied | 42501 permission denied | PASS |
| `readonly-deny-delete-vendor` | `canteen_readonly` | `BEGIN; DELETE FROM vendor WHERE false; ROLLBACK;` | Denied | 42501 permission denied | PASS |
| `runtime-deny-delete-vendor` | `canteen_app` | `BEGIN; DELETE FROM vendor WHERE false; ROLLBACK;` | Denied | 42501 permission denied | PASS |
| `readonly-deny-insert-menu_item` | `canteen_readonly` | `BEGIN; INSERT INTO menu_item DEFAULT VALUES; ROLLBACK;` | Denied | 42501 permission denied | PASS |
| `readonly-deny-update-menu_item` | `canteen_readonly` | `BEGIN; UPDATE menu_item SET item_name=item_name WHERE false; ROLLBACK;` | Denied | 42501 permission denied | PASS |
| `readonly-deny-delete-menu_item` | `canteen_readonly` | `BEGIN; DELETE FROM menu_item WHERE false; ROLLBACK;` | Denied | 42501 permission denied | PASS |
| `readonly-deny-insert-customer_order` | `canteen_readonly` | `BEGIN; INSERT INTO customer_order DEFAULT VALUES; ROLLBACK;` | Denied | 42501 permission denied | PASS |
| `readonly-deny-update-customer_order` | `canteen_readonly` | `BEGIN; UPDATE customer_order SET status=status WHERE false; ROLLBACK;` | Denied | 42501 permission denied | PASS |
| `readonly-deny-delete-customer_order` | `canteen_readonly` | `BEGIN; DELETE FROM customer_order WHERE false; ROLLBACK;` | Denied | 42501 permission denied | PASS |
| `runtime-deny-delete-customer_order` | `canteen_app` | `BEGIN; DELETE FROM customer_order WHERE false; ROLLBACK;` | Denied | 42501 permission denied | PASS |
| `readonly-deny-insert-order_item` | `canteen_readonly` | `BEGIN; INSERT INTO order_item DEFAULT VALUES; ROLLBACK;` | Denied | 42501 permission denied | PASS |
| `readonly-deny-update-order_item` | `canteen_readonly` | `BEGIN; UPDATE order_item SET quantity=quantity WHERE false; ROLLBACK;` | Denied | 42501 permission denied | PASS |
| `readonly-deny-delete-order_item` | `canteen_readonly` | `BEGIN; DELETE FROM order_item WHERE false; ROLLBACK;` | Denied | 42501 permission denied | PASS |
| `runtime-deny-delete-order_item` | `canteen_app` | `BEGIN; DELETE FROM order_item WHERE false; ROLLBACK;` | Denied | 42501 permission denied | PASS |
| `readonly-deny-insert-queue_entry` | `canteen_readonly` | `BEGIN; INSERT INTO queue_entry DEFAULT VALUES; ROLLBACK;` | Denied | 42501 permission denied | PASS |
| `readonly-deny-update-queue_entry` | `canteen_readonly` | `BEGIN; UPDATE queue_entry SET status=status WHERE false; ROLLBACK;` | Denied | 42501 permission denied | PASS |
| `readonly-deny-delete-queue_entry` | `canteen_readonly` | `BEGIN; DELETE FROM queue_entry WHERE false; ROLLBACK;` | Denied | 42501 permission denied | PASS |
| `runtime-deny-delete-queue_entry` | `canteen_app` | `BEGIN; DELETE FROM queue_entry WHERE false; ROLLBACK;` | Denied | 42501 permission denied | PASS |
| `readonly-deny-insert-notification` | `canteen_readonly` | `BEGIN; INSERT INTO notification DEFAULT VALUES; ROLLBACK;` | Denied | 42501 permission denied | PASS |
| `readonly-deny-update-notification` | `canteen_readonly` | `BEGIN; UPDATE notification SET message=message WHERE false; ROLLBACK;` | Denied | 42501 permission denied | PASS |
| `readonly-deny-delete-notification` | `canteen_readonly` | `BEGIN; DELETE FROM notification WHERE false; ROLLBACK;` | Denied | 42501 permission denied | PASS |
| `runtime-deny-delete-notification` | `canteen_app` | `BEGIN; DELETE FROM notification WHERE false; ROLLBACK;` | Denied | 42501 permission denied | PASS |
| `runtime-deny-update-student` | `canteen_app` | `BEGIN; UPDATE student SET full_name=full_name WHERE false; ROLLBACK;` | Denied | 42501 permission denied | PASS |
| `runtime-deny-update-order_item` | `canteen_app` | `BEGIN; UPDATE order_item SET quantity=quantity WHERE false; ROLLBACK;` | Denied | 42501 permission denied | PASS |
| `readonly-deny-student-data` | `canteen_readonly` | `SELECT full_name FROM student;` | Denied | 42501 permission denied | PASS |
| `readonly-deny-vendor-hash` | `canteen_readonly` | `SELECT password_hash FROM vendor;` | Denied | 42501 permission denied | PASS |
| `readonly-deny-vendor-contact` | `canteen_readonly` | `SELECT contact_number FROM vendor;` | Denied | 42501 permission denied | PASS |
| `readonly-deny-order-student` | `canteen_readonly` | `SELECT student_id FROM customer_order;` | Denied | 42501 permission denied | PASS |
| `readonly-deny-queue` | `canteen_readonly` | `SELECT * FROM queue_entry;` | Denied | 42501 permission denied | PASS |
| `readonly-deny-notification` | `canteen_readonly` | `SELECT * FROM notification;` | Denied | 42501 permission denied | PASS |
| `readonly-deny-whole-vendor` | `canteen_readonly` | `SELECT * FROM vendor;` | Denied | 42501 permission denied | PASS |
| `canteen_app-deny-createdb` | `canteen_app` | `CREATE DATABASE g05_forbidden;` | Denied | 42501 permission denied | PASS |
| `canteen_app-deny-createrole` | `canteen_app` | `CREATE ROLE g05_forbidden NOLOGIN;` | Denied | 42501 permission denied | PASS |
| `canteen_app-deny-connect-canteen_unrelated_lab` | `canteen_app` | `SELECT current_database();` | Denied | CONNECT denied | PASS |
| `canteen_app-deny-connect-postgres` | `canteen_app` | `SELECT current_database();` | Denied | CONNECT denied | PASS |
| `canteen_app-deny-connect-template1` | `canteen_app` | `SELECT current_database();` | Denied | CONNECT denied | PASS |
| `canteen_readonly-deny-createdb` | `canteen_readonly` | `CREATE DATABASE g05_forbidden;` | Denied | 42501 permission denied | PASS |
| `canteen_readonly-deny-createrole` | `canteen_readonly` | `CREATE ROLE g05_forbidden NOLOGIN;` | Denied | 42501 permission denied | PASS |
| `canteen_readonly-deny-connect-canteen_unrelated_lab` | `canteen_readonly` | `SELECT current_database();` | Denied | CONNECT denied | PASS |
| `canteen_readonly-deny-connect-postgres` | `canteen_readonly` | `SELECT current_database();` | Denied | CONNECT denied | PASS |
| `canteen_readonly-deny-connect-template1` | `canteen_readonly` | `SELECT current_database();` | Denied | CONNECT denied | PASS |
| `canteen_admin-deny-createdb` | `canteen_admin` | `CREATE DATABASE g05_forbidden;` | Denied | 42501 permission denied | PASS |
| `canteen_admin-deny-createrole` | `canteen_admin` | `CREATE ROLE g05_forbidden NOLOGIN;` | Denied | 42501 permission denied | PASS |
| `canteen_admin-deny-connect-canteen_unrelated_lab` | `canteen_admin` | `SELECT current_database();` | Denied | CONNECT denied | PASS |
| `canteen_admin-deny-connect-postgres` | `canteen_admin` | `SELECT current_database();` | Denied | CONNECT denied | PASS |
| `canteen_admin-deny-connect-template1` | `canteen_admin` | `SELECT current_database();` | Denied | CONNECT denied | PASS |
| `canteen_app-deny-schema` | `canteen_app` | `BEGIN; CREATE SCHEMA g05_forbidden; ROLLBACK;` | Denied | 42501 permission denied | PASS |
| `canteen_app-deny-table` | `canteen_app` | `BEGIN; CREATE TABLE public.g05_forbidden(id int); ROLLBACK;` | Denied | 42501 permission denied | PASS |
| `canteen_app-deny-owner` | `canteen_app` | `BEGIN; SET ROLE canteen_owner_grp; ROLLBACK;` | Denied | 42501 permission denied | PASS |
| `canteen_app-deny-truncate` | `canteen_app` | `BEGIN; TRUNCATE notification; ROLLBACK;` | Denied | 42501 permission denied | PASS |
| `canteen_app-deny-alter` | `canteen_app` | `BEGIN; ALTER TABLE menu_item ADD COLUMN g05_forbidden int; ROLLBACK;` | Denied | 42501 permission denied | PASS |
| `canteen_app-deny-sequence-reset` | `canteen_app` | `BEGIN; SELECT setval('menu_item_item_id_seq',1); ROLLBACK;` | Denied | 42501 permission denied | PASS |
| `canteen_readonly-deny-schema` | `canteen_readonly` | `BEGIN; CREATE SCHEMA g05_forbidden; ROLLBACK;` | Denied | 42501 permission denied | PASS |
| `canteen_readonly-deny-table` | `canteen_readonly` | `BEGIN; CREATE TABLE public.g05_forbidden(id int); ROLLBACK;` | Denied | 42501 permission denied | PASS |
| `canteen_readonly-deny-owner` | `canteen_readonly` | `BEGIN; SET ROLE canteen_owner_grp; ROLLBACK;` | Denied | 42501 permission denied | PASS |
| `canteen_readonly-deny-truncate` | `canteen_readonly` | `BEGIN; TRUNCATE notification; ROLLBACK;` | Denied | 42501 permission denied | PASS |
| `canteen_readonly-deny-alter` | `canteen_readonly` | `BEGIN; ALTER TABLE menu_item ADD COLUMN g05_forbidden int; ROLLBACK;` | Denied | 42501 permission denied | PASS |
| `canteen_readonly-deny-sequence-reset` | `canteen_readonly` | `BEGIN; SELECT setval('menu_item_item_id_seq',1); ROLLBACK;` | Denied | 42501 permission denied | PASS |
| `readonly-deny-nextval` | `canteen_readonly` | `SELECT nextval('menu_item_item_id_seq');` | Denied | 42501 permission denied | PASS |
| `runtime-deny-raw-sequence-read` | `canteen_app` | `SELECT last_value FROM menu_item_item_id_seq;` | Denied | 42501 permission denied | PASS |
| `runtime-deny-grant-membership` | `canteen_app` | `GRANT canteen_app_grp TO canteen_readonly;` | Denied | 42501 permission denied | PASS |
| `admin-requires-owner-role` | `canteen_admin` | `BEGIN; CREATE TABLE public.g05_forbidden(id int); ROLLBACK;` | Denied | 42501 permission denied | PASS |
| `admin-maintenance` | `canteen_admin` | `Full SQL in evidence marker admin-maintenance` | Allowed | Succeeded | PASS |
| `upstream-default-grant-observation` | `lab_admin` | `Full SQL in evidence marker upstream-default-grant-observation` | Allowed | Succeeded | PASS |
| `owner-create-future-objects` | `canteen_admin` | `SET ROLE canteen_owner_grp; CREATE TABLE public.g05_future_probe(id serial PRIMARY KEY,note text); CREATE FUNCTION public.g05_future_function() RETURNS integer LANGUAGE sql AS 'SELECT 1';` | Allowed | Succeeded | PASS |
| `canteen_app-deny-future-table` | `canteen_app` | `SELECT * FROM public.g05_future_probe;` | Denied | 42501 permission denied | PASS |
| `canteen_app-deny-future-function` | `canteen_app` | `SELECT public.g05_future_function();` | Denied | 42501 permission denied | PASS |
| `canteen_readonly-deny-future-table` | `canteen_readonly` | `SELECT * FROM public.g05_future_probe;` | Denied | 42501 permission denied | PASS |
| `canteen_readonly-deny-future-function` | `canteen_readonly` | `SELECT public.g05_future_function();` | Denied | 42501 permission denied | PASS |
| `admin-future-object-use` | `canteen_admin` | `BEGIN; SET ROLE canteen_owner_grp; INSERT INTO g05_future_probe(note) VALUES('probe'); SELECT g05_future_function(); ROLLBACK;` | Allowed | Succeeded | PASS |
| `owner-drop-future-probes` | `canteen_admin` | `SET ROLE canteen_owner_grp; DROP TABLE g05_future_probe; DROP FUNCTION g05_future_function();` | Allowed | Succeeded | PASS |
| `direct-sql-role-boundary` | `canteen_app` | `BEGIN; INSERT INTO student(full_name,email,password_hash,role) VALUES ('G05 boundary','g05-boundary@example.invalid','non-login-test-marker','ADMIN') RETURNING student_id,role; ROLLBACK;` | Allowed | Succeeded | PASS |
| `catalog-and-cleanup` | `lab_admin` | `Full SQL in evidence marker catalog-and-cleanup` | Allowed | Succeeded | PASS |

The complete generated-ID workflow inserted into all seven tables, updated vendor/menu/order/queue/notification rows, returned a captured order-line total of **20.00**, and rolled back. A separate menu test returned `DELETE 1` before rollback. Reporting's approved sales join succeeded; protected identity/hash/contact columns and all writes were rejected.

## 3. Ownership, isolation and future-object verification

[Catalog evidence](evidence/catalog.txt) records six safe project roles, precisely three planned memberships, no membership ADMIN OPTION, database/schema ACLs, owner-group ownership of all tables/sequences, reporting column grants, constraints and default ACLs. Maintenance DDL without SET ROLE was denied; with explicit owner activation, CREATE/INSERT/UPDATE/ALTER/DROP succeeded and rolled back. Ordinary logins could not create roles/databases or escalate to the owner group.

All three logins were denied CONNECT to `canteen_unrelated_lab`, `postgres` and `template1`. Isolation is claimed only for this dedicated lab's databases, not existing services or remote hosts.

A future SERIAL table and SQL function were created by the owner. Runtime and reporting access was denied; maintenance accessed both using the owner role, then removed them. The cleanup catalog confirms both objects are absent. The separate [upstream-default observation](evidence/upstream-defaults-observation.txt) returned runtime SELECT/INSERT/UPDATE = true/true/true for an upstream-default-created probe table. That experiment rolled back and did not alter the final evaluated ACLs.

## 4. Application validation with the restricted runtime login

The source built successfully with JDK 21 and Maven 3.9.15. Maven reported **No tests to run**. These direct HTTP checks, rather than a nonexistent upstream test suite, exercised the app on loopback port 18088. [Build output](evidence/build.txt), [sanitized startup output](evidence/application-startup.txt), [HTTP matrix](evidence/application-tests.json) and [database runtime identity](evidence/application-runtime.txt) provide evidence. Passwords, bearer tokens and response authentication payloads are omitted.

| Check | Request | Expected HTTP | Actual HTTP | Result |
|---|---|---:|---:|---|
| public-vendors | `GET /api/vendors` | 200 | 200 | PASS |
| login-student | `POST /api/auth/login` | 200 | 200 | PASS |
| login-other-student | `POST /api/auth/login` | 200 | 200 | PASS |
| login-vendor | `POST /api/auth/login` | 200 | 200 | PASS |
| login-other-vendor | `POST /api/auth/login` | 200 | 200 | PASS |
| login-admin | `POST /api/auth/login` | 200 | 200 | PASS |
| inactive-vendor-denied | `POST /api/auth/login` | 401 | 401 | PASS |
| unauthenticated-orders | `GET /api/orders` | 401 | 401 | PASS |
| student-denied-admin | `GET /api/admin/vendors` | 401 | 401 | PASS |
| vendor-denied-student | `GET /api/orders` | 401 | 401 | PASS |
| admin-vendors | `GET /api/admin/vendors` | 200 | 200 | PASS |
| vendor-menu | `GET /api/vendor/menu` | 200 | 200 | PASS |
| menu-create | `POST /api/vendor/menu` | 201 | 201 | PASS |
| menu-update | `PUT /api/vendor/menu/13` | 200 | 200 | PASS |
| menu-delete | `DELETE /api/vendor/menu/13` | 200 | 200 | PASS |
| student-place-order | `POST /api/orders` | 201 | 201 | PASS |
| student-own-order | `GET /api/orders/4` | 200 | 200 | PASS |
| other-student-order-denied | `GET /api/orders/4` | 404 | 404 | PASS |
| other-vendor-order-denied | `PATCH /api/vendor/orders/4/status` | 404 | 404 | PASS |
| vendor-status-preparing | `PATCH /api/vendor/orders/4/status` | 200 | 200 | PASS |
| vendor-status-ready | `PATCH /api/vendor/orders/4/status` | 200 | 200 | PASS |
| vendor-status-completed | `PATCH /api/vendor/orders/4/status` | 200 | 200 | PASS |
| completed-status-reversal-denied | `PATCH /api/vendor/orders/4/status` | 409 | 409 | PASS |
| student-notifications | `GET /api/notifications` | 200 | 200 | PASS |
| vendor-sales | `GET /api/vendor/reports/sales` | 200 | 200 | PASS |
| admin-sales | `GET /api/admin/reports/sales` | 200 | 200 | PASS |

The successful requests cover public stalls, five active sample-account logins, menu create/update/delete, student order placement, student/vendor ownership restrictions, forward order transitions, notifications and vendor/admin reports. Invalid route access and an inactive vendor were denied. No interactive browser or optional React-client validation is claimed.

**HTTP observation:** The first wrong-role probe expected 403 but received 401. The rerun records the observed 401 as an access denial; it does not relabel it as 403. Authorized requests using those same login roles succeeded. The reason for the status-code distinction was not established; owner feedback should request clear differentiation between unauthenticated and forbidden responses.

## 5. Security boundary, cleanup and limits

The runtime account can directly insert an `ADMIN` student record because student INSERT is needed for registration and no database column/row policy prevents that value. An actual rolled-back [boundary probe](evidence/runtime-role-boundary.txt) demonstrated it. This is documented as a service-credential trust boundary, not a test failure of the intentionally combined runtime matrix. API registration does not accept a role field; service credentials must never be given to ordinary students/vendors. If database-enforced per-user isolation is required, the owning group needs a reviewed RLS/guarded-routine design. No claim of that protection is made here.

SQL positive probes rolled back. The HTTP-created order and its dependent notification/queue/line records were removed from this disposable database by the provisioning administrator; the temporary menu item was deleted. [Final cleanup evidence](evidence/final-cleanup.txt) confirms the original **3 students, 4 vendors, 10 menu items, 2 orders, 2 lines, 2 queue entries and 3 notifications**. Generated sequence values advanced and were not reset. The HTTP service was stopped after validation.

Successful permission checks do not establish backup/recovery, load/concurrency correctness, every constraint edge case, all application features or production security. Future grants are explicit; privileged owners can still change ACLs by design. Existing services and other groups' repositories were not modified.

## 6. Findings and follow-up

| Finding | Evaluated action / remaining work |
|---|---|
| No own-project progress PDF in source; Maven has no test classes | Record gaps; these reports/evidence support later submission |
| Upstream future-table grants give broad automatic runtime access | Tested under rollback; final policy requires explicit migration grants |
| Upstream admin has CREATEROLE | Evaluated maintenance role has no cluster role/database creation; provisioning remains separate |
| Upstream cluster-wide PUBLIC CONNECT revoke can affect unrelated apps | Applied isolation only in a new dedicated cluster with inventory guard |
| Shared runtime can directly insert an ADMIN identity | Reproduced and rolled back; document credential boundary and recommend owner-reviewed controls if needed |
| Wrong-role HTTP response returned 401 rather than expected 403 | Access denied; exact observed code recorded, cause unconfirmed |

**Feedback sent to owners:** No. These findings are prepared locally; no external message, issue or PR was posted. **Tracker/PDF submission:** not performed in this scoped G08 four-report task. Full Activity 4 course submission is therefore not claimed.

**AI usage declaration:** OpenAI Codex read the assignment, inspected the pinned G08 source and Group 2 reference, designed the plan, initialized an isolated PostgreSQL cluster, authored/applied SQL, built the backend, executed independent-login permission checks and HTTP workflows, and wrote these reports. Validation used actual SQLSTATE/exit codes, live outputs, catalog ACLs/memberships/ownership, generated-ID writes, future-object probes, HTTP responses and cleanup counts. No human validation is claimed. The first HTTP status expectation was corrected to distinguish an observed denial from an assumed 403; the source was not modified to force the expected response.
