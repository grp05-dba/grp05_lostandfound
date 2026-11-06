# HabalGo – Owner Feedback Draft

**Prepared by Group 5, 6 November 2026. Status: draft only; not sent.**

Your source `database/03_roles_and_privileges.sql` was present. Its roles and documented database had not been installed in our local port-5432 environment, causing the initial missing-role errors. We installed the supplied root schema and runtime/read-only plan in a new `grp00_habalgodb`, removed all PASSWORD clauses from the local setup adaptation, and loaded the documented root ten-driver seed. Subsequent dedicated account connections succeeded. The reviewed source commit is `c523913b6ffa57dae754a7fb6e4d6ffed4ac7070`.

Please add an approved project maintenance identity to the access-control plan. Neither `habalgo_app_user` nor `habalgo_readonly_user` has MAINTAIN, and the tables belong to `postgres`. Our ANALYZE and ordinary VACUUM attempts on `driver` were explicitly skipped; we did not retry as superuser. Once a scoped role is approved, establish planner statistics and verify completed maintenance with fresh timestamps/counters and preserved counts.

The actual driver-dropdown query scanned and sorted ten rows in 0.105 ms, but estimated 190 rows because the fresh table has no recorded analysis. Statistics refresh is the first follow-up. Ten rows do not justify a name index; evaluate indexing/autocomplete only with representative directory size and request volume, considering write/storage cost.

Please remove password literals from upstream provisioning and use private local credential configuration. Rotate any literal values that were actually deployed. The original credential-bearing script was not executed or committed in our results. Review the generic cluster-wide group names and retained PUBLIC database connection defaults before reusing this setup across projects.

The readable service journal contains the two resolved initial missing-role failures, two current expected log-function denials and two maintenance-skip warnings. These were our setup/access probes, not invented application incidents. Server-file SQL privileges remain restricted; duration-based slow-query logging is disabled, limiting performance-incident visibility.

Document how deployment supplies the runtime database/account: README names `grp00_habalgodb`, while config defaults to `habalgo` and `postgres`, and the API fixes its search path to `habalgo`. We did not launch PHP or test end-user authentication. The inspected seed has ten drivers and no bookings/payments, so it does not establish full workflow or load readiness.

Supporting evidence and limitations are linked in [Part E](part_e.md) and the [repository package index](README.md). No other project's data or privileges were changed, no log files were edited, and no tracker or PDF work was performed.
