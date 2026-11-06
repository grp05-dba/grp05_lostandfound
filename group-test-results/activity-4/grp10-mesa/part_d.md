# Verification Report - Test and Verify Access Control

**Filename note:** The requested `part_d.md` records the assignment PDF's **Part E** tests. PDF Part D least privilege is in [part_cd.md](part_cd.md).

## 1. Executed scope and evidence

Executed **6 November 2026 (Asia/Manila)**, PostgreSQL **18.3**, database `mesa_g05_activity4`, endpoint `127.0.0.1:55410`. Each login was independently authenticated through SCRAM/psql TCP sessions; ordinary-role restrictions were not merely simulated by SET ROLE inside a superuser session.

**84 database checks passed.** This count includes allowed writes, privilege/connection denials, business-constraint denials, catalog/cleanup and boundary observations; it does not represent 84 separate product features. Exact SQL and expected/actual results are in [verification.json](evidence/verification.json). [verification.txt](evidence/verification.txt) contains actual psql output under the matching test-name marker.

Permission denials required SQLSTATE **42501** or explicit CONNECT rejection. Deliberate business-rule denials required their separate expected SQLSTATE. A syntax error or unrelated constraint failure was not accepted as a permission denial. `WHERE false` probes prove privilege checks, not successful changes to real rows; separate positive workflows changed real records and rolled back.

## 2. Complete database result matrix

| Test / evidence marker | Login account | SQL / operation | Expected | Actual | Result |
|---|---|---|---|---|---|
| `runtime-read-approved-tables` | `rors_app` | `Full SQL in matching evidence marker` | Allowed | Succeeded | PASS |
| `runtime-positive-workflow` | `rors_app` | `Full SQL in matching evidence marker` | Allowed | Succeeded | PASS |
| `runtime-read-v_order_summary` | `rors_app` | `SELECT count(*) FROM v_order_summary;` | Allowed | Succeeded | PASS |
| `runtime-read-v_reservation_schedule` | `rors_app` | `SELECT count(*) FROM v_reservation_schedule;` | Allowed | Succeeded | PASS |
| `report-read-v_customer_directory` | `rors_report` | `SELECT count(*) FROM v_customer_directory;` | Allowed | Succeeded | PASS |
| `report-read-v_staff_directory` | `rors_report` | `SELECT count(*) FROM v_staff_directory;` | Allowed | Succeeded | PASS |
| `report-read-v_order_summary` | `rors_report` | `SELECT count(*) FROM v_order_summary;` | Allowed | Succeeded | PASS |
| `report-read-v_reservation_schedule` | `rors_report` | `SELECT count(*) FROM v_reservation_schedule;` | Allowed | Succeeded | PASS |
| `report-deny-insert-customer` | `rors_report` | `BEGIN; INSERT INTO customer DEFAULT VALUES; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-update-customer` | `rors_report` | `BEGIN; UPDATE customer SET first_name=first_name WHERE false; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-delete-customer` | `rors_report` | `BEGIN; DELETE FROM customer WHERE false; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-insert-staff` | `rors_report` | `BEGIN; INSERT INTO staff DEFAULT VALUES; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-update-staff` | `rors_report` | `BEGIN; UPDATE staff SET first_name=first_name WHERE false; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-delete-staff` | `rors_report` | `BEGIN; DELETE FROM staff WHERE false; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-insert-menu_item` | `rors_report` | `BEGIN; INSERT INTO menu_item DEFAULT VALUES; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-update-menu_item` | `rors_report` | `BEGIN; UPDATE menu_item SET item_name=item_name WHERE false; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-delete-menu_item` | `rors_report` | `BEGIN; DELETE FROM menu_item WHERE false; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-insert-restaurant_table` | `rors_report` | `BEGIN; INSERT INTO restaurant_table DEFAULT VALUES; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-update-restaurant_table` | `rors_report` | `BEGIN; UPDATE restaurant_table SET status=status WHERE false; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-delete-restaurant_table` | `rors_report` | `BEGIN; DELETE FROM restaurant_table WHERE false; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-insert-orders` | `rors_report` | `BEGIN; INSERT INTO orders DEFAULT VALUES; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-update-orders` | `rors_report` | `BEGIN; UPDATE orders SET order_status=order_status WHERE false; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-delete-orders` | `rors_report` | `BEGIN; DELETE FROM orders WHERE false; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-insert-order_item` | `rors_report` | `BEGIN; INSERT INTO order_item DEFAULT VALUES; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-update-order_item` | `rors_report` | `BEGIN; UPDATE order_item SET quantity=quantity WHERE false; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-delete-order_item` | `rors_report` | `BEGIN; DELETE FROM order_item WHERE false; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-insert-reservation` | `rors_report` | `BEGIN; INSERT INTO reservation DEFAULT VALUES; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-update-reservation` | `rors_report` | `BEGIN; UPDATE reservation SET reservation_status=reservation_status WHERE false; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-delete-reservation` | `rors_report` | `BEGIN; DELETE FROM reservation WHERE false; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-insert-payment` | `rors_report` | `BEGIN; INSERT INTO payment DEFAULT VALUES; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-update-payment` | `rors_report` | `BEGIN; UPDATE payment SET amount=amount WHERE false; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-delete-payment` | `rors_report` | `BEGIN; DELETE FROM payment WHERE false; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `runtime-deny-delete-customer` | `rors_app` | `BEGIN; DELETE FROM customer WHERE false; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `runtime-deny-delete-orders` | `rors_app` | `BEGIN; DELETE FROM orders WHERE false; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `runtime-deny-delete-payment` | `rors_app` | `BEGIN; DELETE FROM payment WHERE false; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `runtime-deny-delete-order_item` | `rors_app` | `BEGIN; DELETE FROM order_item WHERE false; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `runtime-deny-update-order-item` | `rors_app` | `BEGIN; UPDATE order_item SET quantity=quantity WHERE false; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-customer-credentials` | `rors_report` | `SELECT password FROM customer;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-staff-credentials` | `rors_report` | `SELECT password FROM staff;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `runtime-menu-delete` | `rors_app` | `BEGIN; INSERT INTO menu_item(item_name,category,price) VALUES('G05 delete probe','Probe',1); DELETE FROM menu_item WHERE item_name='G05 delete probe'; ROLLBACK;` | Allowed | Succeeded | PASS |
| `constraint-negative-price` | `rors_app` | `BEGIN; INSERT INTO menu_item(item_name,category,price) VALUES('G05 invalid probe','Probe',-1); ROLLBACK;` | Denied (23514) | Denied 23514 | PASS |
| `constraint-empty-order` | `rors_app` | `BEGIN; INSERT INTO orders(customer_id) SELECT min(customer_id) FROM customer; COMMIT;` | Denied (23514) | Denied 23514 | PASS |
| `constraint-reservation-overlap` | `rors_app` | `Full SQL in matching evidence marker` | Denied (23P01) | Denied 23P01 | PASS |
| `runtime-shared-account-boundary` | `rors_app` | `BEGIN; UPDATE staff SET role='admin' WHERE email='staff@rors.example'; ROLLBACK;` | Allowed | Succeeded | PASS |
| `rors_app-deny-createdb` | `rors_app` | `CREATE DATABASE g05_forbidden;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `rors_app-deny-createrole` | `rors_app` | `CREATE ROLE g05_forbidden NOLOGIN;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `rors_app-deny-connect-rors_unrelated_lab` | `rors_app` | `SELECT current_database();` | Denied (42501 / CONNECT) | CONNECT denied | PASS |
| `rors_app-deny-connect-postgres` | `rors_app` | `SELECT current_database();` | Denied (42501 / CONNECT) | CONNECT denied | PASS |
| `rors_app-deny-connect-template1` | `rors_app` | `SELECT current_database();` | Denied (42501 / CONNECT) | CONNECT denied | PASS |
| `rors_report-deny-createdb` | `rors_report` | `CREATE DATABASE g05_forbidden;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `rors_report-deny-createrole` | `rors_report` | `CREATE ROLE g05_forbidden NOLOGIN;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `rors_report-deny-connect-rors_unrelated_lab` | `rors_report` | `SELECT current_database();` | Denied (42501 / CONNECT) | CONNECT denied | PASS |
| `rors_report-deny-connect-postgres` | `rors_report` | `SELECT current_database();` | Denied (42501 / CONNECT) | CONNECT denied | PASS |
| `rors_report-deny-connect-template1` | `rors_report` | `SELECT current_database();` | Denied (42501 / CONNECT) | CONNECT denied | PASS |
| `rors_dba-deny-createdb` | `rors_dba` | `CREATE DATABASE g05_forbidden;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `rors_dba-deny-createrole` | `rors_dba` | `CREATE ROLE g05_forbidden NOLOGIN;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `rors_dba-deny-connect-rors_unrelated_lab` | `rors_dba` | `SELECT current_database();` | Denied (42501 / CONNECT) | CONNECT denied | PASS |
| `rors_dba-deny-connect-postgres` | `rors_dba` | `SELECT current_database();` | Denied (42501 / CONNECT) | CONNECT denied | PASS |
| `rors_dba-deny-connect-template1` | `rors_dba` | `SELECT current_database();` | Denied (42501 / CONNECT) | CONNECT denied | PASS |
| `rors_app-deny-schema` | `rors_app` | `BEGIN; CREATE SCHEMA g05_forbidden; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `rors_app-deny-table` | `rors_app` | `BEGIN; CREATE TABLE public.g05_forbidden(id int); ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `rors_app-deny-owner` | `rors_app` | `BEGIN; SET ROLE rors_owner_grp; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `rors_app-deny-truncate` | `rors_app` | `BEGIN; TRUNCATE payment; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `rors_app-deny-alter` | `rors_app` | `BEGIN; ALTER TABLE customer ADD COLUMN g05_forbidden int; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `rors_app-deny-sequence-reset` | `rors_app` | `BEGIN; SELECT setval('customer_customer_id_seq',1); ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `rors_report-deny-schema` | `rors_report` | `BEGIN; CREATE SCHEMA g05_forbidden; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `rors_report-deny-table` | `rors_report` | `BEGIN; CREATE TABLE public.g05_forbidden(id int); ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `rors_report-deny-owner` | `rors_report` | `BEGIN; SET ROLE rors_owner_grp; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `rors_report-deny-truncate` | `rors_report` | `BEGIN; TRUNCATE payment; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `rors_report-deny-alter` | `rors_report` | `BEGIN; ALTER TABLE customer ADD COLUMN g05_forbidden int; ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `rors_report-deny-sequence-reset` | `rors_report` | `BEGIN; SELECT setval('customer_customer_id_seq',1); ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `runtime-deny-sequence-state` | `rors_app` | `SELECT last_value FROM customer_customer_id_seq;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `report-deny-sequence` | `rors_report` | `SELECT nextval('customer_customer_id_seq');` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `runtime-deny-membership` | `rors_app` | `GRANT rors_runtime_grp TO rors_report;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `admin-needs-owner-role` | `rors_dba` | `BEGIN; CREATE TABLE public.g05_forbidden(id int); ROLLBACK;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `admin-maintenance` | `rors_dba` | `Full SQL in matching evidence marker` | Allowed | Succeeded | PASS |
| `admin-create-future-objects` | `rors_dba` | `SET ROLE rors_owner_grp; CREATE TABLE g05_future_probe(id serial PRIMARY KEY); CREATE FUNCTION g05_future_function() RETURNS int LANGUAGE sql AS 'SELECT 1';` | Allowed | Succeeded | PASS |
| `rors_app-deny-future-table` | `rors_app` | `SELECT * FROM g05_future_probe;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `rors_app-deny-future-function` | `rors_app` | `SELECT g05_future_function();` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `rors_report-deny-future-table` | `rors_report` | `SELECT * FROM g05_future_probe;` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `rors_report-deny-future-function` | `rors_report` | `SELECT g05_future_function();` | Denied (42501 / CONNECT) | Denied 42501 | PASS |
| `admin-future-use` | `rors_dba` | `BEGIN; SET ROLE rors_owner_grp; INSERT INTO g05_future_probe DEFAULT VALUES; SELECT g05_future_function(); ROLLBACK;` | Allowed | Succeeded | PASS |
| `admin-remove-future-objects` | `rors_dba` | `SET ROLE rors_owner_grp; DROP TABLE g05_future_probe; DROP FUNCTION g05_future_function();` | Allowed | Succeeded | PASS |
| `catalog-and-cleanup` | `lab_admin` | `Full SQL in matching evidence marker` | Allowed | Succeeded | PASS |

The positive runtime workflow inserted into all eight tables with generated IDs, updated each source-required mutable table, exercised reservation/table/staff deletion and returned the preserved order total **17.50** after menu-price change. Deferred constraints were forced immediate before rollback. A separate unreferenced menu delete succeeded. Empty-order and negative-price checks returned 23514; overlapping reservations returned 23P01. The separate upstream SQL suite also returned **25 passed, 0 failed**, then rolled back; see [upstream CRUD evidence](evidence/upstream-crud-tests.txt). It ran as the provisioning administrator and is not counted as runtime authorization proof.

## 3. Memberships, ownership, default grants and isolation

[Catalog output](evidence/catalog.txt) records all six safe project roles, exactly three planned memberships with no ADMIN OPTION, database/schema/object ACLs, owner-group ownership, functions, triggers, extensions, constraints and default ACLs. Maintenance DDL without SET ROLE was denied; owner activation allowed CREATE/INSERT/ALTER/DROP and rollback.

All three logins were denied CONNECT to `rors_unrelated_lab`, postgres and template1. Isolation is verified for this new dedicated cluster only. Existing services on other ports and remote hosts were not tested or changed.

Future-table/function tests created objects as the owner; runtime and reporting access was denied, maintenance owner access succeeded, and the probes were removed. This verifies effective restrictions after PUBLIC/default/member/ownership review. It does not promise future developers will never change grants.

## 4. Actual application checks using the restricted runtime login

**34 HTTP checks passed**, with PHP 8.5.10 on loopback 18090. [HTTP evidence](evidence/application-tests.json), [sanitized startup](evidence/application-startup.txt) and [runtime identity](evidence/application-runtime.txt) support this result. Form data, cookies, CSRF tokens, passwords and authentication hashes were not copied into evidence. PDO extensions and writable local sessions were configured for this process; owning source stayed unchanged.

| Check | Request | Expected HTTP | Actual HTTP | Result |
|---|---|---:|---:|---|
| health | `GET /health` | 200 | 200 | PASS |
| public-menu | `GET /menu` | 200 | 200 | PASS |
| login-customer-form | `GET /login` | 200 | 200 | PASS |
| login-customer | `POST /login` | 302 | 302 | PASS |
| login-staff-form | `GET /staff/login` | 200 | 200 | PASS |
| login-staff | `POST /staff/login` | 302 | 302 | PASS |
| login-admin-form | `GET /staff/login` | 200 | 200 | PASS |
| login-admin | `POST /staff/login` | 302 | 302 | PASS |
| customer-orders | `GET /orders` | 200 | 200 | PASS |
| customer-profile | `GET /profile` | 200 | 200 | PASS |
| staff-dashboard | `GET /admin` | 200 | 200 | PASS |
| staff-denied-staff-management | `GET /admin/staff` | 403 | 403 | PASS |
| customer-denied-staff-route | `GET /admin` | 302 | 302 | PASS |
| admin-menu | `GET /admin/menu` | 200 | 200 | PASS |
| admin-tables | `GET /admin/tables` | 200 | 200 | PASS |
| admin-orders | `GET /admin/orders` | 200 | 200 | PASS |
| admin-reservations | `GET /admin/reservations` | 200 | 200 | PASS |
| admin-payments | `GET /admin/payments` | 200 | 200 | PASS |
| admin-customers | `GET /admin/customers` | 200 | 200 | PASS |
| admin-staff | `GET /admin/staff` | 200 | 200 | PASS |
| csrf-missing-denied | `POST /admin/menu/save` | 403 | 403 | PASS |
| menu-create-form | `GET /admin/menu/edit` | 200 | 200 | PASS |
| menu-create | `POST /admin/menu/save` | 302 | 302 | PASS |
| menu-update-form | `GET /admin/menu/edit?id=54` | 200 | 200 | PASS |
| menu-update | `POST /admin/menu/save` | 302 | 302 | PASS |
| menu-delete-form | `GET /admin/menu` | 200 | 200 | PASS |
| menu-delete | `POST /admin/menu/delete` | 302 | 302 | PASS |
| cart-add-form | `GET /menu` | 200 | 200 | PASS |
| cart-add | `POST /cart/add` | 302 | 302 | PASS |
| checkout-form | `GET /cart` | 200 | 200 | PASS |
| checkout | `POST /checkout` | 302 | 302 | PASS |
| customer-view-new-order | `GET /orders/view?id=63` | 200 | 200 | PASS |
| staff-confirm-order-form | `GET /admin/orders/view?id=63` | 200 | 200 | PASS |
| staff-confirm-order | `POST /admin/orders/status` | 302 | 302 | PASS |

The checks cover public menu/health, customer/staff/admin login and authorized pages, forbidden staff-management/customer access, CSRF rejection, actual menu create/update/delete, checkout with returned order ID, viewing that order and staff confirmation. Redirect status alone was not enough: SQL checks verified price changes and the final confirmed order state.

No interactive browser testing, load/concurrency testing, full security audit, backup/recovery or every product workflow is claimed. Maven/Java is not used by this PHP project.

## 5. Findings, cleanup and remaining responsibilities

| Finding | Evaluated resolution / remaining action |
|---|---|
| Windows-invalid unrelated test-folder name | Export committed application snapshot without that folder; no application source patch |
| Documented hidden-password helper is missing | Assign distinct local passwords safely; recommend restoring helper |
| Database-create migration hardcodes the upstream name | Provision isolated DB explicitly; apply target-local migrations 001–004 unchanged |
| PDF still has 28 completion markers and link placeholders | Progress documentation remains incomplete despite successful DB testing |
| Shared runtime can manage application staff/admin identities directly | Document service-credential trust boundary; API authorization remains essential |
| Upstream extra backup/monitoring roles exceed this task's scope | Not provisioned here; later activities need a separate privilege review |

The service-credential boundary is explicit: a rolled-back runtime UPDATE changed a staff role to admin, reflecting the combined service privileges needed by the current admin account-management feature. No database-enforced per-end-user RLS or guarded-routine redesign was implemented or claimed.

SQL mutations rolled back; HTTP-created order/payment/line and menu rows were removed using the provisioning administrator only within this disposable database. [Final cleanup](evidence/final-cleanup.txt) verifies the original counts recorded in [Part A](part_a.md); temporary future objects are absent. Sequence increments are not transactional and were not reset. Application processes were stopped; the isolated database remains locally available.

**Owner feedback sent:** No. Findings are prepared here; no external message, issue or PR was posted. **Tracker, PDF and repository publication:** not performed in this scoped four-report task. These files provide inputs to those later submissions. Full course-wide Activity 4 completion is not claimed; Group 12 is not evaluated without a repository link.

**AI usage declaration:** OpenAI Codex read the assignment/reference reports, inspected the pinned repository, designed and applied the evaluated SQL, initialized the isolated cluster, executed separate-login psql checks and HTTP workflows, and wrote the reports. Output was validated against source operations, SQLSTATE/exit codes, actual generated-ID mutations, constraints/triggers, catalog ACLs/memberships/ownership, future-object behavior, HTTP responses, database effect checks and final row counts. No human validation is claimed. Real credentials and session tokens remain in private local/process configuration, outside Git and submissions.
