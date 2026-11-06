# Part D – Query Performance Analysis

## Selected application query

The `options` endpoint in [api.php](https://github.com/jeanaroyo/HabalGo/blob/c523913b6ffa57dae754a7fb6e4d6ffed4ac7070/api.php) builds its driver dropdown from this exact SELECT:

```sql
SELECT driver_id,name FROM driver ORDER BY name;
```

The application sets its search path to `habalgo`. [04_query_plan.sql](sql/04_query_plan.sql) uses that schema in a read-only transaction and runs as the dedicated **`habalgo_app_user` / `app_runtime_grp`** service account. There is no separate authenticated driver/customer application role in this endpoint; PostgreSQL's service role is distinct from the records being listed.

The selected query is meaningful for the existing documented ten-driver seed. No artificial bookings or workflow records were inserted for analysis. EXPLAIN prints the plan without driver names/contact details; EXPLAIN ANALYZE executes the safe read but does not print its result values. [Source provenance](evidence/08_source_query.txt) records the source commit, file blob and exact caller line.

At **18:28:51 +08, 6 November 2026**, plain EXPLAIN ran first, followed by EXPLAIN (ANALYZE, BUFFERS), with a 30-second timeout. The read-only transaction ended with ROLLBACK. The PHP endpoint itself was not started or called, and maintenance had been skipped rather than successfully completed.

## Captured plan

[Full evidence](evidence/04_query_plan.txt) contains:

```text
Sort (cost=19.09..19.57 rows=190 width=222)
  (actual time=0.093..0.095 rows=10.00 loops=1)
  Sort Key: name
  Sort Method: quicksort  Memory: 25kB
  Buffers: shared hit=4
  -> Seq Scan on driver (cost=0.00..11.90 rows=190 width=222)
       (actual time=0.016..0.017 rows=10.00 loops=1)
       Buffers: shared hit=1
Planning Time: 0.041 ms
Execution Time: 0.105 ms
```

## Interpretation and recommendation

The sequential scan reads all ten driver records; the in-memory quicksort orders them by name. The sort uses 25 kB with no displayed temp spill. The top execution node reports four shared hits, including its child's work; the child reports one shared hit. Do not add inclusive node counts as separate physical I/O. No shared read is shown in the displayed execution plan.

The planner estimated **190 rows versus ten actual rows**, a 19-fold overestimate. The fresh table has no recorded ANALYZE and `reltuples=-1`, so missing initial statistics are a plausible explanation. This is not a measured regression or proof that a different plan would be faster. **First refresh statistics through an approved maintenance identity**, then repeat the same query and compare row estimates, buffers and repeated timings. Part C records why that action could not be completed under the supplied roles.

The observed sequential scan and sort are proportionate for ten rows. **No immediate index change is justified.** Primary-key/license indexes do not supply name order. A name-order index could be evaluated if the driver directory becomes large and this dropdown query is frequent, but it costs storage and insert/name-update/WAL/maintenance work and may not outperform scanning when returning the full directory. No such index was created or forced.

At larger scale, also assess server-side autocomplete or result limits against the dropdown's requirements rather than returning every driver indefinitely. That is a source-based follow-up proposal, not a demonstrated current bottleneck. The 0.105 ms measurement is one local warm seed-data sample, not endpoint latency, concurrent-load capacity or a before/after maintenance speedup.
