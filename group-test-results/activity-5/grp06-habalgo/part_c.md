# Part C – Routine Maintenance

**Outcome: maintenance permission limitation demonstrated; successful maintenance remains outstanding.** The source role plan supplies runtime and read-only access but no maintenance identity. Its roles were installed without adding extra maintenance grants.

## Review and purpose

[Health evidence](evidence/01_health.txt) shows eight small tables, seven sequences and seventeen indexes. Ten documented sample drivers were loaded; all other tables are empty. Dead-tuple estimates are zero, no maintenance timestamps are recorded, and every table has `reltuples=-1`. Driver modifications-since-analysis are ten. Autovacuum is enabled, table/index totals are 8–40 kB and XID ages are 21–28. There is no observed bloat or wraparound emergency.

The driver table has primary-key and unique-license indexes but no name index. The chosen query sorts driver names; its small dataset does not justify a speculative index. The index inventory is not a physical corruption check.

Before running the restricted demonstration, the following purposes and impacts were assessed:

- **ANALYZE** would establish planner statistics after seeding. This is the useful maintenance need: Part D estimated 190 driver rows but actually found ten.
- **Ordinary VACUUM** would reclaim dead versions and maintain visibility/freeze metadata. There is no dead-tuple backlog to clear; a single-table attempt establishes whether the supplied account can perform the required routine approach.
- **VACUUM with ANALYZE** combines cleanup and statistics refresh. It must run outside a transaction block. FULL vacuum and index rebuilds are unnecessary for this small setup.

Ordinary vacuum may conflict with DDL/maintenance and can briefly request a stronger lock for tail truncation. The initial snapshot had no competing session. The demonstration used `lock_timeout=3s` and `statement_timeout=30s`. Catalog checks already showed MAINTAIN=false, so permission skips were expected; the attempt was not repeated on all tables.

## Account, commands and actual result

At **18:28:50 +08 on 6 November 2026**, the direct `habalgo_app_user` login ran [03_maintenance.sql](sql/03_maintenance.sql). It confirmed `postgres` ownership and false MAINTAIN for all eight tables, then issued:

```sql
ANALYZE VERBOSE habalgo.driver;
VACUUM (VERBOSE, ANALYZE) habalgo.driver;
```

[Actual output](evidence/03_maintenance.txt):

```text
WARNING:  01000: permission denied to analyze "driver", skipping it
ANALYZE
WARNING:  01000: permission denied to vacuum "driver", skipping it
VACUUM
```

The table was **skipped**. The command tags and zero psql exit status do not mean maintenance succeeded; warning-only skips also are not prevented simply by ON_ERROR_STOP. No superuser retry, SET ROLE, ownership change or MAINTAIN grant was used. The earlier administrative schema/role/seed installation was a separate prerequisite step, not maintenance under a different account.

## Verification and next step

A fresh `habalgo_readonly_user` session at **18:28:51 +08** ran [05_verify.sql](sql/05_verify.sql). [Output](evidence/05_verify.txt) confirms ten driver rows and zero rows in the seven other tables, unchanged from health inspection. All vacuum/analyze counts remain zero and timestamps NULL; driver modifications-since-analysis remain ten. The seed load intentionally created the ten drivers before inspection; Activity 5 checks added/updated/deleted no application records and consumed no sequence values.

An authorized access-control owner should review a project-scoped maintenance group/login, with suitable CONNECT/schema access and table-level MAINTAIN for the intended tables, or deliberately scoped ownership. The supplied `app_runtime_grp` and `app_readonly_grp` should keep their existing duties. Do not grant broad cluster-wide maintenance or superuser access merely to satisfy this exercise.

After approving that role plan, run ANALYZE on the seeded driver table and proportionate ordinary VACUUM, capture verbose output without skips and confirm current timestamps/counters and unchanged row counts. Recheck the query estimate afterward. Never use `--single-transaction` for VACUUM or add VACUUM FULL without the required instructor approval. No follow-up maintenance or performance improvement from it is claimed here.
