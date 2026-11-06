# Part A – Database Health and Activity Inspection

Group 5 inspected Group 6's HabalGo database on **6 November 2026**. Health evidence was captured at **18:28:48 Asia/Manila (UTC+08)** after installing the missing local prerequisites from the supplied repository.

## Environment and prerequisite setup

| Item | Verified value |
|---|---|
| Repository | https://github.com/jeanaroyo/HabalGo |
| Reviewed branch/commit | `main`, `c523913b6ffa57dae754a7fb6e4d6ffed4ac7070` |
| Source verification | Clean temporary clone at that commit; source files were not edited |
| Database/schema | `grp00_habalgodb` / `habalgo` |
| PostgreSQL | 18.6, x86_64 Linux |
| Connection | Local Unix socket, port 5432, direct named logins |
| Database/table owner | `postgres` |
| Initial post-setup size | 8,345,279 bytes, displayed as `8150 kB` |
| Schema objects | Eight tables, seven SERIAL sequences, seventeen indexes |

The repository **does contain** `database/03_roles_and_privileges.sql`. The earlier connection failures meant its login definitions were not installed locally, not that the source file was absent. Our Activity 4 HabalGo folder contained only `.gitkeep`; [pre-setup inventory](evidence/00_initial_inventory.txt) independently confirmed that neither documented database name (`grp00_habalgodb` or `habalgo`) nor the four supplied roles existed locally.

The source prerequisites were then installed in a new local `grp00_habalgodb`: the root `schema.sql`, the role script with **all PASSWORD clauses removed**, and the README's root `sample data.sql` seed (ten drivers). [Setup scripts](setup/01_database.sql), [schema](setup/02_schema.sql), [sanitized roles](setup/03_roles.sql) and the `00_*` evidence files document this work. The original credential-bearing role script was not executed or committed. No existing HabalGo data was overwritten because the target database did not exist. The older Activity 3 isolated test cluster was not reused.

The setup administrator `postgres` was used only to inventory/provision prerequisites, create schema/roles and load the documented sample seed. **Activity 5 health, log-access probes, maintenance-limit demonstration and query plans used the dedicated accounts afterward.** No maintenance command was retried as superuser to evade its role restriction. This is newly installed source role configuration, not a claim that a prior local Activity 4 verification was already complete.

## Accounts and role comparison

| Task | Direct account | Supplied group/responsibility |
|---|---|---|
| Health, roles, logging settings/access probes, post-check verification | `habalgo_readonly_user` | `app_readonly_grp`, read-only inspection |
| Query plan and maintenance-limit probe | `habalgo_app_user` | `app_runtime_grp`, PHP service runtime |
| Accessible service journal | Existing OS user `me` | OS read access; no database role substitution |

Every SQL capture records `session_user` and `current_user`. The two groups are NOLOGIN, the two account roles have LOGIN, and each account has only its supplied group membership. All four have INHERIT and lack SUPERUSER, CREATEDB, CREATEROLE, BYPASSRLS and REPLICATION; membership ADMIN OPTION is false.

The runtime has SELECT/INSERT/UPDATE/DELETE on the eight tables and USAGE/SELECT on seven sequences. The read-only role has SELECT on the tables and no sequence USAGE/SELECT. Neither has TRUNCATE or MAINTAIN. Schema USAGE is granted to both groups; schema CREATE remains with the owner. These observed grants match the sanitized supplied plan. No separate maintenance account is supplied by it.

The groups' generic cluster-wide names should be reviewed before future reuse by another project. Database PUBLIC CONNECT/TEMPORARY remains, and both logins have effective CONNECT to unrelated `postgres` through defaults there. These are catalog findings, not new unrelated-database connection tests or evidence of unrelated table access. No other project's privileges were changed.

The PHP code has no implemented login/role-specific UI boundary in the reviewed API. These PostgreSQL roles represent service/inspection duties; they do not authenticate an individual driver or customer. Password authentication, remote access, full negative privilege tests and running PHP configuration were not exercised.

## Health, objects and activity

[01_health.sql](sql/01_health.sql) and [its output](evidence/01_health.txt) show **ten exact live rows**, all in `driver`. `booking`, `customer`, `driver_vehicle`, `location`, `payment`, `rating_feedback` and `vehicle` each have zero rows. No driver names, phone numbers or license values were copied into evidence. The driver/vehicle assignment table has a composite key and no sequence, explaining seven sequences for eight tables.

All table dead-tuple estimates are zero. `driver.n_mod_since_analyze=10`, every table has `reltuples=-1`, and no manual/automatic analyze or vacuum history is recorded after this fresh installation. Autovacuum and activity/count tracking are enabled with no table storage-option override shown. Table/index totals are 8–40 kB and XID ages are 21–28. This is a small seed dataset with no demonstrated bloat or wraparound emergency; statistics refresh is the useful next maintenance step.

The initial snapshot showed **one connection**, the read-only inspection query (PID 58132), approximately **2.295 ms** into execution. No other active/idle project sessions appeared and `pg_blocking_pids` returned `{}`. No current blocker or long-running query was observed. Other accounts' SQL is intentionally omitted and may also be restricted by PostgreSQL privileges; this single-session snapshot does not establish cross-account visibility or long-term behavior.

Counters showed `xact_commit=38`, `xact_rollback=0`, `deadlocks=0`, `conflicts=0`, `sessions=4`, and zero abandoned/fatal/killed sessions; `stats_reset` was NULL. These post-creation counters do not erase or explain the pre-setup failed connection attempts, which are preserved in the service journal and discussed in Part B.

**Assessment:** the installed test database is reachable and responsive, with no current blocking. The initial missing-role/database blocker is resolved. Maintenance privileges, statistics, broad connection defaults and the limited seed-only workload remain qualifications.
