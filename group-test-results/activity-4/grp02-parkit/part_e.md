# Part E - Test and Verify Access Control

## 1. Execution and result

The checks below were **executed on 6 November 2026** against local PostgreSQL **18.6**, `grp_parkitdb`, at `127.0.0.1:55442`. Each case opened a new direct SCRAM-authenticated connection as its named login. Successful connections recorded `session_user`, `current_user` and `current_database`; no administrator impersonation was used for runtime/auditor tests.

**96 of 96 cases matched the stated expectations.** This includes two deliberately successful business-rule probes (E95–E96), which demonstrate unresolved integrity gaps. It does not mean every application security requirement is satisfied: Staff vehicle registration/editing also succeeded during HTTP testing despite the upstream Admin-only policy.

[The test runner](run_verification.py) contains every executed statement, expected outcome and assertion. [Structured results](evidence/results.json) preserve the complete SQL, process exit status and stdout/stderr for each numbered case. The account-specific output files below provide readable transcripts. Long multi-statement cases are abbreviated in the table; their complete SQL is in the structured result with the same ID.

Permission denials use SQLSTATE `42501`; the protected-vehicle test expects foreign-key SQLSTATE `23503`. Startup CONNECT errors do not display SQLSTATE in psql, so those cases verify the explicit “User does not have CONNECT privilege” diagnostic and a nonzero exit status. Successful SQL probes explicitly roll back changes; failed sessions disconnect and roll back. Temporary future objects are removed after testing. Sequence increments can persist without row changes.

## 2. Individual verification results

| Test | Account | Statement or operation | Expected | Actual result / evidence |
|---|---|---|---|---|
| E01 | `parkit_app` | `SELECT session_user = current_user AS identity_matches;` | Allowed | Succeeded; exit 0; [output](evidence/parkit_app.txt) |
| E02 | `parkit_app` | `CREATE DATABASE parkit_forbidden_probe;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_app.txt) |
| E03 | `parkit_app` | `CREATE ROLE parkit_forbidden_role;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_app.txt) |
| E04 | `parkit_app` | `SELECT current_database();` | CONNECT denied | Denied: no CONNECT privilege; [output](evidence/parkit_app.txt) |
| E05 | `parkit_app` | `SELECT current_database();` | CONNECT denied | Denied: no CONNECT privilege; [output](evidence/parkit_app.txt) |
| E06 | `parkit_app` | `SELECT current_database();` | CONNECT denied | Denied: no CONNECT privilege; [output](evidence/parkit_app.txt) |
| E07 | `parkit_app` | `SET ROLE postgres;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_app.txt) |
| E08 | `parkit_auditor` | `SELECT session_user = current_user AS identity_matches;` | Allowed | Succeeded; exit 0; [output](evidence/parkit_auditor.txt) |
| E09 | `parkit_auditor` | `CREATE DATABASE parkit_forbidden_probe;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_auditor.txt) |
| E10 | `parkit_auditor` | `CREATE ROLE parkit_forbidden_role;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_auditor.txt) |
| E11 | `parkit_auditor` | `SELECT current_database();` | CONNECT denied | Denied: no CONNECT privilege; [output](evidence/parkit_auditor.txt) |
| E12 | `parkit_auditor` | `SELECT current_database();` | CONNECT denied | Denied: no CONNECT privilege; [output](evidence/parkit_auditor.txt) |
| E13 | `parkit_auditor` | `SELECT current_database();` | CONNECT denied | Denied: no CONNECT privilege; [output](evidence/parkit_auditor.txt) |
| E14 | `parkit_auditor` | `SET ROLE postgres;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_auditor.txt) |
| E15 | `parkit_dba` | `SELECT session_user = current_user AS identity_matches;` | Allowed | Succeeded; exit 0; [output](evidence/parkit_dba.txt) |
| E16 | `parkit_dba` | `CREATE DATABASE parkit_forbidden_probe;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_dba.txt) |
| E17 | `parkit_dba` | `CREATE ROLE parkit_forbidden_role;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_dba.txt) |
| E18 | `parkit_dba` | `SELECT current_database();` | CONNECT denied | Denied: no CONNECT privilege; [output](evidence/parkit_dba.txt) |
| E19 | `parkit_dba` | `SELECT current_database();` | CONNECT denied | Denied: no CONNECT privilege; [output](evidence/parkit_dba.txt) |
| E20 | `parkit_dba` | `SELECT current_database();` | CONNECT denied | Denied: no CONNECT privilege; [output](evidence/parkit_dba.txt) |
| E21 | `parkit_dba` | `SET ROLE postgres;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_dba.txt) |
| E22 | `parkit_app` | `SELECT count(*) FROM public."parking_zone";` | Allowed | Succeeded; exit 0; [output](evidence/parkit_app.txt) |
| E23 | `parkit_auditor` | `SELECT count(*) FROM public."parking_zone";` | Allowed | Succeeded; exit 0; [output](evidence/parkit_auditor.txt) |
| E24 | `parkit_app` | `SELECT count(*) FROM public."vehicle";` | Allowed | Succeeded; exit 0; [output](evidence/parkit_app.txt) |
| E25 | `parkit_auditor` | `SELECT count(*) FROM public."vehicle";` | Allowed | Succeeded; exit 0; [output](evidence/parkit_auditor.txt) |
| E26 | `parkit_app` | `SELECT count(*) FROM public."transaction";` | Allowed | Succeeded; exit 0; [output](evidence/parkit_app.txt) |
| E27 | `parkit_auditor` | `SELECT count(*) FROM public."transaction";` | Allowed | Succeeded; exit 0; [output](evidence/parkit_auditor.txt) |
| E28 | `parkit_app` | `SELECT count(*) FROM public."payment";` | Allowed | Succeeded; exit 0; [output](evidence/parkit_app.txt) |
| E29 | `parkit_auditor` | `SELECT count(*) FROM public."payment";` | Allowed | Succeeded; exit 0; [output](evidence/parkit_auditor.txt) |
| E30 | `parkit_app` | `SELECT user_id,username,role,(length(password_hash)>0) AS hash_present FROM public.staff_user;` | Allowed | Succeeded; exit 0; [output](evidence/parkit_app.txt) |
| E31 | `parkit_auditor` | `SELECT user_id,username,role FROM public.staff_user;` | Allowed | Succeeded; exit 0; [output](evidence/parkit_auditor.txt) |
| E32 | `parkit_auditor` | `SELECT password_hash FROM public.staff_user;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_auditor.txt) |
| E33 | `parkit_auditor` | `SELECT * FROM public.staff_user;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_auditor.txt) |
| E34 | `parkit_app` | `Runtime complete parking lifecycle, generated IDs and narrow updates; complete SQL in results.json E34` | Allowed | Succeeded; exit 0; [output](evidence/parkit_app.txt) |
| E35 | `parkit_app` | `Runtime edits and deletes unreferenced vehicle; complete SQL in results.json E35` | Allowed | Succeeded; exit 0; [output](evidence/parkit_app.txt) |
| E36 | `parkit_app` | `Foreign key protects referenced vehicle; complete SQL in results.json E36` | Denied 23503 | Rejected 23503; [output](evidence/parkit_app.txt) |
| E37 | `parkit_app` | `BEGIN; UPDATE public.parking_zone SET max_capacity=100; ROLLBACK;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_app.txt) |
| E38 | `parkit_app` | `BEGIN; UPDATE public.vehicle SET vehicle_id=vehicle_id; ROLLBACK;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_app.txt) |
| E39 | `parkit_app` | `BEGIN; UPDATE public."transaction" SET entry_time=entry_time; ROLLBACK;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_app.txt) |
| E40 | `parkit_app` | `BEGIN; UPDATE public."transaction" SET vehicle_id=vehicle_id; ROLLBACK;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_app.txt) |
| E41 | `parkit_app` | `BEGIN; UPDATE public.payment SET amount=amount; ROLLBACK;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_app.txt) |
| E42 | `parkit_app` | `BEGIN; UPDATE public.payment SET payment_time=payment_time; ROLLBACK;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_app.txt) |
| E43 | `parkit_app` | `BEGIN; UPDATE public.payment SET transaction_id=transaction_id; ROLLBACK;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_app.txt) |
| E44 | `parkit_app` | `BEGIN; UPDATE public.staff_user SET role=role; ROLLBACK;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_app.txt) |
| E45 | `parkit_app` | `BEGIN; INSERT INTO public.parking_zone(zone_name,max_capacity) VALUES('ACT4-NO',1); ROLLBACK;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_app.txt) |
| E46 | `parkit_app` | `BEGIN; INSERT INTO public.staff_user(username,password_hash,role) VALUES('ACT4-NO','noncredential-probe','Staff'); ROLLBACK;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_app.txt) |
| E47 | `parkit_app` | `BEGIN; DELETE FROM public.staff_user; ROLLBACK;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_app.txt) |
| E48 | `parkit_app` | `BEGIN; DELETE FROM public.parking_zone; ROLLBACK;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_app.txt) |
| E49 | `parkit_app` | `BEGIN; DELETE FROM public."transaction"; ROLLBACK;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_app.txt) |
| E50 | `parkit_app` | `BEGIN; DELETE FROM public.payment; ROLLBACK;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_app.txt) |
| E51 | `parkit_app` | `BEGIN; CREATE TABLE public.act4_forbidden(id integer); ROLLBACK;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_app.txt) |
| E52 | `parkit_app` | `BEGIN; CREATE SCHEMA act4_forbidden; ROLLBACK;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_app.txt) |
| E53 | `parkit_app` | `BEGIN; CREATE TEMP TABLE act4_forbidden(id integer); ROLLBACK;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_app.txt) |
| E54 | `parkit_app` | `BEGIN; TRUNCATE public.vehicle; ROLLBACK;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_app.txt) |
| E55 | `parkit_app` | `BEGIN; ALTER TABLE public.vehicle ADD COLUMN act4_forbidden integer; ROLLBACK;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_app.txt) |
| E56 | `parkit_app` | `BEGIN; GRANT parkit_owner_grp TO parkit_app; ROLLBACK;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_app.txt) |
| E57 | `parkit_app` | `BEGIN; SELECT nextval('public.staff_user_user_id_seq'); ROLLBACK;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_app.txt) |
| E58 | `parkit_app` | `BEGIN; SELECT nextval('public.parking_zone_zone_id_seq'); ROLLBACK;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_app.txt) |
| E59 | `parkit_app` | `BEGIN; SELECT setval('public.vehicle_vehicle_id_seq',999); ROLLBACK;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_app.txt) |
| E60 | `parkit_auditor` | `BEGIN; CREATE TABLE public.act4_forbidden(id integer); ROLLBACK;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_auditor.txt) |
| E61 | `parkit_auditor` | `BEGIN; CREATE SCHEMA act4_forbidden; ROLLBACK;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_auditor.txt) |
| E62 | `parkit_auditor` | `BEGIN; CREATE TEMP TABLE act4_forbidden(id integer); ROLLBACK;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_auditor.txt) |
| E63 | `parkit_auditor` | `BEGIN; TRUNCATE public.vehicle; ROLLBACK;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_auditor.txt) |
| E64 | `parkit_auditor` | `BEGIN; ALTER TABLE public.vehicle ADD COLUMN act4_forbidden integer; ROLLBACK;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_auditor.txt) |
| E65 | `parkit_auditor` | `BEGIN; GRANT parkit_owner_grp TO parkit_auditor; ROLLBACK;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_auditor.txt) |
| E66 | `parkit_auditor` | `BEGIN; SELECT nextval('public.staff_user_user_id_seq'); ROLLBACK;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_auditor.txt) |
| E67 | `parkit_auditor` | `BEGIN; SELECT nextval('public.parking_zone_zone_id_seq'); ROLLBACK;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_auditor.txt) |
| E68 | `parkit_auditor` | `BEGIN; SELECT setval('public.vehicle_vehicle_id_seq',999); ROLLBACK;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_auditor.txt) |
| E69 | `parkit_auditor` | `BEGIN; INSERT INTO public."parking_zone" DEFAULT VALUES; ROLLBACK;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_auditor.txt) |
| E70 | `parkit_auditor` | `BEGIN; UPDATE public."parking_zone" SET current_active_count=current_active_count; ROLLBACK;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_auditor.txt) |
| E71 | `parkit_auditor` | `BEGIN; DELETE FROM public."parking_zone"; ROLLBACK;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_auditor.txt) |
| E72 | `parkit_auditor` | `BEGIN; INSERT INTO public."vehicle" DEFAULT VALUES; ROLLBACK;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_auditor.txt) |
| E73 | `parkit_auditor` | `BEGIN; UPDATE public."vehicle" SET vehicle_type=vehicle_type; ROLLBACK;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_auditor.txt) |
| E74 | `parkit_auditor` | `BEGIN; DELETE FROM public."vehicle"; ROLLBACK;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_auditor.txt) |
| E75 | `parkit_auditor` | `BEGIN; INSERT INTO public."staff_user" DEFAULT VALUES; ROLLBACK;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_auditor.txt) |
| E76 | `parkit_auditor` | `BEGIN; UPDATE public."staff_user" SET role=role; ROLLBACK;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_auditor.txt) |
| E77 | `parkit_auditor` | `BEGIN; DELETE FROM public."staff_user"; ROLLBACK;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_auditor.txt) |
| E78 | `parkit_auditor` | `BEGIN; INSERT INTO public."transaction" DEFAULT VALUES; ROLLBACK;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_auditor.txt) |
| E79 | `parkit_auditor` | `BEGIN; UPDATE public."transaction" SET status=status; ROLLBACK;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_auditor.txt) |
| E80 | `parkit_auditor` | `BEGIN; DELETE FROM public."transaction"; ROLLBACK;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_auditor.txt) |
| E81 | `parkit_auditor` | `BEGIN; INSERT INTO public."payment" DEFAULT VALUES; ROLLBACK;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_auditor.txt) |
| E82 | `parkit_auditor` | `BEGIN; UPDATE public."payment" SET payment_method=payment_method; ROLLBACK;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_auditor.txt) |
| E83 | `parkit_auditor` | `BEGIN; DELETE FROM public."payment"; ROLLBACK;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_auditor.txt) |
| E84 | `parkit_auditor` | `SELECT nextval('public.vehicle_vehicle_id_seq');` | Denied 42501 | Rejected 42501; [output](evidence/parkit_auditor.txt) |
| E85 | `parkit_auditor` | `SELECT nextval('public.transaction_transaction_id_seq');` | Denied 42501 | Rejected 42501; [output](evidence/parkit_auditor.txt) |
| E86 | `parkit_auditor` | `SELECT nextval('public.payment_payment_id_seq');` | Denied 42501 | Rejected 42501; [output](evidence/parkit_auditor.txt) |
| E87 | `parkit_dba` | `DBA owns/migrates project objects and provisions zone data; complete SQL in results.json E87` | Allowed | Succeeded; exit 0; [output](evidence/parkit_dba.txt) |
| E88 | `parkit_dba` | `ANALYZE public.vehicle;` | Allowed | Succeeded; exit 0; [output](evidence/parkit_dba.txt) |
| E89 | `parkit_app` | `SELECT * FROM public.act4_future_probe;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_app.txt) |
| E90 | `parkit_app` | `SELECT nextval('public.act4_future_probe_id_seq');` | Denied 42501 | Rejected 42501; [output](evidence/parkit_app.txt) |
| E91 | `parkit_app` | `SELECT public.act4_future_function();` | Denied 42501 | Rejected 42501; [output](evidence/parkit_app.txt) |
| E92 | `parkit_auditor` | `SELECT * FROM public.act4_future_probe;` | Denied 42501 | Rejected 42501; [output](evidence/parkit_auditor.txt) |
| E93 | `parkit_auditor` | `SELECT nextval('public.act4_future_probe_id_seq');` | Denied 42501 | Rejected 42501; [output](evidence/parkit_auditor.txt) |
| E94 | `parkit_auditor` | `SELECT public.act4_future_function();` | Denied 42501 | Rejected 42501; [output](evidence/parkit_auditor.txt) |
| E95 | `parkit_app` | `Business rule gap: duplicate active entries permitted by schema; complete SQL in results.json E95` | Allowed | Succeeded; exit 0; [output](evidence/parkit_app.txt) |
| E96 | `parkit_app` | `BEGIN; UPDATE public.parking_zone SET current_active_count=-1 RETURNING current_active_count; ROLLBACK;` | Allowed | Succeeded; exit 0; [output](evidence/parkit_app.txt) |

## 3. Representative actual output

The runtime lifecycle case (E34) creates a disposable vehicle, entry and payment, locks the rows used by the PHP workflow, updates the exit and occupancy, and corrects only the payment method. It returns:

```text
  status   | amount | payment_method
-----------+--------+----------------
 Completed |  50.00 | GCash
(1 row)

ROLLBACK
```

The auditor can select staff identity columns but cannot select hashes or use `SELECT *`:

```text
ERROR:  42501: permission denied for table staff_user
```

Runtime changes to protected payment columns, transaction linkage/entry time, capacity and staff roles are rejected. Permission checks occur even when a protected table is empty; these denial statements do not rely on rows being present. Positive write tests create actual rows within their rollback transaction. The referenced-vehicle test reaches the DELETE privilege successfully and is then rejected by its foreign key:

```text
ERROR:  23503: update or delete on table "vehicle" violates foreign key constraint "transaction_vehicle_id_fkey" on table "transaction"
```

All three project logins are denied connections to each unrelated/default test target:

```text
FATAL:  permission denied for database "parkit_unrelateddb"
DETAIL:  User does not have CONNECT privilege.
```

[Catalog evidence](evidence/catalog.txt) independently confirms role attributes, memberships, database/schema/object ownership, table/column ACLs, defaults, constraints, indexes and final row counts. DBA ownership gives project DDL/maintenance authority; it does not grant cluster SUPERUSER, CREATEDB or CREATEROLE.

## 4. Application-level validation

[The HTTP validation transcript](evidence/application_validation.txt) records requests made by [validate_application.py](validate_application.py) against a private copy of the pinned source. Only connection configuration was adapted to private environment values. PHP connected as **`parkit_app`** with its private password. No UI/browser interaction, Apache/XAMPP setup or automated upstream test suite is claimed.

| Operation | Actual result |
|---|---|
| Staff login | Successful authentication and redirect to populated dashboard |
| Staff vehicle registration | Vehicle and Active transaction persisted; occupancy became 1 — violates documented Admin-only policy |
| Staff vehicle edit | License plate changed — same unresolved role-policy failure |
| Monitoring page/API | HTTP 200; API returned valid JSON |
| Vehicle payment/exit | Completed transaction, amount 50.00, Cash payment, occupancy returned to 0 |
| Receipt/payment-method correction | Receipt retrieved; method changed to GCash using the narrow UPDATE grant |
| Admin login/dashboard | Successful with the same restricted service login |
| Cleanup | Named test payment/transaction/vehicle removed by DBA; seed records retained; PHP server stopped |

The HTTP tests prove the normal database workflow works without superuser privileges. They also show why database roles cannot distinguish Admin and Staff when both use the same PHP service account. Owners must enforce `isAdmin()` or equivalent authorization on the vehicle endpoints, and review other role-sensitive actions.

## 5. Remaining findings, fixes and limits

- **Fixed in the evaluated local setup:** superuser runtime connection, missing group/login separation, overly broad PUBLIC access, missing insert-sequence permissions, and grants that did not match feature SQL. Runtime UPDATE is restricted to needed columns, and auditor staff access excludes hashes. The original repository is unchanged.
- **Unresolved application authorization:** Staff can register/edit vehicles despite the published policy. Captured HTTP evidence records this as a finding, not a passed policy check.
- **Unresolved database integrity:** E95 inserts two Active transactions for one vehicle; E96 sets occupancy to -1. Both succeed and roll back. Recommend a reviewed unique active-entry rule and nonnegative capacity/occupancy CHECKs, alongside explicit state-transition validation. These schema changes were not applied because the source's table/column structure was preserved.
- **History protection has limits:** denial of transaction/payment DELETE and protected-column UPDATE does not guarantee valid amounts, chronology, status or relationships on INSERT. Trusted DBA ownership is also intentionally powerful. Further business validation needs reviewed constraints, guarded routines or application controls.
- **Lab scope:** this is an isolated local PostgreSQL/PHP test, with only disposable demo data. Network TLS, external hosts, concurrent-load behavior, production deployment and long-term credential management were not evaluated. Loopback SCRAM authentication was exercised. Initial default-socket connection failed because no default server was running; the separate cluster resolved that environment issue.
- **Final state:** one 50-space zone at occupancy 0, two application users, zero vehicles, transactions and payments; no probe tables/functions remain. Sequence counters may contain gaps.

Feedback and recommended fixes are documented in these reports but were **not sent** to owners. Tracker edits, a consolidated submission PDF and commits remain separate submission steps; no such actions are claimed.

## 6. AI usage declaration

OpenAI Codex assisted with reading the Activity 4 PDF and repository documents, tracing PHP database operations, preparing the access plan and SQL/scripts, executing local setup/tests and drafting these reports. Generated grants were checked against the source SQL and final PostgreSQL catalogs. Each restricted login was tested directly with both allowed and denied operations; psql outcomes were checked against expected error diagnostics. HTTP requests independently exercised the actual PHP workflow and confirmed its authorization limitation. Secrets, cookies, source configuration credentials, staff hashes and the seeder's credential-bearing output were excluded from submitted evidence.
