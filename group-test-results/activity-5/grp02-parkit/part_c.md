# Part C – Routine Maintenance

## Review and choice of operations

The initial [table/index inspection](evidence/01_health.txt) found five empty tables and nine valid-looking index definitions supporting primary/unique constraints. It did not perform a physical corruption check. There is no additional status/entry-time index on `transaction`; that is a conditional performance recommendation in Part D rather than a reason to create one now.

All tables initially had `reltuples=-1` (no established row-count estimate) and no recorded manual/automatic analyze or vacuum timestamps in the available statistics. `vehicle.n_dead_tup=2`, while all exact live row counts were zero. The two rolled-back vehicle inserts documented in Activity 4 are a plausible source; this attribution is an inference. Autovacuum, activity tracking and count tracking are enabled, with no per-table storage-option override recorded. No large backlog or wraparound emergency was identified (observed table XID ages were 46).

Before execution, the following purposes and impacts were assessed:

- **ANALYZE:** establish current planner statistics for each small application table, including empty relations. Sampling has CPU/I/O and locking costs; this local idle setup is suitable.
- **Ordinary VACUUM:** remove the known dead vehicle tuples, make space reusable and maintain visibility/freeze information. Run once across the five tiny tables to establish a documented maintenance baseline. The other empty tables have no demonstrated bloat emergency.
- **VACUUM with ANALYZE:** refresh statistics after cleanup. The explicit ANALYZE followed by the combined command intentionally performs two analyses per table to demonstrate both required operations; repeating both is unnecessary as a routine schedule.

Ordinary VACUUM allows normal DML in general, but conflicts with some maintenance/DDL and can briefly request a stronger lock when truncating empty tail pages. This was assessed against the idle local environment. `lock_timeout=3s` and `statement_timeout=30s` bound waits/work. `VACUUM FULL` and index creation were not needed.

## Account and commands

`park_it_dba` connected directly and had effective `MAINTAIN` on all five tables, despite `postgres` owning them. The Activity 4 `ALL PRIVILEGES ON ALL TABLES` grant includes table maintenance in this PostgreSQL installation. Runtime and auditor accounts had no maintenance privilege. No ownership or role changes were required.

The complete executed [03_maintenance.sql](sql/03_maintenance.sql) ran outside any transaction block through `psql -X -w -a -U park_it_dba -d grp_parkitdb -f ...`. For each real table it executed:

```sql
ANALYZE VERBOSE public.vehicle;
VACUUM (VERBOSE, ANALYZE) public.vehicle;
```

The same two operations were explicitly issued for `parking_zone`, `payment`, `staff_user`, and `"transaction"`. The script contains the exact command list and safety timeouts. It must not be run using `--single-transaction`.

## Actual outcomes

Maintenance ran at **17:39:50 +08 on 6 November 2026**. [Full verbose evidence](evidence/03_maintenance.txt) records five `ANALYZE` completions and five `VACUUM` completions, with no ERROR, WARNING or skipped-table message. The process exited successfully.

For `vehicle`, PostgreSQL reported:

```text
table "vehicle": truncated 1 to 0 pages
tuples: 2 removed, 0 remain, 0 are dead but not yet removable
```

That ordinary vacuum also cleaned dead item identifiers from its two indexes. The four other table vacuums reported zero tuples removed and zero remaining. No rebuild or database-wide disk-reduction claim is inferred from this small cleanup.

A fresh auditor session at **17:39:55 +08** ran [05_verify.sql](sql/05_verify.sql). [Verification output](evidence/05_verify.txt) shows:

| Table | Live/dead estimates after | `vacuum_count` | `analyze_count` | Exact rows after |
|---|---|---:|---:|---:|
| `parking_zone` | 0 / 0 | 1 | 2 | 0 |
| `payment` | 0 / 0 | 1 | 2 | 0 |
| `staff_user` | 0 / 0 | 1 | 2 | 0 |
| `transaction` | 0 / 0 | 1 | 2 | 0 |
| `vehicle` | 0 / 0 | 1 | 2 | 0 |

Each table has current `last_vacuum` and `last_analyze` timestamps. Before/after exact counts agree. No live application records were inserted, updated or deleted, and no sequence was reset. Maintenance itself updates catalog/statistics, visibility information and physical storage as expected.

**Recommendation:** retain autovacuum and monitor dead tuples, modification counts and analyze timestamps after real data is loaded. Analyze after substantial initial loading and reassess plans then. A fixed aggressive manual vacuum schedule is not justified by this empty test database.
