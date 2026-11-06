# Part D – Query Performance Analysis

## Actual application SELECT

`Report::getStatistics()` in [src/models/Report.php](https://github.com/jeffersonorpesa2-ops/grp07-campussafe/blob/3684b97cfa8b8c6624d039eda461551ade774701/src/models/Report.php) computes category counts for `public/admin/stats.php`, whose route permits application Administrator/Auditor roles. [Source provenance](evidence/08_source_query.txt) retains the exact query/caller context:

```sql
SELECT c.category_name, COUNT(r.report_id) AS count
FROM hazard_category c
LEFT JOIN hazard_report r ON c.category_id = r.category_id
GROUP BY c.category_name
ORDER BY count DESC;
```

The direct **`campussafe_app` / `campussafe_runtime_grp`** connection represents the PHP shared runtime. The application's Auditor screen uses that runtime connection, while the separate `campussafe_report` login is for database inspection. No GUI authentication or live deployment configuration was tested here.

[04_query_plan.sql](sql/04_query_plan.sql) first ran plain EXPLAIN, then EXPLAIN (ANALYZE, BUFFERS), at **19:08:06 +08 on 6 November 2026**, after maintenance. Only this safe SELECT ran, inside a read-only transaction with public search path and a 30-second timeout, ending in ROLLBACK. No incident descriptions, account details or output row values were printed.

## Measured plan

[Full output](evidence/04_query_plan.txt) records:

```text
Sort (cost=2.59..2.60 rows=6 width=19)
  (actual time=0.127..0.129 rows=6.00 loops=1)
  Sort Key: (count(r.report_id)) DESC
  Sort Method: quicksort  Memory: 25kB
  Buffers: shared hit=5
  -> HashAggregate (estimated rows=6; actual rows=6.00)
       Group Key: c.category_name
       Batches: 1  Memory Usage: 32kB
       -> Hash Right Join (estimated rows=16; actual rows=16.00)
            Hash Cond: (r.category_id = c.category_id)
            -> Seq Scan on hazard_report r (estimated/actual rows=16)
            -> Hash (actual rows=6.00; Memory Usage: 9kB; Batches: 1)
                 -> Seq Scan on hazard_category c (estimated/actual rows=6)
Planning Time: 0.189 ms
Execution Time: 0.185 ms
```

## Interpretation and recommendation

The planner hashes the six categories and scans sixteen hazard reports. Its **hash right join is an equivalent physical arrangement of the SQL left join**, preserving categories with no matching reports. COUNT of `report_id` gives zero for an unmatched category; changing it to COUNT(*) would change that behavior. The hash aggregate produces six category totals, which are sorted descending by count.

Estimates match the observed category scan (six), report scan (sixteen), join output (sixteen) and grouped output (six). Hash operations used one batch, and the quicksort stayed in memory (25 kB); no displayed temp spill or shared read occurred. Execution reports five shared-buffer hits at the top node; node counters include child activity and should not be summed as separate physical I/O. Planning separately reports four hits. The measured 0.185 ms is one warm local seed-data sample, not endpoint latency or concurrent-load capacity.

**No immediate index change is justified.** The aggregation reads all reports and categories, so sequential scans are proportionate. `idx_report_category(category_id)` already supports category relationships/selective filtering; a duplicate category index would add storage, insert/update/WAL and maintenance cost without an established benefit. An index cannot by itself avoid processing the complete current report population for this all-time summary.

Preserve the outer join and COUNT semantics. With representative data volume and request frequency, repeat plans after appropriate statistics maintenance and measure whether the summary becomes expensive. If it does, evaluate a justified time filter, summary cache or maintained aggregate against the requirement for fresh all-time totals and the added refresh/consistency cost. No index, cache or rewrite was implemented, and no before/after speedup is claimed.
