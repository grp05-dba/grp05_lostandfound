# Verification Report - Test and Verify Access Control

**Filename note:** `part_d.md` is the requested filename. The assignment PDF calls verification **Part E**; its Part D least-privilege requirements are addressed in [part_cd.md](part_cd.md).

## 1. Execution details and result

Executed on **6 November 2026 (Asia/Manila)** with Windows PostgreSQL 18.6 and psql, against the isolated `grp_brewposdb` instance on `127.0.0.1:55432`.

**58 of 58 implemented-plan checks passed**, plus eight future-object lifecycle checks. A separate historical-order append probe exposed a business-integrity gap; it is documented as unresolved, not counted as an access-control failure or concealed by the passing privilege checks. This is not a claim that the complete application is production-secure.

Each test used a real TCP connection as the named login with a private local password. `session_user` and `current_user` were verified for each login. Runtime/auditor testing did not use superuser impersonation or SET ROLE to manufacture identities. DBA maintenance intentionally used its granted owner membership.

Evidence files:

- [Runtime statements and actual output](evidence/brewpos_app.txt).
- [Auditor statements and actual output](evidence/brewpos_auditor.txt).
- [DBA statements and actual output](evidence/brewpos_dba.txt).
- [Per-case SQL, expectations, exit codes and status](evidence/results.json).
- [Database setup](evidence/setup.txt), [catalog and cleanup checks](evidence/catalog.txt), and [authentication configuration](evidence/authentication.txt).
- [Future-object policy checks](evidence/future_objects.txt) and [historical append finding](evidence/historical_append_gap.txt).

Expected SQL denials were checked for nonzero exit status and SQLSTATE `42501`. Initial connection failures do not display a SQLSTATE in this psql output; they were verified using the nonzero connection exit status and the explicit message that the account lacks CONNECT. A successful psql invocation alone was never taken as proof that every operation passed.

## 2. Detailed main test matrix

Every row below corresponds to the named block in that account's evidence file. Full SQL for longer transactions is retained there and in the linked JSON/verification scripts.

| Test | Account | Statement or operation | Expected | Actual result | Status |
|---|---|---|---|---|---|
| `identity-brewpos_app` | `brewpos_app` | SELECT session_user, current_user, current_database() | Allowed | Succeeded | **PASS** |
| `read-brewpos_app` | `brewpos_app` | SELECT actual row counts from all five tables | Allowed | 2 staff, 3 categories, 11 items, 5 tickets, 9 lines | **PASS** |
| `identity-brewpos_auditor` | `brewpos_auditor` | SELECT session_user, current_user, current_database() | Allowed | Succeeded | **PASS** |
| `read-brewpos_auditor` | `brewpos_auditor` | SELECT actual row counts from all five tables | Allowed | 2 staff, 3 categories, 11 items, 5 tickets, 9 lines | **PASS** |
| `identity-brewpos_dba` | `brewpos_dba` | SELECT session_user, current_user, current_database() | Allowed | Succeeded | **PASS** |
| `read-brewpos_dba` | `brewpos_dba` | SELECT actual row counts from all five tables | Allowed | 2 staff, 3 categories, 11 items, 5 tickets, 9 lines | **PASS** |
| `runtime-catalog-write` | `brewpos_app` | Insert/rename category; insert item; update its price and active status; ROLLBACK | Allowed | INSERT/UPDATE succeeded; price 12.50, active f; cleanup counts 0 | **PASS** |
| `runtime-category-delete` | `brewpos_app` | Insert an unused category; DELETE that category; ROLLBACK | Allowed | DELETE 1; rolled back | **PASS** |
| `runtime-checkout` | `brewpos_app` | Insert ticket and 2 x Americano line item; SELECT total; ROLLBACK | Allowed | Two INSERT 0 1 results; total 180.00; rolled back | **PASS** |
| `runtime-deny-staff-insert` | `brewpos_app` | BEGIN; INSERT INTO staff(full_name,role) VALUES ('E4 probe','CASHIER'); ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `runtime-deny-staff-update` | `brewpos_app` | BEGIN; UPDATE staff SET full_name=full_name WHERE staff_id=1; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `runtime-deny-staff-delete` | `brewpos_app` | BEGIN; DELETE FROM staff WHERE staff_id=1; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `runtime-deny-item-delete` | `brewpos_app` | BEGIN; DELETE FROM menu_item WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `runtime-deny-order-update` | `brewpos_app` | BEGIN; UPDATE order_ticket SET payment_method=payment_method WHERE order_id=1; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `runtime-deny-order-delete` | `brewpos_app` | BEGIN; DELETE FROM order_ticket WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `runtime-deny-line-update` | `brewpos_app` | BEGIN; UPDATE order_line_item SET sold_price=sold_price WHERE order_id=1; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `runtime-deny-line-delete` | `brewpos_app` | BEGIN; DELETE FROM order_line_item WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `runtime-deny-truncate` | `brewpos_app` | BEGIN; TRUNCATE order_line_item; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `runtime-deny-create-table` | `brewpos_app` | BEGIN; CREATE TABLE public.e4_forbidden(id integer); ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `runtime-deny-create-schema` | `brewpos_app` | BEGIN; CREATE SCHEMA e4_forbidden; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `runtime-deny-alter-table` | `brewpos_app` | BEGIN; ALTER TABLE staff ADD COLUMN e4_forbidden integer; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `runtime-deny-staff-sequence` | `brewpos_app` | BEGIN; SELECT nextval('staff_staff_id_seq'); ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `runtime-deny-sequence-reset` | `brewpos_app` | BEGIN; SELECT setval('order_ticket_order_id_seq',1); ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `runtime-deny-owner-escalation` | `brewpos_app` | BEGIN; SET ROLE brewpos_owner_grp; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `auditor-deny-insert-staff` | `brewpos_auditor` | BEGIN; INSERT INTO staff DEFAULT VALUES; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `auditor-deny-update-staff` | `brewpos_auditor` | BEGIN; UPDATE staff SET full_name=full_name WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `auditor-deny-delete-staff` | `brewpos_auditor` | BEGIN; DELETE FROM staff WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `auditor-deny-insert-menu_category` | `brewpos_auditor` | BEGIN; INSERT INTO menu_category DEFAULT VALUES; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `auditor-deny-update-menu_category` | `brewpos_auditor` | BEGIN; UPDATE menu_category SET category_name=category_name WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `auditor-deny-delete-menu_category` | `brewpos_auditor` | BEGIN; DELETE FROM menu_category WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `auditor-deny-insert-menu_item` | `brewpos_auditor` | BEGIN; INSERT INTO menu_item DEFAULT VALUES; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `auditor-deny-update-menu_item` | `brewpos_auditor` | BEGIN; UPDATE menu_item SET price=price WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `auditor-deny-delete-menu_item` | `brewpos_auditor` | BEGIN; DELETE FROM menu_item WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `auditor-deny-insert-order_ticket` | `brewpos_auditor` | BEGIN; INSERT INTO order_ticket DEFAULT VALUES; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `auditor-deny-update-order_ticket` | `brewpos_auditor` | BEGIN; UPDATE order_ticket SET payment_method=payment_method WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `auditor-deny-delete-order_ticket` | `brewpos_auditor` | BEGIN; DELETE FROM order_ticket WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `auditor-deny-insert-order_line_item` | `brewpos_auditor` | BEGIN; INSERT INTO order_line_item DEFAULT VALUES; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `auditor-deny-update-order_line_item` | `brewpos_auditor` | BEGIN; UPDATE order_line_item SET quantity=quantity WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `auditor-deny-delete-order_line_item` | `brewpos_auditor` | BEGIN; DELETE FROM order_line_item WHERE false; ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `auditor-deny-sequence` | `brewpos_auditor` | SELECT nextval('order_ticket_order_id_seq'); | Denied | Permission error 42501 | **PASS** |
| `auditor-deny-create-table` | `brewpos_auditor` | BEGIN; CREATE TABLE public.e4_forbidden(id integer); ROLLBACK; | Denied | Permission error 42501 | **PASS** |
| `auditor-deny-owner` | `brewpos_auditor` | SET ROLE brewpos_owner_grp; | Denied | Permission error 42501 | **PASS** |
| `dba-maintenance` | `brewpos_dba` | SET ROLE owner; insert staff; update item; ALTER staff; CREATE/DROP table; ROLLBACK | Allowed | INSERT, UPDATE, ALTER, CREATE, DROP succeeded; probes rolled back | **PASS** |
| `deny-createdb-brewpos_app` | `brewpos_app` | CREATE DATABASE e4_forbidden_database; | Denied | Permission error 42501 | **PASS** |
| `deny-createrole-brewpos_app` | `brewpos_app` | CREATE ROLE e4_forbidden_role NOLOGIN; | Denied | Permission error 42501 | **PASS** |
| `isolation-brewpos_app-brewpos_unrelateddb` | `brewpos_app` | Connect to `brewpos_unrelateddb` and attempt SELECT current_database() | Denied | CONNECT rejected | **PASS** |
| `isolation-brewpos_app-postgres` | `brewpos_app` | Connect to `postgres` and attempt SELECT current_database() | Denied | CONNECT rejected | **PASS** |
| `isolation-brewpos_app-template1` | `brewpos_app` | Connect to `template1` and attempt SELECT current_database() | Denied | CONNECT rejected | **PASS** |
| `deny-createdb-brewpos_auditor` | `brewpos_auditor` | CREATE DATABASE e4_forbidden_database; | Denied | Permission error 42501 | **PASS** |
| `deny-createrole-brewpos_auditor` | `brewpos_auditor` | CREATE ROLE e4_forbidden_role NOLOGIN; | Denied | Permission error 42501 | **PASS** |
| `isolation-brewpos_auditor-brewpos_unrelateddb` | `brewpos_auditor` | Connect to `brewpos_unrelateddb` and attempt SELECT current_database() | Denied | CONNECT rejected | **PASS** |
| `isolation-brewpos_auditor-postgres` | `brewpos_auditor` | Connect to `postgres` and attempt SELECT current_database() | Denied | CONNECT rejected | **PASS** |
| `isolation-brewpos_auditor-template1` | `brewpos_auditor` | Connect to `template1` and attempt SELECT current_database() | Denied | CONNECT rejected | **PASS** |
| `deny-createdb-brewpos_dba` | `brewpos_dba` | CREATE DATABASE e4_forbidden_database; | Denied | Permission error 42501 | **PASS** |
| `deny-createrole-brewpos_dba` | `brewpos_dba` | CREATE ROLE e4_forbidden_role NOLOGIN; | Denied | Permission error 42501 | **PASS** |
| `isolation-brewpos_dba-brewpos_unrelateddb` | `brewpos_dba` | Connect to `brewpos_unrelateddb` and attempt SELECT current_database() | Denied | CONNECT rejected | **PASS** |
| `isolation-brewpos_dba-postgres` | `brewpos_dba` | Connect to `postgres` and attempt SELECT current_database() | Denied | CONNECT rejected | **PASS** |
| `isolation-brewpos_dba-template1` | `brewpos_dba` | Connect to `template1` and attempt SELECT current_database() | Denied | CONNECT rejected | **PASS** |

## 3. Evidence excerpts

Runtime's actual generated-ID ticket and line-item INSERTs succeeded within a transaction. Two Americanos at the seeded price produced:

```text
INSERT 0 1
INSERT 0 1
 total
--------
 180.00
ROLLBACK
```

The runtime catalog-write transaction returned `UPDATE 1`, price `12.50`, and `is_active = f`. The separate category-delete test returned `DELETE 1`. All changes were rolled back. These are actual record modifications, rather than only `WHERE false` privilege probes.

Representative permission errors:

```text
ERROR:  42501: permission denied for table staff
ERROR:  42501: permission denied for table order_ticket
ERROR:  42501: permission denied for table order_line_item
ERROR:  42501: permission denied for schema public
ERROR:  42501: permission denied to create database
ERROR:  42501: permission denied to create role
```

Unrelated connection attempts were denied for all three login accounts:

```text
FATAL:  permission denied for database "brewpos_unrelateddb"
DETAIL:  User does not have CONNECT privilege.
```

The same explicit CONNECT restriction was observed for `postgres` and `template1`. Database isolation was verified only for the databases in this newly provisioned test cluster. Existing databases on port 5432 were not accessed or modified.

## 4. PUBLIC, ownership, memberships and future objects

Catalog inspection verified exactly the intended login-to-group memberships, no ADMIN OPTION and no elevated attributes for the six project roles. All five tables and four sequences belong to `brewpos_owner_grp`; the runtime and auditor do not inherit this owner role. Database/schema ACLs and table grants match the plan. The only remaining owner default-ACL entry is the explicit owner-only function execution policy; table/sequence defaults already grant no PUBLIC access, so revoking those defaults need not create extra catalog rows.

Eight additional future-object lifecycle checks were executed:

| Check | Actual outcome |
|---|---|
| Owner creates a new serial-key table and SQL function | Succeeded |
| Runtime SELECT from new table | Denied, 42501 |
| Runtime execute new function | Denied, 42501 |
| Auditor SELECT from new table | Denied, 42501 |
| Auditor execute new function | Denied, 42501 |
| DBA uses owner role to insert into new table and execute function | Succeeded; data rolled back |
| Owner drops both probes | Succeeded |
| Verify both probe objects absent | Both true |

No automatic future-table or sequence access is promised to runtime/auditor roles. Migrations must review each new object's grants. Default privileges are creator-specific; maintenance should deliberately use the documented owner role.

## 5. Historical-order append gap - unresolved

Although sales-table UPDATE and DELETE are denied, `brewpos_app` still needs INSERT. An actual test selected an existing ticket and a menu item not yet on that ticket, inserted a line with a valid foreign key, and received `INSERT 0 1`. The test rolled back and the line count returned to nine. See [full SQL and output](evidence/historical_append_gap.txt).

This demonstrates that withholding UPDATE/DELETE does not alone make existing receipt totals immutable. The same account can also choose a sold price through direct SQL; the Java service's price-copying rules are an application boundary. Recommended owner work is to define an explicit open/closed order lifecycle and guard writes through transaction-safe database routines/triggers or an equivalent reviewed design. This evaluation does not invent an order state or alter the owning group's schema.

The demo manager/cashier dropdown also does not authenticate a user. The shared runtime account supplies the combined service permissions, and the reviewed menu controller methods do not check an authenticated role. A production system needs server-side authentication and authorization. No claim of per-cashier database separation is made.

## 6. Cleanup, test limits and application status

After psql probes, the database retained 2 staff, 3 categories, 11 menu items, 5 tickets and 9 line items. Category/item probe rows and DBA staff probes were absent; temporary DDL and future-object probes were removed. Forbidden database/role probes did not create objects. SERIAL increments are not rolled back, so sequence values advanced during successful tests and were not reset. Exact generated IDs are not assumed.

Auditor INSERT/UPDATE/DELETE was attempted against all five tables; UPDATE/DELETE uses `WHERE false` where noted in the exact SQL. Those cases establish privilege rejection, not business effects on populated records. Other successful runtime probes performed actual inserts, updates and a category deletion inside rollback transactions. DDL and catalog checks do not establish backup/restore, all constraint edge cases, remote-host authentication or every possible application workflow.

The unmodified source was successfully packaged with Maven 3.10.0 and `-DskipTests`, then started on loopback HTTP port 18081. [Build output](evidence/build.txt), [startup output](evidence/application_startup.txt) and [application validation](evidence/application_validation.txt) provide the evidence. HTTP checks retrieved the landing page, 2 staff, 10 active products, 3 categories and 5 seeded orders; checkout returned HTTP 201 for two Americanos totaling 180.00; receipt and daily-sales retrieval succeeded. Database activity showed `brewpos_app` connections. The returned smoke-test order and its line were removed by the provisioning administrator, leaving the five original tickets and nine lines. The upstream JUnit suite and interactive browser workflows were not tested. Database privilege verification is independent of these HTTP smoke checks.

## 7. Issues, recommended feedback and AI usage

| Issue | Action / status |
|---|---|
| Existing PostgreSQL service requires unavailable credentials | Used a separate loopback-only cluster; existing service unchanged |
| Upstream role document claims the optional script creates groups/auditor/admin | Implemented the evaluated groups explicitly; recommend correcting documentation |
| Optional runtime script is broader than normal feature requirements | Evaluated role omits menu-item DELETE, staff sequence access and blanket sequence SELECT |
| Configuration defaults to `postgres` | Scratch local `.env` explicitly selects the non-superuser service login |
| PUBLIC default CONNECT could allow unrelated access | Hardened only this isolated cluster and verified actual denied connections |
| Historical receipt can receive additional line items | Reproduced, rolled back, unresolved; recommend guarded order lifecycle |
| Demo role selection is not authenticated authorization | Documented scope and recommended production controls |

**Feedback sent to owners:** No. These are prepared findings for the user's review; no external message or issue was posted. **Tracker/PDF submission:** not performed in this scoped four-report task. The supplied Markdown, SQL and evidence can support that later submission.

**AI usage declaration:** OpenAI Codex inspected the assignment and repository, prepared the access plan and SQL, initialized the isolated PostgreSQL lab, executed direct-login psql checks and wrote these reports. AI output was validated against the upstream source, actual psql results, SQLSTATE errors, catalog ACLs/memberships/ownership, generated-ID writes, rollback cleanup and future-object tests. No human validation is claimed. Test expectations were corrected during validation to select a named seeded product instead of assuming serial-ID order, and to match explicit CONNECT-denial output rather than an undisplayed connection SQLSTATE. The final evidence reflects the corrected rerun.

No actual passwords or password hashes are included in the submitted files. Group 4's repository was used as a source; all evaluation files remain in Group 5's local repository. Publication and course-wide completion are not claimed.
