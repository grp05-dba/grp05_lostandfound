# Part E – Findings and Maintenance Report

**Project:** Group 4, BrewPOS café point-of-sale system. **Testing group:** Group 5. **Date:** 6 November 2026, Asia/Manila. **Environment:** existing local `grp_brewposdb`, PostgreSQL 18.6, public schema, Unix socket on port 5432.

**Overall result: reachable, with access-control gaps; maintenance blocked by existing privileges.** Health, available-log review and safe query analysis were completed. ANALYZE and VACUUM were skipped by PostgreSQL because the sole project account lacks maintenance permission. The report package is complete for the observed state; successful maintenance and a completed Activity 4 setup are not claimed.

## Accounts, work and evidence

Only `brewpos_app` exists among the documented BrewPOS logins/groups. Our Activity 4 BrewPOS folder contains no completed role plan or verification. All SQL therefore used the real runtime account within its grants, and each capture records its direct session/current identity. Existing OS user `me` separately read accessible service messages. No superuser, SET ROLE, new roles, new grants or ownership changes were used.

| Work | Results and evidence |
|---|---|
| Health and access comparison | [Part A](part_a.md), [health output](evidence/01_health.txt): 8070 kB initially; five tables, four sequences, nine indexes; 30 exact live rows; one inspection session, no blockers; intended auditor/admin/groups absent. |
| Logs and issues | [Part B](part_b.md), [SQL access](evidence/02_logging_access.txt), [service extract](evidence/07_service_log_review.txt): one historical administrative termination, two deliberate log-function errors and two maintenance-skip warnings. Slow-query logging is disabled; SQL server-log functions are restricted. |
| Maintenance demonstration | [Part C](part_c.md), [command output](evidence/03_maintenance.txt): ANALYZE and ordinary VACUUM attempted on `menu_item`, both explicitly skipped. A zero process exit and command tags were not mistaken for maintenance success. |
| Verification | [Fresh capture](evidence/05_verify.txt): all five exact row counts, vacuum counts and existing ANALYZE timestamps/counters unchanged. No dead-tuple backlog is demonstrated; live-count estimates differ from exact counts. |
| Query performance | [Part D](part_d.md), [plan evidence](evidence/04_query_plan.txt): source-derived daily-sales SELECT, sequential scans/hash join/sort/aggregate, 0.123 ms execution; 440.00 over two existing orders. Existing indexes are adequate for this small sample. |

## Prioritized recommendations

| Priority | Action | Responsibility / completion criterion |
|---|---|---|
| **Immediate prerequisite action** | Reconcile and implement an approved Activity 4 access-control plan. `docs/user-roles.md` describes groups/auditor/admin that are absent, and its claim that the runtime script automates them is inaccurate. | Authorized access-control owner: document real responsibilities and provide separate approved inspection/maintenance identities. Do not grant broad maintenance or superuser access to the normal runtime merely to complete this exercise. |
| **Follow-up action** | Complete maintenance under the approved maintenance identity; use table-level MAINTAIN or deliberately scoped ownership rather than an unrelated superuser fallback. | Authorized project maintainer: run suitable ANALYZE/ordinary VACUUM, capture verbose results with no skips and verify fresh timestamps/counters and preserved row counts. This remains outstanding. |
| **Follow-up action** | Investigate statistics-view live-count estimates differing from exact counts; catalog `reltuples` currently matches the exact data. | Project maintainer: refresh relevant statistics when authorized, monitor subsequent estimates and explain any persistent discrepancy. No duplicate-data diagnosis or reset of shared statistics is justified by this observation alone. |
| **Follow-up action** | Review PUBLIC database access. The project retains PUBLIC CONNECT/TEMPORARY and the runtime can CONNECT to unrelated `postgres`. | Cluster administrator: inventory legitimate clients, preserve required explicit grants and review inappropriate defaults/isolation controls. No shared ACL was changed here. |
| **Follow-up action** | Confirm whether the historical administrator-terminated connection was planned; establish scoped log export/access and slow-query observability if needed. | Environment owner: document context, retain runtime log restrictions and avoid exposing sensitive SQL in exports. |
| **Follow-up action** | Recheck daily-sales plans with realistic volume and fresh authorized statistics. | Application/database owner: preserve the half-open timestamp predicate and historical sold-price computation; compare selectivity, buffers and timings before proposing an index. |
| **No action required now** | Duplicate indexes, VACUUM FULL, index rebuilds or aggressive repeated manual maintenance. | The database is small, estimated dead tuples are zero and the measured plan is reasonable. Retain autovacuum and monitor real workload. |
| **No action required** | Widening runtime log privileges to suppress deliberate log-access errors. | Existing denials are expected. They do not establish a normal application fault. |

## Limitations and AI validation

The missing local Activity 4 plan and absent project maintenance account limit completion. Source role mappings are intended design rather than proof of installed roles. Historical Activity 3 testing used an isolated port-55432 cluster; Activity 5 inspected the existing local port-5432 database and did not assert identical environment history. No application startup, authentication/role-boundary test, load test or remote/password-authentication test was performed.

Health/session evidence is a snapshot. Cumulative counters and approximate tuple estimates are not an incident audit. The service journal covers one readable window and PID-correlated sessions; pre-authorization failures, older sessions/history and other sinks may be missing. No failed-password or slow-query incident was invented. Log files were not edited and logging settings were retained; the runtime's maintenance attempts left table maintenance undone.

AI assistance (OpenAI Codex) reviewed the Activity 5 instructions, prior local material and current repository; prepared/executed SQL; filtered existing service logs; interpreted results; and drafted this package. Validation used direct account identities, catalog grants/role presence, real warning/error messages, before/after exact counts and counters, actual query plans, and the source JPQL/caller. [Source provenance](evidence/08_source_query.txt) records commit `f2af982d7cd2709ebcb0e0f0fd00af27bc4286d4`. The report query is a disclosed SQL translation of JPQL, not claimed to be captured Hibernate SQL. No synthetic records, fabricated success, passwords or hashes are included.

## Repository handoff

The [README](README.md) indexes Parts A–E, scripts, evidence, reproduction commands and the repository portion of Part F. [Owner feedback](owner-feedback.md) is an unsent draft. No tracker or tracking-log updates or PDF documentation were prepared, as instructed. No feedback was sent and no push is claimed. Access-control prerequisites and successful maintenance remain outstanding rather than silently bypassed.
