# Part E – Test and Verify Access Control

## 1. Execution details

These tests were **executed in psql on 6 November 2026** against local PostgreSQL 18.6 and `grp_parkitdb`. They replace the previous illustrative results. See [Part C and Part D](part_cd.md) for the privilege plan.

Each login connected directly, without administrator impersonation:

```sh
psql -X -w -U park_it_app -d grp_parkitdb
psql -X -w -U park_it_auditor -d grp_parkitdb
psql -X -w -U park_it_dba -d grp_parkitdb
```

`SELECT session_user, current_user, current_database();` confirmed each requested account as both session and current user, with database `grp_parkitdb`. Connections used the local Unix socket on port 5432 without passwords in commands or evidence. Remote connections and password authentication were not tested.

Evidence below contains executed statements and actual output excerpts. Expected errors were allowed to continue so that later tests could run. A zero psql process exit status was not interpreted as proof that every statement succeeded. All permission errors below reported SQLSTATE `42501`.

## 2. Results

| Test | Account | SQL statement or operation | Expected | Actual result / evidence | Status |
|---|---|---|---|---|---|
| E01 | `park_it_app` | Vehicle SELECT and operational table counts (§3) | Allowed | SELECT succeeded; all counts 0 | PASS |
| E02 | `park_it_app` | Actual vehicle INSERT with default generated ID (§3) | Allowed | `INSERT 0 1`, ID 1; rolled back; remaining test rows 0 | PASS |
| E03 | `park_it_app` | UPDATE vehicle, zone, transaction and payment; DELETE vehicle, all `WHERE false` (§3) | Allowed | Four `UPDATE 0` results; `DELETE 0` | PASS for privilege checks |
| E04 | `park_it_app` | `DELETE FROM public.payment WHERE false;` | Denied | `permission denied for table payment` | PASS |
| E05 | `park_it_app` | `UPDATE public.staff_user SET username=username WHERE false;` | Denied | `permission denied for table staff_user` | PASS |
| E06 | `park_it_app` | `CREATE DATABASE park_it_part_e_probe_20261106;` | Denied | `permission denied to create database` | PASS |
| E07 | `park_it_app` | `CREATE ROLE park_it_part_e_probe_20261106 NOLOGIN;` | Denied | `permission denied to create role` | PASS |
| E08 | `park_it_app` | `CREATE TABLE public.part_e_probe_20261106 (id integer);` | Denied | `permission denied for schema public` | PASS |
| E09 | `park_it_auditor` | SELECT operational tables and approved staff columns (§4) | Allowed | All SELECT statements succeeded; operational counts 0 | PASS |
| E10 | `park_it_auditor` | `SELECT password_hash FROM public.staff_user LIMIT 0;` | Denied | `permission denied for table staff_user` | PASS |
| E11a | `park_it_auditor` | `UPDATE public.vehicle SET vehicle_type=vehicle_type WHERE false;` | Denied | `permission denied for table vehicle` | PASS |
| E11b | `park_it_auditor` | Vehicle INSERT (§4) | Denied | `permission denied for table vehicle` | PASS |
| E11c | `park_it_auditor` | `DELETE FROM public.vehicle WHERE false;` | Denied | `permission denied for table vehicle` | PASS |
| E12 | `park_it_auditor` | `CREATE DATABASE park_it_part_e_auditor_probe_20261106;` | Denied | `permission denied to create database` | PASS |
| E13 | `park_it_dba` | Staff SELECT, vehicle INSERT, zone UPDATE, payment DELETE, table creation (§5) | Allowed | SELECT succeeded; `INSERT 0 1`, ID 2; `UPDATE 0`, `DELETE 0`, `CREATE TABLE`; rolled back | PASS for tested operations |
| E14a | `park_it_dba` | `CREATE DATABASE park_it_part_e_dba_probe_20261106;` | Denied under configured attributes | `permission denied to create database` | PASS |
| E14b | `park_it_dba` | `CREATE ROLE park_it_part_e_dba_probe_20261106 NOLOGIN;` | Denied under configured attributes | `permission denied to create role` | PASS |
| E15a | `park_it_app` | Connect to unrelated `postgres` database (§6) | Denied | Connection succeeded | **FAIL – unresolved** |
| E15b | `park_it_auditor` | Connect to unrelated `postgres` database (§6) | Denied | Connection succeeded | **FAIL – unresolved** |
| E15c | `park_it_dba` | Connect to unrelated `postgres` database (§6) | Denied for project-scoped administration | Connection succeeded | **FAIL – unresolved** |

## 3. Runtime statements and captured evidence

Connected as `park_it_app` to `grp_parkitdb`:

```sql
SELECT vehicle_id, license_plate, vehicle_type FROM public.vehicle LIMIT 0;
BEGIN;
INSERT INTO public.vehicle (license_plate, vehicle_type)
VALUES ('E4-' || pg_backend_pid(), 'Part E verification')
RETURNING vehicle_id, license_plate, vehicle_type;
ROLLBACK;
SELECT count(*) AS remaining_test_rows FROM public.vehicle
WHERE license_plate = 'E4-' || pg_backend_pid();

BEGIN;
UPDATE public.vehicle SET vehicle_type=vehicle_type WHERE false;
UPDATE public.parking_zone SET current_active_count=current_active_count WHERE false;
UPDATE public."transaction" SET status=status WHERE false;
UPDATE public.payment SET payment_method=payment_method WHERE false;
DELETE FROM public.vehicle WHERE false;
ROLLBACK;
```

The SELECT succeeded with the requested column headers and `(0 rows)`. Captured INSERT evidence:

```text
 vehicle_id | license_plate |    vehicle_type
------------+---------------+---------------------
          1 | E4-20188      | Part E verification
(1 row)

INSERT 0 1
ROLLBACK
 remaining_test_rows
---------------------
                   0
(1 row)
```

The four UPDATE statements returned `UPDATE 0`; DELETE returned `DELETE 0`. The actual INSERT also exercised the default `vehicle_vehicle_id_seq` sequence.

The E04, E05 and E08 statements in the results table each ran inside a separate `BEGIN` / `ROLLBACK`. E06 and E07 ran outside transactions so that their errors tested privileges rather than transaction-block restrictions. Captured errors, in order:

```text
ERROR:  42501: permission denied for table payment
ERROR:  42501: permission denied for table staff_user
ERROR:  42501: permission denied to create database
ERROR:  42501: permission denied to create role
DETAIL:  Only roles with the CREATEROLE attribute may create roles.
ERROR:  42501: permission denied for schema public
```

This actual data-read query was also run separately under **all three logins**:

```sql
SELECT current_user,
       (SELECT count(*) FROM public.vehicle) AS vehicles,
       (SELECT count(*) FROM public.parking_zone) AS zones,
       (SELECT count(*) FROM public."transaction") AS transactions,
       (SELECT count(*) FROM public.payment) AS payments;
```

Combined evidence from the three separate one-row outputs:

```text
  current_user   | vehicles | zones | transactions | payments
-----------------+----------+-------+--------------+----------
 park_it_app     |        0 |     0 |            0 |        0
 park_it_auditor |        0 |     0 |            0 |        0
 park_it_dba     |        0 |     0 |            0 |        0
```

## 4. Auditor statements and captured evidence

Connected as `park_it_auditor`:

```sql
SELECT * FROM public.vehicle LIMIT 0;
SELECT * FROM public.parking_zone LIMIT 0;
SELECT * FROM public."transaction" LIMIT 0;
SELECT * FROM public.payment LIMIT 0;
SELECT user_id, username, role FROM public.staff_user LIMIT 0;
SELECT password_hash FROM public.staff_user LIMIT 0;

BEGIN;
UPDATE public.vehicle SET vehicle_type=vehicle_type WHERE false;
ROLLBACK;
BEGIN;
INSERT INTO public.vehicle (license_plate, vehicle_type)
VALUES ('E4-' || pg_backend_pid(), 'Part E verification');
ROLLBACK;
BEGIN;
DELETE FROM public.vehicle WHERE false;
ROLLBACK;
CREATE DATABASE park_it_part_e_auditor_probe_20261106;
```

The first five SELECT statements succeeded, returning requested column headers and `(0 rows)`. `LIMIT 0` still checks column permissions and avoids exposing staff records. The separate count query in §3 also performed actual operational-table reads.

Captured errors for password-hash SELECT, UPDATE, INSERT, DELETE and CREATE DATABASE, respectively:

```text
ERROR:  42501: permission denied for table staff_user
ERROR:  42501: permission denied for table vehicle
ERROR:  42501: permission denied for table vehicle
ERROR:  42501: permission denied for table vehicle
ERROR:  42501: permission denied to create database
```

## 5. DBA statements and captured evidence

Connected as `park_it_dba`:

```sql
BEGIN;
SELECT user_id, username, role FROM public.staff_user LIMIT 0;
INSERT INTO public.vehicle (license_plate, vehicle_type)
VALUES ('E4-' || pg_backend_pid(), 'Part E DBA verification') RETURNING vehicle_id;
UPDATE public.parking_zone SET current_active_count=current_active_count WHERE false;
DELETE FROM public.payment WHERE false;
CREATE TABLE public.part_e_dba_probe_20261106 (id integer);
ROLLBACK;
SELECT to_regclass('public.part_e_dba_probe_20261106') IS NULL AS probe_table_removed;
SELECT count(*) AS remaining_test_rows FROM public.vehicle
WHERE license_plate='E4-' || pg_backend_pid();
CREATE DATABASE park_it_part_e_dba_probe_20261106;
CREATE ROLE park_it_part_e_dba_probe_20261106 NOLOGIN;
```

Staff SELECT succeeded. Captured output excerpts:

```text
 vehicle_id
------------
          2
(1 row)

INSERT 0 1
UPDATE 0
DELETE 0
CREATE TABLE
ROLLBACK
 probe_table_removed
---------------------
 t
(1 row)

 remaining_test_rows
---------------------
                   0
(1 row)

ERROR:  42501: permission denied to create database
ERROR:  42501: permission denied to create role
DETAIL:  Only roles with the CREATEROLE attribute may create roles.
```

The DBA account can administer the tested existing objects and create objects in `public`. It is not a cluster administrator. Database-level `ALL PRIVILEGES` does not grant the `CREATEDB` or `CREATEROLE` attributes; provisioning database roles still requires an appropriately authorized account.

## 6. Unrelated-database failure and investigation

Actual separate connection attempts:

```sh
psql -X -w -U park_it_app -d postgres
psql -X -w -U park_it_auditor -d postgres
psql -X -w -U park_it_dba -d postgres
```

Each ran `SELECT session_user, current_user, current_database();`. All connections succeeded. Combined evidence from separate sessions:

```text
  session_user   |  current_user   | current_database
-----------------+-----------------+------------------
 park_it_app     | park_it_app     | postgres
 park_it_auditor | park_it_auditor | postgres
 park_it_dba     | park_it_dba     | postgres
```

Investigation queries executed under `park_it_app`:

```sql
SELECT rolname, rolcanlogin, rolsuper, rolcreatedb, rolcreaterole, rolinherit
FROM pg_roles WHERE rolname LIKE 'park_it_%' ORDER BY rolname;

SELECT member.rolname AS login, parent.rolname AS group_role
FROM pg_auth_members m
JOIN pg_roles member ON member.oid=m.member
JOIN pg_roles parent ON parent.oid=m.roleid
WHERE member.rolname LIKE 'park_it_%';

SELECT datname, pg_get_userbyid(datdba) AS owner, datacl
FROM pg_database WHERE datname IN ('grp_parkitdb','postgres');
SELECT nspname, nspacl FROM pg_namespace WHERE nspname='public';
SELECT tablename, tableowner FROM pg_tables WHERE schemaname='public';

SELECT grantee, table_name, privilege_type
FROM information_schema.table_privileges
WHERE table_schema='public'
  AND grantee IN ('PUBLIC','park_it_app','park_it_runtime_grp')
ORDER BY grantee, table_name, privilege_type;

SELECT datname, has_database_privilege(current_user, oid, 'CONNECT') AS can_connect
FROM pg_database WHERE datallowconn ORDER BY datname;
```

Findings:

- All six Park It roles have `rolsuper = f`, `rolcreatedb = f`, `rolcreaterole = f`, and `rolinherit = t`. Only the three account roles have `rolcanlogin = t`.
- Each login has only its corresponding group membership: runtime, readonly or admin. No unexpected membership was returned for these roles.
- The project database and all five existing tables are owned by `postgres`, not a tested account. Object ownership does not explain these connections.
- `postgres.datacl` is NULL: default database privileges apply, including CONNECT for `PUBLIC`. This explains access without a direct login-specific grant.
- `grp_parkitdb.datacl` is `{=Tc/postgres,postgres=CTc/postgres,park_it_admin_grp=CTc/postgres,park_it_runtime_grp=c/postgres,park_it_readonly_grp=c/postgres}`. The `=Tc` entry retains `PUBLIC` TEMPORARY and CONNECT privileges on the project database too.
- The `public` schema retains `PUBLIC` USAGE, but not CREATE. The table-grant query returned only the planned runtime group grants; no direct `park_it_app` or `PUBLIC` table grants were returned by that query.
- Runtime effective CONNECT was also true for `company_db`, `grp05_lostandfounddb`, `grp05_lostandfounddb_clone`, `grp_brewposdb` and `template1`, and false for `loan_system_demo`. These were catalog checks; actual unrelated-database connections were tested only against `postgres`. Connection access does not establish access to its tables.

**The unrelated-database restriction remains unresolved.** Shared database permissions were not changed during Part E. An administrator must review legitimate users of affected databases, preserve their explicit CONNECT grants, and revoke inappropriate `PUBLIC` CONNECT. Revoking only a direct login grant cannot remove access inherited through `PUBLIC`. The project database's PUBLIC defaults also need review. After remediation, rerun the actual connection tests for all three logins and check other applicable access paths before claiming completion.

## 7. Cleanup, limits and AI validation

Both successful vehicle inserts were rolled back; cleanup queries found zero remaining test rows. The DBA test table was rolled back and verified absent. Denied CREATE statements created no database or role. PostgreSQL sequence increments are not rolled back: successful inserts consumed vehicle IDs 1 and 2. The sequence was not reset.

`WHERE false` UPDATE/DELETE tests verify privileges without changing records; they do not test modifications to populated records or application business rules. `LIMIT 0` verifies requested column privileges. Actual INSERT and count queries supplement these checks. The four operational tables were empty. Transaction/payment INSERTs, their sequences, full application workflows, future-object permissions and a complete table/column permission matrix were not exercised and are not claimed as passing.

AI assistance prepared and executed the psql tests and wrote this report. Validation used actual independent account connections, SQL results, SQLSTATE errors, catalog inspection and rollback checks. No actual passwords or password hashes are included.

The tested table restrictions and role-attribute restrictions behaved as intended. Unrelated-database connections failed the expected restriction, so the overall access-control configuration must not yet be reported as fully verified or complete.
