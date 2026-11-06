# Part C – Routine Maintenance

## Pre-maintenance assessment

[Initial evidence](evidence/01_health.txt) shows 12 small tables, 12 sequences and 24 primary/unique indexes. The largest observed table-plus-index total was `users` at 64 kB. There were 12 exact live rows and 18 estimated dead tuples, no recorded analyze/vacuum history, and `reltuples=-1` on every table. Autovacuum is enabled, but this tiny test workload had not produced recorded automatic maintenance. Earlier rolled-back linked-record tests plausibly explain the dead tuples; this is an inference grounded in Activity 4, not a claim of production churn.

The 24 existing indexes include `student_requirements(student_id, req_id)`, which already supports the selected query's student filter and requirement join. No additional index or rebuild was justified by this inventory alone. This was not an index-corruption inspection.

Before execution, these purposes and impacts were assessed:

- **ANALYZE** establishes current planner statistics for the seeded tables and empty workflow tables. It uses sampling/CPU/I/O and takes locks; the local idle environment and small sizes make a baseline proportionate.
- **Ordinary VACUUM** removes dead tuple versions, makes space reusable and maintains visibility/freeze metadata. The known 18 dead tuples justify cleanup; empty `audit_log` was included in the small complete baseline, not treated as bloated.
- **VACUUM with ANALYZE** refreshes statistics after cleanup. Explicit ANALYZE followed by the combined operation intentionally demonstrates both required operations; repeating both is unnecessary as a standing schedule.

Ordinary vacuum generally allows normal DML but conflicts with some DDL/maintenance and may briefly request a stronger lock for tail-page truncation. The initial snapshot had no competing project session. `lock_timeout=3s` and `statement_timeout=30s` bound waits/work. There was no reason for VACUUM FULL or emergency freeze work; observed XID ages were 26.

## Account and executed commands

The direct `grp03_ojt_dba` login inherits the owning `grp03_ojt_admin_grp`. The [maintenance script](sql/03_maintenance.sql) first confirmed effective `MAINTAIN` on every table, then ran explicit statements on all 12 tables, for example:

```sql
ANALYZE VERBOSE public.student_requirements;
VACUUM (VERBOSE, ANALYZE) public.student_requirements;
```

No superuser, role switching, ownership changes or new privileges were needed. VACUUM ran standalone through psql, outside transaction blocks; `--single-transaction` must not be used.

## Results and preservation checks

Execution at **17:59:34 +08, 6 November 2026**, completed **12 ANALYZE and 12 VACUUM commands**, with no ERROR, WARNING or skipped-table result. [Verbose evidence](evidence/03_maintenance.txt) records these primary-table removals; any separate TOAST output is not double-counted:

| Table | Dead tuples removed | Exact live rows before/after |
|---|---:|---:|
| `academic_supervisors` | 1 | 1 |
| `attendance` | 2 | 0 |
| `audit_log` | 0 | 0 |
| `companies` | 1 | 1 |
| `company_supervisors` | 1 | 1 |
| `evaluations` | 1 | 0 |
| `ojt_applications` | 2 | 0 |
| `ojt_placements` | 2 | 0 |
| `requirements` | 1 | 3 |
| `student_requirements` | 2 | 0 |
| `students` | 1 | 1 |
| `users` | 4 | 5 |
| **Total** | **18** | **12** |

A fresh auditor session at **17:59:36 +08** executed [05_verify.sql](sql/05_verify.sql). [Verification output](evidence/05_verify.txt) shows current `last_vacuum`/`last_analyze` timestamps, `vacuum_count=1`, `analyze_count=2`, zero dead tuples and zero modifications-since-analysis on every table. Exact aggregate counts match the initial 12-table counts. Two analysis completions per table reflect the explicit ANALYZE and VACUUM ANALYZE.

No live records, audit rows, schema definitions, object grants or sequence values were changed by application DML or DDL in this activity. Maintenance updates storage, visibility and catalog/statistics as expected. Vacuum reclaimed dead versions without deleting seeded records; it does not demonstrate a need for database-wide disk reclamation.

**Recommendation:** retain autovacuum, check dead-tuple/modification trends and refresh statistics after substantial future loads. Choose further manual maintenance from observed workload rather than a fixed aggressive schedule on a tiny seed database.
