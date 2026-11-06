# Part D - Query Performance Analysis

## Selected source query and account

The query comes from [the pinned application source](https://github.com/karlrobertc-art/BoardTrack/blob/242b366936f17324dca7e4435bc1d6abe59b27d7/src/routes/leases.js), commit `242b366936f17324dca7e4435bc1d6abe59b27d7`, blob `ac10193246493818cf61895e3a73fe14f5fe6c97`. [Provenance](evidence/query_provenance.json) records the exact statement and adaptation: **G11 landlord/staff lease-list query plus ORDER BY 1 added by rowsFor; no tenant filter**. It serves the landlord/staff lease list; the tenant-specific WHERE filter is not part of this selected role variant.

```sql
SELECT lease_id, tenant_id, tenant, property_name, room_number, start_date, end_date, monthly_rent, status, total_paid, utilities_billed FROM v_lease_summary ORDER BY 1;
```

Direct account: **`boardtrack_app`**, the Activity 4 restricted service login. Plain EXPLAIN ran first, followed by EXPLAIN (ANALYZE, BUFFERS) on this safe SELECT in a bounded READ ONLY transaction. No application result values were copied; EXPLAIN describes execution instead. The SQL and initial/final outputs are linked below.

## Before and after observations

| Measurement | Before maintenance | After maintenance |
|---|---:|---:|
| Target scan estimated rows | 640 | 4 |
| Target scan actual output rows | 4.0 | 4.0 |
| Root estimated / actual rows | 640 / 4.0 | 4 / 4.0 |
| JSON-plan execution time, ms | 1.023 | 0.882 |
| JSON-plan planning time, ms | 20.532 | 22.167 |
| Root shared hits / reads | 22 / 0 | 15 / 0 |

Evidence: [initial text plan](evidence/query_plan_before.txt), [initial JSON plan](evidence/query_plan_before.json), [final text plan](evidence/query_plan_after.txt), [final JSON plan](evidence/query_plan_after.json), [runnable SQL](sql/04_query_plan.sql). Text and JSON plans are **separate executions**, so their timings may differ. The comparison table consistently uses JSON capture values; it is not an average or a benchmark distribution.

Before maintenance, the lease scan and top result were estimated at 640 versus 4 actual. Analyzing the six business inputs brought the relevant estimates to 4. Hash joins combine leases with rooms/properties/tenants. The summary view invokes two per-lease aggregates; Actual Rows values on repeated nodes are per-loop averages (for example 1.25 payment rows across four loops), not fractional physical rows.

## Final node summary and interpretation

| Node | Relation/index | Estimated output rows | Actual output rows per loop | Loops |
|---|---|---:|---:|---:|
| Sort | `—` | 4 | 4.0 | 1 |
| Hash Join | `—` | 4 | 4.0 | 1 |
| Hash Join | `—` | 4 | 4.0 | 1 |
| Hash Join | `—` | 4 | 4.0 | 1 |
| Seq Scan | `lease` | 4 | 4.0 | 1 |
| Hash | `—` | 6 | 6.0 | 1 |
| Seq Scan | `room` | 6 | 6.0 | 1 |
| Hash | `—` | 2 | 2.0 | 1 |
| Seq Scan | `property` | 2 | 2.0 | 1 |
| Hash | `—` | 4 | 4.0 | 1 |
| Seq Scan | `tenant` | 4 | 4.0 | 1 |
| Aggregate | `—` | 1 | 1.0 | 4 |
| Seq Scan | `payment` | 1 | 1.25 | 4 |
| Aggregate | `—` | 1 | 1.0 | 4 |
| Seq Scan | `utility_bill` | 1 | 1.0 | 4 |

Root buffer figures include child work; do not sum inclusive node counts as separate physical I/O. The displayed plans have zero shared reads at the root in these captures and no root temp read/write spill. The final plan includes an in-memory sort, hash joins, sequential scans and repeated aggregates. Costs are planner units, not milliseconds.

## Recommendation and limits

The view uses a correlated payment aggregate and utility aggregate once per lease (four loops each here). Existing lease_id indexes were visible before maintenance, but the refreshed statistics favor tiny sequential scans after it. With a larger lease history, benchmark a pre-aggregated payment/utility join or pagination against the existing indexed approach. Preserve tenant_id scoping and completed-payment semantics; avoid joining raw one-to-many payments and bills in a way that multiplies totals. No query/view/index was changed.

The measured execution times are small local seed-data samples. Cache warming, process/host scheduling and instrumentation can change individual timings. The after sample is lower, but one comparison does not establish a repeatable maintenance speedup. Better row estimates are a supported observation, not proof of production throughput or endpoint latency. No synthetic workload, index, forced scan, application-source rewrite or realistic concurrent-load benchmark was introduced.

Reference: [PostgreSQL 18 Using EXPLAIN](https://www.postgresql.org/docs/18/using-explain.html).
