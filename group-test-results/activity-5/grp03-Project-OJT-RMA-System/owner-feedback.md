# OJT Management System – Owner Feedback Draft

**Prepared by Group 5, 6 November 2026. Status: draft only; not sent.**

We inspected the existing local Activity 4 `ojt_managementdb` using the dedicated auditor, runtime and DBA accounts, with source `main` at commit `6a899fbc5882c2916be0af3a91457b1c0c54084b`.

Please prioritize the remaining cross-database connection scope with the authorized cluster administrator. All three grp03 logins still have effective CONNECT to unrelated Park It and `postgres`; historical service records confirm the earlier Park It connection tests. Review legitimate access before restricting inappropriate PUBLIC defaults or applying other isolation controls, then repeat connection tests. Connection permission does not demonstrate unrelated table access. No shared ACL was changed in this activity.

Routine ANALYZE and ordinary VACUUM succeeded on all 12 tables through the existing project DBA's inherited ownership. Vacuum removed 18 dead tuples; all 12 exact table counts retained their seed state, totaling 12 live rows. Fresh verification found zero dead tuples and current maintenance timestamps. Autovacuum is enabled; no FULL vacuum or rebuild was warranted.

The student My requirements query returned three rows using a sequential scan, hash left join and in-memory sort, with 0.110 ms execution in this small local sample. The existing unique `(student_id, req_id)` index already fits the submission lookup. Keep it rather than adding a duplicate index; reassess with representative submissions and concurrent workflows before making performance changes. Preserve the student condition in the left join's ON clause so unsubmitted requirements remain visible.

The application audit table remains empty and no user-defined audit trigger exists. Earlier source review also found no automatic audit writes. Please implement and test attributable, transaction-aware change logging rather than treating the existence of `audit_log` as proof of coverage. We did not insert, edit or delete audit rows.

The readable service journal showed the expected Activity 4 negative tests and two current denied server-log function probes, with no additional correlated project ERROR category. SQL log access remains limited, and duration-based slow-query logging is disabled. Arrange scoped observability if needed; do not widen normal runtime/auditor privileges to suppress expected denials.

Keep the earlier setup issues visible: the SQL archive contains a different application's schema, the OJT PDF DDL needed correction and compatibility columns, and Java uses private `db.properties` rather than the README's `.env` description. Provide a consistent migration and setup path, and remove or gate demo seeding before deployment. This activity reused the previously adapted local database and did not launch Java or change your source.

Supporting details and evidence are in [Part E](part_e.md) and the [package index](README.md).
