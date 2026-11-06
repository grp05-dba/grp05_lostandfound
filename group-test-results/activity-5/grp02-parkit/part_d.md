# Part D – Query Performance Analysis

## Application query and execution context

The selected query supplies the **active parked vehicles list** in `park-it/modules/monitoring/api_status.php` (`$stmtActive`) from the [supplied repository at the reviewed commit](https://github.com/HelloP0/PARK-IT-DATABASE-MANAGEMENT-SYSTEM/blob/d369a457ce2dc88a024428513360f0ad76473f43/park-it/modules/monitoring/api_status.php). [Source excerpt and provenance](evidence/08_source_query.txt) retain the actual PHP query. It joins active transactions to vehicle and zone details and sorts newest entries first:

```sql
SELECT t.transaction_id, t.entry_time, t.status,
       v.license_plate, v.vehicle_type, z.zone_name
FROM public."transaction" t
JOIN public.vehicle v ON t.vehicle_id = v.vehicle_id
JOIN public.parking_zone z ON t.zone_id = z.zone_id
WHERE t.status = 'Active'
ORDER BY t.entry_time DESC;
```

The direct `park_it_app` login represents Activity 4's runtime role shared by application Admin and Staff sessions. It has the necessary SELECT permissions. This measures the query under that role; it does not prove a running PHP deployment already uses this account.

[04_query_plan.sql](sql/04_query_plan.sql) first ran plain EXPLAIN, then `EXPLAIN (ANALYZE, BUFFERS)` on the safe SELECT at **17:39:54 +08, 6 November 2026**, after maintenance. Both ran in `BEGIN READ ONLY` with a 30-second statement timeout and ended with ROLLBACK. The endpoint as a whole was not called: its earlier `getParkingSummary()` helper can update occupancy, whereas the selected statement only reads.

## Captured plan

The [full output](evidence/04_query_plan.txt) contains both plans. The measured plan's relevant operations were:

```text
Sort (cost=0.04..0.04 rows=1 width=364)
  (actual time=0.058..0.059 rows=0.00 loops=1)
  Sort Key: t.entry_time DESC
  Sort Method: quicksort  Memory: 25kB
  Buffers: shared hit=3
  -> Nested Loop
       Join Filter: (z.zone_id = t.zone_id)
       -> Nested Loop
            Join Filter: (v.vehicle_id = t.vehicle_id)
            -> Seq Scan on transaction t
                 Filter: ((status)::text = 'Active'::text)
                 (actual rows=0.00 loops=1)
            -> Seq Scan on vehicle v (never executed)
       -> Seq Scan on parking_zone z (never executed)
Planning Time: 0.238 ms
Execution Time: 0.104 ms
```

## Interpretation

| Plan feature | Interpretation |
|---|---|
| Sequential scan of `transaction` | Tests rows for `status='Active'`. With an empty table, scanning has negligible work. A sequential scan alone is not evidence of a bad plan. |
| Nested-loop joins | Connect matching vehicle and zone IDs. The outer scan found no transactions, so both inner scans were never executed. Their scalability was not measured. |
| Sort | Supplies descending entry-time order. It used in-memory quicksort, 25 kB, and returned no rows; no disk spill is shown. |
| Estimated versus actual rows | The top node and transaction scan estimated 1 row and actually returned 0. The small positive estimate in this empty relation does not demonstrate a serious statistics problem after ANALYZE. |
| Buffers and timing | Execution reported 3 shared-buffer hits, no shared reads in the displayed plan, and 0.104 ms execution. Planning separately reported 3 shared hits and 0.238 ms. This is one local empty-data sample, not endpoint latency or a production benchmark. |

## Recommendation and cost

The plan is reasonable for the observed database; **no immediate index change is justified**. Existing primary-key indexes already support vehicle/zone identity lookups when the planner finds them useful.

If transaction history grows while the active subset stays small, evaluate a **partial B-tree index on transaction `entry_time DESC` with predicate `status='Active'`**. It could reduce the rows visited for monitoring and help supply order, depending on the join strategy and distribution. It has a storage/WAL cost, must be maintained on inserts and entry-time changes, and completing transactions changes index membership. It does not guarantee the final join plan avoids sorting. No index was created for this activity.

First load representative authorized test data, refresh statistics, and compare the same query's plans, estimates, buffers and repeated timings under realistic active/completed proportions. Evaluate polling frequency and concurrent clients, since the supplied README describes automatic monitoring refresh every three seconds. If history or result counts justify it, assess result limits/pagination against the live monitor's requirement to display active vehicles. These are follow-up proposals, not measured speedups.
