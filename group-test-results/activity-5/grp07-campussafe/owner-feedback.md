# CampusSafe – Owner Feedback Draft

**Prepared by Group 5, 6 November 2026. Status: draft only; not sent.**

We reviewed source `main` at `3684b97cfa8b8c6624d039eda461551ade774701` and installed its missing local prerequisites in a new `grp07_campussafedb`. We removed schema/seed resets from local fresh-install copies, removed password clauses, and prefixed the generic groups `campussafe_` because HabalGo already uses the original names on this cluster. No existing HabalGo roles or privileges were changed.

Your `docs/user-roles.md` names non-superuser `campussafe_owner` for database maintenance, but the SQL installer does not create that account. We implemented the documented identity with actual project database/table/sequence ownership and aligned owner migration defaults. Please make this distinction explicit upstream: granting ALL on tables does not by itself transfer ownership or implement the documented owner.

Routine ANALYZE and ordinary VACUUM succeeded through that owner on all nine tables. No dead tuples needed removal; all 129 seed rows remained intact, and fresh verification found current timestamps plus vacuum count 1/analyze count 2 on each table. The runtime/reporting/backup accounts retain no maintenance permission.

The real dashboard category summary returned six groups in 0.185 ms. It used sequential scans, a hash right join equivalent to the SQL left join, a hash aggregate and in-memory sort. Estimates matched the seeded data. The existing category index does not need duplication, and no current rewrite/cache was justified. Reassess at representative volume while preserving zero-report categories and COUNT(report_id) semantics.

Please review unrelated-database connection defaults with the authorized cluster owner: all four CampusSafe accounts still have effective CONNECT to `postgres`, despite the project database's PUBLIC lockdown. This differs from the source guide's denial expectation; connection scope does not establish table access. Preserve legitimate clients before changing shared access.

Review future-table defaults in migrations: existing audit/action tables are appropriately protected, while automatic future runtime grants include UPDATE. New objects should receive privileges appropriate to their purpose. Keep credentials private, project group names distinct and owner-created object/default behavior consistent.

The readable service journal showed the resolved initial missing-role failure and two expected reporting-account log-function denials. Duration-based slow-query logging is disabled, limiting absence-of-incident conclusions. The reporting account's user-table restrictions were respected; credential hashes, personal seed values and incident descriptions were not copied into evidence.

No PHP UI, backup/restore, remote authentication or load test was performed. No tracker/PDF work, log-file edits or external feedback was performed. Supporting findings and evidence are linked in [Part E](part_e.md) and the [package index](README.md).
