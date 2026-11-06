# Part E - Findings and Maintenance Report

**Project:** Group 08, Campus Canteen Pre-Order and Queue Management System. **Testing group:** Group 5. **Date:** 6 November 2026, Asia/Manila. **Result:** database reachable; selected routine maintenance completed and verified; query analysis completed with logging/visibility and small-dataset qualifications.

## Evidence and actual outcomes

| Area / existing account | Outcome | Evidence |
|---|---|---|
| Health and role review: `canteen_admin` with owner role | PostgreSQL 18.3, `canteen_g05_activity4`, initial 8542 kB; 7 tables/7 sequences/0 views/11 indexes; 26 exact rows; Activity 4 role/ACL policy intact | [Part A](part_a.md), [initial health](evidence/01_health_before.txt), [roles](evidence/02_roles_before.txt) |
| Activity: direct `canteen_admin` | One visible inspection session; no reported blocker; visibility-limited owner snapshot handled separately | [activity evidence](evidence/activity_visibility.txt) |
| Logs: reporting SQL probes plus scoped OS reader | 66 ERROR/9 FATAL/0 WARNING/0 PANIC retained; expected test categories, no unexplained production incident established; duration logging unavailable | [Part B](part_b.md), [filtered log review](evidence/log_review.txt) |
| Maintenance: `canteen_admin` → `canteen_owner_grp` | ANALYZE on customer_order; ordinary VACUUM/ANALYZE on customer_order; no permission/skip warning; fresh counters/timestamps confirm completion | [Part C](part_c.md), [commands](sql/03_maintenance.sql), [actual output](evidence/04_maintenance.txt) |
| Query: `canteen_app` | Source SELECT measured before/after; final root Aggregate; target estimate/actual 2/2.0; sampled execution 0.446 ms | [Part D](part_d.md), [plan/provenance](evidence/query_provenance.json) |
| Post-checks | All exact counts and sequence values unchanged; six roles, memberships, object/schema/database/default ACLs unchanged | [after health](evidence/05_health_after.txt), [after roles](evidence/06_roles_after.txt), [summary](evidence/summary.json) |

No new superuser/monitor/maintenance grant was introduced. This used the deliberately assigned object-maintenance owner role from Activity 4, not a superuser fallback after a denied runtime operation. No FULL vacuum, index creation/rebuild, application data mutation, sequence consumption/reset, log editing or logging-policy change was performed.

## Prioritized recommendations

| Priority | Action / completion criterion |
|---|---|
| **Completed** | Selected ANALYZE/VACUUM succeeded without skips; exact counts/sequences and ACL policy preserved. Keep the distinction between this selected-table maintenance and a claim that all tables were vacuumed. |
| **Follow-up action** | Monitor actual workload growth, dead-tuple estimates and autoanalyze/autovacuum history; decide proportionate maintenance for other tables from evidence, not a blanket rewrite. |
| **Follow-up action** | If investigating real slow requests, approve scoped duration/connection observability first. Disabled duration logging and stopped apps prevent a production-performance conclusion. |
| **Follow-up action** | Correlate the nonzero abandoned-session counter with controlled app shutdowns and future workloads; current cause is unconfirmed. |
| **Follow-up action** | At larger order volumes, benchmark report date/vendor access patterns before proposing an index. |
| **No immediate action required** | No current blocker, deadlock counter or wraparound emergency was demonstrated. Expected permission denials do not justify widening runtime/reporting privileges. |
| **No action required now** | FULL vacuum, forced index use, index rebuild or a new index merely for this exercise. Small seed-data plans are reasonable; one timing comparison is not proof of speedup. |

## Limits, AI usage and handoff

This is a reused local Activity 4 evaluation database, not an owning group's live deployment. The application remained stopped and was not rerun for Activity 5. Statistics are estimates; activity is point-in-time; some owner-switched visibility was limited; historical logs cover only the dedicated accessible file/window. Logs are not a complete failed-login/connection audit. Performance measurements cover small seed datasets with no concurrency or production-latency guarantee. Existing source-security trust boundaries remain documented in Activity 4; this task did not redesign them.

**AI usage:** OpenAI Codex read the Activity 5 PDF and reference reports, reused the verified Activity 4 setup, prepared scoped SQL, executed authenticated monitoring/maintenance/EXPLAIN checks, filtered available log diagnostics and wrote Parts A-E. Validation checked actual role identities, catalog permissions/ACL equality, verbose maintenance warnings, fresh maintenance timestamps/counters, exact counts/sequence equality, source commit/blob/query provenance, and text/JSON plans. Raw credentials, password hashes, session tokens and application record values were excluded. No human validation is claimed.

**Feedback sent:** No; findings are prepared in these reports and no message or issue was sent to the owners. **Tracker/PDF/publication:** not performed in this scoped task. The five reports, SQL and evidence are local inputs for the group's later Activity 5 progress document and tracker update. Full course-wide submission is not claimed. G09 remains unavailable because its tracker row has no repository link; its blocker is [recorded separately](../grp09-pending/README.md).
