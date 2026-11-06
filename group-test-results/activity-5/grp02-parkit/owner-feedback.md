# Park It – Owner Feedback Draft

**Prepared by Group 5, 6 November 2026. Status: draft only; not sent.**

We inspected the existing local `grp_parkitdb` with the Activity 4 auditor, runtime and DBA accounts and reviewed your supplied repository at commit `d369a457ce2dc88a024428513360f0ad76473f43`.

Please prioritize a review of database CONNECT boundaries with the authorized cluster administrator. Our catalog checks still show all three Park It accounts can connect to unrelated `postgres`, while the project database retains `PUBLIC` CONNECT. Historical service records also show grp03 accounts connecting to `grp_parkitdb`. Connection permission does not prove table access, but it exceeds the intended project scope. Preserve legitimate explicit access before restricting defaults, then repeat connection tests. We did not change these shared permissions.

The local database is empty, including the parking-zone and staff-account tables. Confirm the intended seed/provisioning process before assessing application readiness. Configure the deployed PHP connection for the dedicated runtime account rather than the README's `postgres` account, and keep credentials outside committed files. This activity did not start or reconfigure your PHP application.

Routine ANALYZE and ordinary VACUUM succeeded using the existing `park_it_dba` privileges. Vacuum removed two dead vehicle tuples and verification found zero live/dead tuples afterward. Autovacuum is enabled. No index, schema, ownership or privilege changes were made.

The actual live-monitor query used sequential scans, nested-loop joins and a sort, with execution time 0.104 ms on zero rows. This does not measure realistic workload performance. If completed transaction history grows, assess a partial index supporting active entries ordered by entry time; measure it with representative data and account for storage/write costs before adopting it.

Historical logs contain two missing-vehicle-relation errors and three administrator-terminated connections. Current qualified table checks succeeded; confirm whether those events belong to planned setup/cleanup. Activity 4's deliberate permission failures and Activity 5's denied log-function calls were expected. Service logs were readable to the existing OS user, while the database accounts' server-log function restrictions remained intact.

Please also reconcile the canonical repository URL: earlier Activity 4 documentation cited `millerdevera6-glitch/park-it-database`, while Activity 5 was requested against `HelloP0/PARK-IT-DATABASE-MANAGEMENT-SYSTEM`. The observed table design aligns, but shared version history was not established.

Supporting detail and scoped evidence are linked in [Part E](part_e.md) and the [repository package index](README.md).
