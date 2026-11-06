# Part D - Query Performance Analysis

## Selected source query and account

The query comes from [the pinned application source](https://github.com/kathlenmaecallos11-arch/Restaurant-Online-Ordering-Table-Reservation-System/blob/9e1141a51515fcede0fe176ee5f47cfb6c8abf9b/restaurant-ordering-reservation-system/app/src/controllers/menu.php), commit `9e1141a51515fcede0fe176ee5f47cfb6c8abf9b`, blob `7a425d0ae15776b4e70b228b60fcd44c7398decb`. [Provenance](evidence/query_provenance.json) records the exact statement and adaptation: **G10 menu query with empty search/category, verbatim assembled SQL**. It serves public/customer menu browsing with no search/category filter.

```sql
SELECT menu_item_id, item_name, description, category, price FROM menu_item WHERE availability = true ORDER BY category, item_name;
```

Direct account: **`rors_app`**, the Activity 4 restricted service login. Plain EXPLAIN ran first, followed by EXPLAIN (ANALYZE, BUFFERS) on this safe SELECT in a bounded READ ONLY transaction. No application result values were copied; EXPLAIN describes execution instead. The SQL and initial/final outputs are linked below.

## Before and after observations

| Measurement | Before maintenance | After maintenance |
|---|---:|---:|
| Target scan estimated rows | 48 | 48 |
| Target scan actual output rows | 48.0 | 48.0 |
| Root estimated / actual rows | 48 / 48.0 | 48 / 48.0 |
| JSON-plan execution time, ms | 0.321 | 0.472 |
| JSON-plan planning time, ms | 4.716 | 5.371 |
| Root shared hits / reads | 4 / 0 | 4 / 0 |

Evidence: [initial text plan](evidence/query_plan_before.txt), [initial JSON plan](evidence/query_plan_before.json), [final text plan](evidence/query_plan_after.txt), [final JSON plan](evidence/query_plan_after.json), [runnable SQL](sql/04_query_plan.sql). Text and JSON plans are **separate executions**, so their timings may differ. The comparison table consistently uses JSON capture values; it is not an average or a benchmark distribution.

The menu estimate was already accurate at 48 returned rows before manual maintenance, consistent with prior automatic analyze. Two of the 50 menu rows were filtered out. Refresh maintained that estimate; it did not establish a new access-path improvement.

## Final node summary and interpretation

| Node | Relation/index | Estimated output rows | Actual output rows per loop | Loops |
|---|---|---:|---:|---:|
| Sort | `—` | 48 | 48.0 | 1 |
| Seq Scan | `menu_item` | 48 | 48.0 | 1 |

Root buffer figures include child work; do not sum inclusive node counts as separate physical I/O. The displayed plans have zero shared reads at the root in these captures and no root temp read/write spill. The final plan uses an in-memory sort over a sequential scan. Costs are planner units, not milliseconds.

## Recommendation and limits

Scanning 50 menu rows and sorting the 48 available items is reasonable. An availability/category/name or partial available-menu index could be benchmarked at a much larger catalog, but an unselective availability predicate and returning most rows may still favor a scan. Price/catalog writes and index storage have costs; no index was created.

The measured execution times are small local seed-data samples. Cache warming, process/host scheduling and instrumentation can change individual timings. The after sample is slower despite verified maintenance; no speedup is claimed. Better row estimates are a supported observation, not proof of production throughput or endpoint latency. No synthetic workload, index, forced scan, application-source rewrite or realistic concurrent-load benchmark was introduced.

Reference: [PostgreSQL 18 Using EXPLAIN](https://www.postgresql.org/docs/18/using-explain.html).
