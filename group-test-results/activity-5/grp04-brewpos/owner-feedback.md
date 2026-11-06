# BrewPOS – Owner Feedback Draft

**Prepared by Group 5, 6 November 2026. Status: draft only; not sent.**

We inspected the existing local port-5432 `grp_brewposdb` using `brewpos_app`, with your repository `main` reviewed at commit `f2af982d7cd2709ebcb0e0f0fd00af27bc4286d4`. This was not a restart of the isolated cluster described in our Activity 3 report.

Please reconcile the intended database role mapping with executable setup. The documented auditor/admin logins and runtime/readonly/admin groups are absent locally; only `brewpos_app` exists with direct grants and NOINHERIT. Our local Activity 4 BrewPOS folder has no completed plan. `docs/user-roles.md` says `05_create_app_role.sql` automates the groups/accounts, but that script provisions only the runtime. Define separate approved inspection and project maintenance identities rather than relying on a superuser or widening the runtime.

The runtime's normal table restrictions match your script: staff read-only, menu category/item CRUD and sales SELECT/INSERT only. It lacks table MAINTAIN. Both ANALYZE and ordinary VACUUM on `menu_item` were explicitly skipped with permission warnings; command tags and zero psql exit status did not mean success. Maintenance remains outstanding. Once the authorized role exists, perform suitable routine maintenance and verify timestamps/counters and unchanged data.

Exact current counts are three categories, eleven items, five tickets, nine lines and two staff records. Statistics-view live estimates are twice these counts while `pg_class.reltuples` matches the actual data. Please reassess that discrepancy with authorized statistics maintenance; this observation alone does not prove duplicated records. No dead-tuple backlog or large-storage emergency was demonstrated.

The actual daily-sales JPQL was translated to equivalent SQL for analysis. For 4 November's existing orders, it reported 440.00 from two orders and executed in 0.123 ms in a small warm local sample. The sequential scans/hash join/sort are reasonable here. The timestamp index and line-item primary key already support its access pattern; avoid duplicate indexes and retest at representative scale before changing them. Retain the half-open timestamp range and historical sold-price computation.

Review database connection scope with the authorized cluster owner: project PUBLIC CONNECT/TEMPORARY remains, and the runtime has effective CONNECT to unrelated `postgres`. No unrelated table access was inferred or attempted. Preserve legitimate explicit access before changing shared defaults.

The readable service journal showed one historical administrator-terminated connection, two current denied log-function probes and two current maintenance-skip warnings. Confirm whether the historical disconnect was planned. Keep runtime server-log restrictions; arrange scoped observability if needed. Duration-based slow-query logging is disabled, so absence of slow-query messages does not establish production performance.

No application data, grants, schema or owning-repository files were changed. Log settings and access rights were retained. Supporting evidence and limitations are linked in [Part E](part_e.md) and the [package index](README.md).
