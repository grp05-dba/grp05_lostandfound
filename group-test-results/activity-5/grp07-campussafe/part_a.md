# Part A – Database Health and Activity Inspection

Group 5 inspected Group 7's CampusSafe database on **6 November 2026**, with health evidence captured at **19:08:02 Asia/Manila (UTC+08)** after installing the missing local prerequisites.

## Environment and setup context

| Item | Observed value |
|---|---|
| Repository | https://github.com/jeffersonorpesa2-ops/grp07-campussafe |
| Reviewed source | `main`, commit `3684b97cfa8b8c6624d039eda461551ade774701` |
| Source verification | Clean temporary clone at that commit; owning-group source unchanged |
| Database/schema | `grp07_campussafedb` / `public` |
| PostgreSQL | 18.6, x86_64 Linux |
| Connection | Local Unix socket on port 5432, direct named logins |
| Database/table/sequence owner | `campussafe_owner`, non-superuser |
| Initial inspected size | 8,836,799 bytes, displayed as `8630 kB` |
| Public objects | Nine tables, nine SERIAL sequences, twenty-four indexes |

Our Activity 4 CampusSafe folder contained only `.gitkeep`. The initial reporting login failed because the role was absent; [inventory](evidence/00_initial_inventory.txt) also found neither the documented database nor the earlier Activity 3 isolated database. This run therefore installed source prerequisites into a **new local database** rather than inspecting an already-completed Activity 4 environment.

Local setup adaptations are explicit:

- The source schema's DROP TABLE reset statements were removed from [setup/02_schema.sql](setup/02_schema.sql). The seed's TRUNCATE reset was removed in a temporary copy, which loaded the supplied sample records without echoing hashes/data. No seed copy containing hashes is committed.
- All PASSWORD clauses were removed from [setup/03_roles.sql](setup/03_roles.sql). The three generic source groups were renamed `campussafe_runtime_grp`, `campussafe_readonly_grp` and `campussafe_backup_grp`: HabalGo already uses the generic names on this shared cluster. Existing HabalGo roles/grants were not altered.
- [docs/user-roles.md](https://github.com/jeffersonorpesa2-ops/grp07-campussafe/blob/3684b97cfa8b8c6624d039eda461551ade774701/docs/user-roles.md) explicitly names non-superuser `campussafe_owner` for VACUUM/ANALYZE, but the installer script does not create it. [setup/04_owner.sql](setup/04_owner.sql) implements that documented identity, assigns this database's tables/sequences to it and aligns migration-owner defaults with the supplied plan.

The cluster administrator was used only for prerequisite inventory and this new database/schema/role/seed/ownership setup. Subsequent Activity 5 SQL used dedicated accounts, including the documented non-superuser owner for maintenance. No superuser retry was used to evade a maintenance denial. The original destructive reset scripts and credential-bearing role script were not run unchanged. `00_*` evidence records the setup separately; a fully verified pre-existing Activity 4 configuration is not claimed.

## Accounts and role verification

| Direct account | Local group / documented responsibility | Activity 5 use |
|---|---|---|
| `campussafe_report` | `campussafe_readonly_grp`, database auditor/reporting | Health, log settings/access probes and verification |
| `campussafe_app` | `campussafe_runtime_grp`, PHP shared runtime | Actual dashboard query; aggregate-only counts of auditor-excluded tables |
| `campussafe_owner` | Project database/object owner, no group membership | ANALYZE and ordinary VACUUM |
| `campussafe_backup` | `campussafe_backup_grp`, backup reader | Presence/privileges inspected in catalog; no dump or direct backup session tested |
| Existing OS user `me` | Existing service-journal read access | Sanitized log review; no database impersonation |

All seven local role objects exist: four LOGIN accounts and three NOLOGIN groups. All lack SUPERUSER, CREATEDB, CREATEROLE, BYPASSRLS and REPLICATION; INHERIT is true. Each service/report/backup login has only its corresponding project group, with ADMIN OPTION false; the owner has no group membership. All four accounts have false membership checks for HabalGo's existing runtime/readonly groups.

Effective privileges match the source SQL's current-object plan: runtime SELECT on all nine tables, INSERT on eight (excluding `role`), UPDATE on five mutable tables, DELETE only on attachment/assignment, no TRUNCATE/MAINTAIN. Audit history and maintenance-action logs lack runtime UPDATE/DELETE. Reporting SELECT covers seven operational tables and excludes `app_user` and `role`; it has no writes or maintenance. Backup has SELECT on all tables, without writes/maintenance. The owner has actual ownership and effective MAINTAIN on all nine tables.

The project database has no PUBLIC database privileges; PUBLIC schema USAGE remains but CREATE is revoked. All four accounts still have effective CONNECT to unrelated `postgres` through its defaults. These are catalog checks, not actual unrelated connections or proof of table access. The source guide's unrelated-database denial expectation is therefore not established. No shared ACL was changed.

Application Administrator, Auditor, maintenance and reporter sessions use the PHP runtime account; the direct reporting login is a separate database inspection identity. Application route/row authorization is not established solely by these database grants. Password/remote authentication, backups and full negative privilege testing were not repeated here.

## Health, data and current activity

[01_health.sql](sql/01_health.sql) and [output](evidence/01_health.txt) capture health and catalog evidence. Runtime-only aggregate counts of `app_user` and `role` appear in [00_runtime_counts_before.txt](evidence/00_runtime_counts_before.txt); the reporting account was not given extra access to count them.

| Table | Exact seed rows | Account permitted to count |
|---|---:|---|
| `role` | 5 | Runtime |
| `app_user` | 6 | Runtime |
| `hazard_category` | 6 | Reporting |
| `campus_location` | 10 | Reporting |
| `hazard_report` | 16 | Reporting |
| `assignment` | 12 | Reporting |
| `report_status_history` | 60 | Reporting |
| `maintenance_action` | 9 | Reporting |
| `attachment` | 5 | Reporting |
| **Total** | **129** | Combined aggregate-only checks |

No user names, emails, password hashes, attachment paths or incident descriptions were selected into evidence. All dead-tuple estimates were zero. No manual analyze/vacuum history was recorded initially; `report_status_history` already had an **autoanalyze at 19:06:12 +08**, while the other tables had uninitialized catalog tuple estimates (-1). Autovacuum and activity/count tracking were enabled, with no table storage override shown. Table/index totals were 32–112 kB and XID ages 53–61, indicating no demonstrated bloat/wraparound emergency.

The snapshot showed one connection, the reporting account's inspection query (PID 74697), approximately **1.966 ms** into execution; no other active/idle session appeared. Blocking PID arrays were empty. Counters showed 83 committed transactions, zero rollbacks/deadlocks/conflicts, six sessions and zero abandoned/fatal/killed sessions; reset time was NULL. These fresh-database counters do not cover the initial failed connection as a complete historical audit. Other-session SQL is omitted and may also be permission-limited.

Aggregate adaptations of the supplied verification queries returned zero unverified reports with verifier fields, zero resolved/closed reports missing resolution timestamps and zero orphaned assignments. These three checks supplement constraints; they do not verify every business rule or attachment file.

**Assessment:** the new local setup is reachable, has coherent inspected seed relationships and no current blockers. Routine statistics/visibility maintenance is appropriate; connection scope and setup/documentation differences remain follow-up items.
