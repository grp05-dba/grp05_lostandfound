# Parts C and D - Roles, Privileges, and Least Privilege

## 1. Executed implementation

The [Part B plan](part_b.md) was implemented on **6 November 2026** against a new PostgreSQL 18.6 lab on port **55442**. The project database is `grp_parkitdb`. [Setup output](evidence/setup.txt) and [final catalog verification](evidence/catalog.txt) show actual creation, ownership, memberships and grants. The source repository was not modified.

These scripts are intended for a **fresh dedicated lab**. They stop on errors, including existing role/database names; they do not drop and replace an existing installation. Roles are cluster-wide. PUBLIC revokes on the administrative databases apply only to this isolated lab, not an unreviewed shared server.

## 2. Part C - Login/group roles and database access

Execute [01_roles_database.sql](sql/01_roles_database.sql) as the provisioning administrator connected to `postgres`. It creates:

| NOLOGIN group | Member LOGIN | Scope |
|---|---|---|
| `parkit_owner_grp` | `parkit_dba` | Trusted owner of this project's database and objects |
| `parkit_runtime_grp` | `parkit_app` | PHP's approved operations |
| `parkit_readonly_grp` | `parkit_auditor` | Approved read-only inspection |

Every role explicitly has NOSUPERUSER, NOCREATEDB, NOCREATEROLE, NOREPLICATION and NOBYPASSRLS. Login roles use INHERIT; memberships have no ADMIN OPTION. The DBA can `SET ROLE parkit_owner_grp` for migrations but cannot create cluster roles/databases. Runtime and auditor do not own project objects and cannot assume the owner group.

The project database is owned by `parkit_owner_grp`. PUBLIC access is revoked; runtime/auditor groups receive CONNECT only, and the DBA inherits owner access. The unrelated lab database, `postgres`, and `template1` deny project connections. `template0` remains non-connectable by its normal database setting; no application database was placed there.

Passwords were randomly generated and assigned through non-echoed psql standard input. They are stored only in a protected local directory outside the repository; tests pass them through private process environments. No passwords, connection URLs with secrets, password hashes, cookies or credential-bearing HTML are included in evidence. Manual setup can assign credentials interactively:

```text
\password parkit_app
\password parkit_auditor
\password parkit_dba
```

The upstream schema dump was imported with `psql -v ON_ERROR_STOP=1` unchanged. Because it explicitly assigns owners to `postgres`, the privilege script subsequently transfers each table to the owner group; PostgreSQL transfers the table's owned sequence with it. A global reassignment of all `postgres` ownership was not used. The final catalog confirms the five tables, five sequences and their indexes are owned by `parkit_owner_grp`.

## 3. Part C - Schema, object, sequence and default privileges

Execute [02_privileges.sql](sql/02_privileges.sql) as the provisioning administrator connected to `grp_parkitdb`. The central grants are:

```sql
ALTER SCHEMA public OWNER TO parkit_owner_grp;
REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO parkit_runtime_grp, parkit_readonly_grp;

GRANT SELECT ON public.parking_zone, public.vehicle, public.staff_user,
    public."transaction", public.payment TO parkit_runtime_grp;
GRANT INSERT ON public.vehicle, public."transaction", public.payment TO parkit_runtime_grp;
GRANT DELETE ON public.vehicle TO parkit_runtime_grp;
GRANT UPDATE (license_plate, vehicle_type) ON public.vehicle TO parkit_runtime_grp;
GRANT UPDATE (current_active_count) ON public.parking_zone TO parkit_runtime_grp;
GRANT UPDATE (exit_time, status, is_lost_ticket) ON public."transaction" TO parkit_runtime_grp;
GRANT UPDATE (payment_method) ON public.payment TO parkit_runtime_grp;
GRANT USAGE ON SEQUENCE public.vehicle_vehicle_id_seq,
    public.transaction_transaction_id_seq, public.payment_payment_id_seq TO parkit_runtime_grp;

GRANT SELECT ON public.parking_zone, public.vehicle, public."transaction", public.payment
    TO parkit_readonly_grp;
GRANT SELECT (user_id, username, role) ON public.staff_user TO parkit_readonly_grp;

ALTER DEFAULT PRIVILEGES FOR ROLE parkit_owner_grp IN SCHEMA public
    REVOKE ALL ON TABLES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE parkit_owner_grp IN SCHEMA public
    REVOKE ALL ON SEQUENCES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE parkit_owner_grp REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE parkit_dba REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;
```

The complete script also performs the individual ownership transfers and configures runtime search path, statement timeout and lock timeout. Column-level UPDATE is intentional: table-level UPDATE would also expose protected columns such as amount, entry time, capacity and linkage IDs. `SELECT * FROM staff_user` is denied to the auditor; it must request the three approved columns explicitly.

No blanket future runtime/auditor grants are installed. New objects need reviewed grants after owner-scoped migrations. Table/sequence PUBLIC revokes preserve PostgreSQL's normally private defaults; function EXECUTE needs an explicit global default revoke. Defaults apply to the creating role, not automatically every member. Use `SET ROLE parkit_owner_grp` for consistent object ownership. Separate-session probes verified future table, sequence and function denials and removed those objects afterwards.

## 4. Part D - Least-privilege verification

| Activity 4 requirement | Implemented control and actual verification |
|---|---|
| Application avoids superuser | Private PHP configuration uses `parkit_app`; complete HTTP entry/payment workflow succeeds with that login |
| Login/group separation | Three NOLOGIN groups and three LOGIN members, one designated membership each; catalog includes inheritance and ADMIN OPTION |
| No cross-project access | All three project logins actually denied CONNECT to `parkit_unrelateddb`, `postgres` and `template1` |
| Restricted writes | Runtime cannot change payment amount/timestamp/link, entry timestamp/link, capacity, staff roles, or delete transaction/payment history |
| Read-only auditor | Reads succeed; INSERT/UPDATE/DELETE denied on all five tables; hashes and staff SELECT-star denied |
| Limited sequence rights | Runtime USAGE on three insert sequences; staff/zone nextval and setval denied; auditor nextval denied on all five sequences |
| No unnecessary elevated attributes | All six role attributes checked; CREATE DATABASE, CREATE ROLE and SET ROLE postgres denied for each login |
| No runtime/auditor ownership or DDL | CREATE schema/table/temp-table, ALTER, TRUNCATE and owner-membership escalation denied |
| Public/inherited access reviewed | Database, schema, relation, column and default ACLs plus memberships captured in catalog evidence |
| Legitimate owner work remains possible | DBA creates/alters/drops a project probe table, provisions a zone, and ANALYZEs a project table |
| Database integrity remains active | Deleting a referenced vehicle denied by foreign-key SQLSTATE `23503`, independently of table DELETE permission |

A permission denial is generally SQLSTATE `42501`; a foreign-key rejection is not a privilege denial. psql's startup CONNECT errors omit the SQLSTATE, so those checks compare its explicit CONNECT-privilege diagnostic instead of inventing a captured code. [Part E](part_e.md) records the individual statements, expectations and actual output links.

These controls do not enforce the web Admin/Staff distinction or all parking-state rules. Staff vehicle registration/editing and the direct-SQL duplicate-entry/negative-occupancy findings remain open. The owner can intentionally override ordinary project restrictions, so the DBA account is trusted and kept out of normal requests.

## 5. Reproduction and evidence

From this report folder, after initializing a new dedicated cluster with the same socket/port and provisioning authentication, the performed setup is reproducible with:

```sh
git clone https://github.com/millerdevera6-glitch/park-it-database.git /tmp/activity4-grp02-source
git -C /tmp/activity4-grp02-source checkout 0c01b3e87cf3d623f5f8c4936e3fe7fe56daeeb3
python3 setup_lab.py
python3 run_verification.py
python3 validate_application.py
psql -X -w -h /tmp/activity4-grp02-lab -p 55442 -U postgres -d grp_parkitdb \
  -f sql/verify_catalog.sql -o evidence/catalog.txt
```

`setup_lab.py` requires a fresh cluster and refuses to overwrite an existing private credential file. Its defaults match the evaluated lab. It imports the pinned schema, executes both SQL scripts, prepares a private PHP copy and runs the upstream seed as the DBA. The source checkout remains unchanged. The seeder's raw HTML is not saved because it prints demo passwords.

The evaluated cluster was initialized with:

```sh
initdb -D /tmp/activity4-grp02-lab -U postgres --auth-local=peer --auth-host=scram-sha-256 --no-locale -E UTF8
```

Its `postgresql.conf` selects `listen_addresses='127.0.0.1'`, `port=55442` and `unix_socket_directories='/tmp/activity4-grp02-lab'`. Its local `pg_hba.conf` entries are `local all postgres peer map=lab_admin` followed by `local all all scram-sha-256`; TCP entry is `host all all 127.0.0.1/32 scram-sha-256`. The peer map is `lab_admin me postgres`, where `me` is the evaluated operating-system username; adapt that mapping on another machine. The cluster starts with `pg_ctl -D /tmp/activity4-grp02-lab -l /tmp/activity4-grp02-lab/server.log start`. These files stay outside the repository.

For individual authenticated checks, use a password prompt:

```sh
psql -X -W -h 127.0.0.1 -p 55442 -U parkit_app -d grp_parkitdb
psql -X -W -h 127.0.0.1 -p 55442 -U parkit_auditor -d grp_parkitdb
psql -X -W -h 127.0.0.1 -p 55442 -U parkit_dba -d grp_parkitdb
```

The verification runner uses one direct authenticated connection per case, ON_ERROR_STOP and verbose SQL errors. It compares process result and the expected diagnostic; a zero psql exit status alone is not treated as proof of a denial. SQL write/DDL probes roll back, except temporary future objects that must be committed for independent-session checks and are explicitly dropped afterwards. HTTP requests commit their named disposable fixture, which the DBA subsequently removes in foreign-key order. The PHP server is stopped after the HTTP checks.

The scripts write evidence files on rerun. Preserve an earlier evidence snapshot separately if needed. Sequence values can advance even when probe transactions roll back. Do not rerun the setup scripts over the current lab or apply the lab's administrative-database revokes to a shared server without reviewing existing users.
