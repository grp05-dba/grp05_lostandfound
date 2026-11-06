# Part D - Query Performance Analysis

## Selected source query and account

The query comes from [the pinned application source](https://github.com/EclipseChan/bwisIT-Solutions---Campus-Canteen-Pre-Order-and-Queue-Management-System/blob/5056cb1c1cddca71c0641dd01fc7b82082f1c3ed/src/main/java/com/bwisit/canteen/service/ReportService.java), commit `5056cb1c1cddca71c0641dd01fc7b82082f1c3ed`, blob `7ec9e9ddac564f247d048ec90a0d22df4df6deb4`. [Provenance](evidence/query_provenance.json) records the exact statement and adaptation: **G08 native administrator count query with concrete last-30-day timestamps**. It serves the application administrator sales report.

```sql
SELECT count(*) FILTER (WHERE o.status = 'completed'), count(*) FILTER (WHERE o.status = 'cancelled'), count(*) FROM customer_order o WHERE o.order_date >= TIMESTAMP '2026-10-08 00:00:00' AND o.order_date < TIMESTAMP '2026-11-07 00:00:00';
```

Direct account: **`canteen_app`**, the Activity 4 restricted service login. Plain EXPLAIN ran first, followed by EXPLAIN (ANALYZE, BUFFERS) on this safe SELECT in a bounded READ ONLY transaction. No application result values were copied; EXPLAIN describes execution instead. The SQL and initial/final outputs are linked below.

## Before and after observations

| Measurement | Before maintenance | After maintenance |
|---|---:|---:|
| Target scan estimated rows | 4 | 2 |
| Target scan actual output rows | 2.0 | 2.0 |
| Root estimated / actual rows | 1 / 1.0 | 1 / 1.0 |
| JSON-plan execution time, ms | 0.424 | 0.446 |
| JSON-plan planning time, ms | 3.688 | 3.99 |
| Root shared hits / reads | 1 / 0 | 1 / 0 |

Evidence: [initial text plan](evidence/query_plan_before.txt), [initial JSON plan](evidence/query_plan_before.json), [final text plan](evidence/query_plan_after.txt), [final JSON plan](evidence/query_plan_after.json), [runnable SQL](sql/04_query_plan.sql). Text and JSON plans are **separate executions**, so their timings may differ. The comparison table consistently uses JSON capture values; it is not an average or a benchmark distribution.

Initial missing statistics overestimated the filtered order scan (4 versus 2 actual); refresh brought the estimate to 2. The Aggregate returns one row of counts, so its own estimate/actual is 1/1; this must not be confused with underlying scanned rows.

## Final node summary and interpretation

| Node | Relation/index | Estimated output rows | Actual output rows per loop | Loops |
|---|---|---:|---:|---:|
| Aggregate | `—` | 1 | 1.0 | 1 |
| Seq Scan | `customer_order` | 2 | 2.0 | 1 |

Root buffer figures include child work; do not sum inclusive node counts as separate physical I/O. The displayed plans have zero shared reads at the root in these captures and no root temp read/write spill. The final plan uses an aggregate over a sequential scan. Costs are planner units, not milliseconds.

## Recommendation and limits

The sequential scan over two orders is reasonable. No new index is justified now. At a larger order history, evaluate the date-range predicate and report frequency before testing an order_date or vendor/date index; account for insert/update and storage costs. Do not force an index on this tiny dataset.

The measured execution times are small local seed-data samples. Cache warming, process/host scheduling and instrumentation can change individual timings. The after sample is slower despite verified maintenance; no speedup is claimed. Better row estimates are a supported observation, not proof of production throughput or endpoint latency. No synthetic workload, index, forced scan, application-source rewrite or realistic concurrent-load benchmark was introduced.

Reference: [PostgreSQL 18 Using EXPLAIN](https://www.postgresql.org/docs/18/using-explain.html).
