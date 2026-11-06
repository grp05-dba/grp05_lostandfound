# Part D – Query Performance Analysis

## Selected application query

The STUDENT **My requirements** tab uses `MY_REQS` in [system/Roles.java](https://github.com/swvenz/Project-OJT-RMA-System/blob/6a899fbc5882c2916be0af3a91457b1c0c54084b/system/Roles.java). The [source excerpt](evidence/08_source_query.txt) records its query constant, caller and Git provenance. It lists every requirement and any submission for the logged-in student's profile:

```sql
SELECT r.req_id, r.title, r.is_mandatory,
       coalesce(sr.status,'Not submitted') status, sr.remarks
FROM requirements r
LEFT JOIN student_requirements sr
  ON sr.req_id=r.req_id AND sr.student_id=:student_id
ORDER BY r.req_id;
```

Java binds its `?` parameter to the logged-in profile ID. The [executed SQL script](sql/04_query_plan.sql) substituted existing, non-deleted student profile **1**, selected from the database rather than assuming an invented record. Only the numeric ID and plans were captured; no student name, contact information, credential or result remarks were printed.

The direct `grp03_ojt_app` login represents the shared JDBC runtime role. The selected query serves STUDENT, while all five application roles use that same database account. PostgreSQL grants do not enforce individual student identity here; Java supplies the correct parameter. This activity did not run Java startup, its seed routine or GUI actions.

At **17:59:35 +08 on 6 November 2026**, plain EXPLAIN ran first. `EXPLAIN (ANALYZE, BUFFERS)` then executed the safe SELECT in `BEGIN READ ONLY`, with a 30-second timeout and the public search path, after maintenance. The transaction ended with ROLLBACK.

## Actual execution plan

[Full output](evidence/04_query_plan.txt) includes both plans. The measured operations were:

```text
Sort (cost=1.07..1.08 rows=3 width=83)
  (actual time=0.071..0.074 rows=3.00 loops=1)
  Sort Key: r.req_id
  Sort Method: quicksort  Memory: 25kB
  Buffers: shared hit=1
  -> Hash Left Join (estimated rows=3; actual rows=3.00 loops=1)
       Hash Cond: (r.req_id = sr.req_id)
       -> Seq Scan on requirements r (estimated rows=3; actual rows=3.00)
       -> Hash (actual rows=0.00; Memory Usage: 8kB; Batches: 1)
            -> Seq Scan on student_requirements sr
                 Filter: (student_id = 1)
                 (estimated rows=1; actual rows=0.00 loops=1)
Planning Time: 0.158 ms
Execution Time: 0.110 ms
```

## Interpretation and justified action

The requirements scan reads the three seeded definitions. The submission scan filters by student; it found no rows. The left join correctly preserves all three requirements, with COALESCE providing the not-submitted label. Its output estimate of three rows matches the actual three-row result. The empty submission scan's estimate of one row versus actual zero is not evidence of a serious estimation fault in this small relation.

The hash join uses a single batch with 8 kB of memory. The final in-memory quicksort uses 25 kB to order the three results by ID. The displayed execution has one shared-buffer hit and no reported shared reads or temp spill. Sequential scans are sensible for three definitions and zero submissions; forcing index scans would not establish an improvement.

**No immediate index change is required.** The existing unique B-tree `student_requirements_student_id_req_id_key` on **(student_id, req_id)** already matches the filter/join access pattern. Creating another index on the same keys would duplicate storage and add insert/update/WAL and maintenance cost without an established benefit. The requirements primary-key index also supports ID lookups/order when useful to the planner.

Retain the student condition inside the LEFT JOIN's ON clause: moving it into WHERE would discard unmatched requirements and change the screen's behavior. Preserve the parameterized application query. With representative submission volume, refresh statistics and repeat plans for students with many, few and no submissions to check whether the existing composite index is selected and whether estimates, buffer usage or sorting warrant further work.

This single warm local sample is not a production benchmark or measured GUI latency. There are no submissions, placements or attendance records, and no concurrent application workload was generated. No speedup from maintenance or a proposed change is claimed because no controlled before/after benchmark was performed.
