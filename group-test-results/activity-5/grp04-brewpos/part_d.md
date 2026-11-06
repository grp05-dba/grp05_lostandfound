# Part D – Query Performance Analysis

## Application query and role

The selected query computes **daily revenue and distinct order count**, used by `SalesReportService.dailySales()` and declared as `OrderLineItemRepository.dailyTotals()`. Both were reviewed at commit `f2af982d7cd2709ebcb0e0f0fd00af27bc4286d4`. [Source excerpt and provenance](evidence/08_source_query.txt) retain the JPQL method and caller semantics.

The source uses JPQL entity/property names. The following is a SQL translation to the documented table/column names, **not a capture of literal Hibernate-generated SQL**:

```sql
SELECT sum(l.quantity * l.sold_price), count(DISTINCT t.order_id)
FROM public.order_line_item l
JOIN public.order_ticket t ON t.order_id=l.order_id
WHERE t.order_timestamp >= TIMESTAMP '2026-11-04 00:00:00'
  AND t.order_timestamp <  TIMESTAMP '2026-11-05 00:00:00';
```

The day was selected from the earliest existing order, not invented or seeded for this test. It preserves the caller's half-open local-café timestamp range, from the chosen day's midnight to the next midnight. It calculates revenue from historical `sold_price`, rather than today's menu price, and counts each order once even when it has several lines.

`brewpos_app` is the documented shared Spring Boot service account, with SELECT on both sales tables. The report serves the application's reporting/manager functions; separate UI modes do not create separate PostgreSQL identities. No application startup, HTTP request or GUI role enforcement was tested in this activity.

[04_query_plan.sql](sql/04_query_plan.sql) ran plain EXPLAIN first, then EXPLAIN (ANALYZE, BUFFERS), and the aggregate SELECT itself at **18:11:37 +08, 6 November 2026**. These safe reads ran in a read-only transaction with a 30-second timeout and ended with ROLLBACK. They do not depend on successful maintenance; Part C's maintenance attempts were skipped.

## Observed plan and result

[Full evidence](evidence/04_query_plan.txt) records:

```text
Aggregate (estimated rows=1; actual rows=1.00)
  Buffers: shared hit=5
  -> Sort (estimated rows=2; actual rows=4.00)
       Sort Key: t.order_id
       Sort Method: quicksort  Memory: 25kB
       -> Hash Join (estimated rows=2; actual rows=4.00)
            Hash Cond: (l.order_id = t.order_id)
            -> Seq Scan on order_line_item l (estimated rows=9; actual rows=9.00)
            -> Hash (actual rows=2.00; Memory Usage: 9kB; Batches: 1)
                 -> Seq Scan on order_ticket t (estimated rows=1; actual rows=2.00)
                      Filter: timestamp >= day start AND timestamp < next day
                      Rows Removed by Filter: 3
Planning Time: 0.177 ms
Execution Time: 0.123 ms
```

The actual aggregate returned **440.00 revenue and 2 orders** for 4 November. Four matching line rows contributed to those two orders; the `count(DISTINCT ...)` avoids counting all four as separate transactions.

## Interpretation and recommendation

PostgreSQL scans the five order tickets, keeps two matching the day, hashes their IDs and joins the nine line rows to produce four matching lines. It sorts those rows by order ID for the distinct-count aggregate. The top aggregate returns one summary row. The estimate correctly predicts one output summary, while the ticket filter and join underestimate matching rows by a factor of two (1 versus 2 tickets, 2 versus 4 lines). These are small absolute differences on seed data, not proof of a harmful plan.

The sort stays in memory (25 kB), the hash uses one batch (9 kB), and the displayed execution has five shared-buffer hits with no shared reads/temp spill reported. Planning separately shows 14 shared hits. These counts are inclusive per plan node; do not sum every displayed hit count as independent I/O. The 0.123 ms execution is one warm local sample, not endpoint latency or a production capacity measurement.

**No immediate index change is justified.** The database already has `idx_order_ticket_timestamp(order_timestamp)` for the half-open date filter, and the line-item composite primary key `(order_id,item_id)` supports matching lines by order. At five tickets/nine lines, sequential scans can cost less than index traversal. The SQL keeps timestamp comparisons directly on the column, preserving the existing index's potential usefulness; replacing the predicate with a date cast on the column could undermine that access pattern.

Adding duplicate timestamp/order-key indexes would consume storage, increase insert/WAL/maintenance costs and has no established benefit here. First establish the authorized maintenance role, refresh relevant statistics, then repeat plans with realistic history and varied day selectivity. Compare estimates, buffers, sort behavior and repeated timings before considering a justified change. No index was created or forced, and no maintenance speedup is claimed.
