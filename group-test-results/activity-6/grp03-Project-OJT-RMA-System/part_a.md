# Part A - Backup Planning

**Project:** Group 03 - OJT Management System. **Testing group:** Group 5. **Execution date:** 6 November 2026, Asia/Manila.

| Requirement | Planned and implemented scope |
|---|---|
| Repository / pinned commit | [Source](https://github.com/swvenz/Project-OJT-RMA-System) / `6a899fbc5882c2916be0af3a91457b1c0c54084b` |
| Original database / schema | `ojt_managementdb` / `public` |
| Server/client | PostgreSQL **18.3**, Windows x64, `127.0.0.1:55403` |
| Objects | All source tables/data, sequences/states, indexes, constraints, views, functions, triggers, extensions, ownership, ACLs and defaults in the single database |
| Logical method | Full custom-format `pg_dump -Fc`; inspect and selectively execute `pg_restore` TOC entries |
| Backup account | `grp03_ojt_dba` with explicit `--role=grp03_ojt_admin_grp`, the existing project-owner membership; not the runtime login |
| Storage | `D:\Data Administration\course-review\activity6-private\g03` outside Git; inherited NTFS access restricted to the current OS operator and SYSTEM |
| Archive sensitivity | Includes application data/authentication hashes; archive payloads must never be committed or shared as report attachments |
| Verification | Restore independently; compare row fingerprints/counts, schema definitions, sequence states, ownership, effective privileges, roles/defaults, behavior and application connection |
| Proposed schedule | Nightly 02:00 Asia/Manila, plus before major schema/data changes |
| Proposed retention | Seven daily, four weekly and three monthly points, with a separately protected encrypted independent copy |
| Proposed classroom RPO / RTO | 24 hours / 60 minutes, subject to owner approval; production requirements need a separate agreement |

These schedule, retention, encryption/offsite and RPO/RTO values are **proposals**, not installed jobs or proven production targets. Current storage is durable local disk but remains on the same PC; it does not protect against loss of the whole machine.

## Source continuity and roles

This PC did not contain the other environment referenced by the earlier Activity 4 report. A fresh, separate local copy was reconstructed using the committed Group 5 Activity 4 role/schema/privilege scripts and the same pinned upstream source. It is not represented as the earlier Windows/Linux PostgreSQL 18.6 instance. Provisioning and seed output is in [local prerequisite evidence](evidence/local_prerequisite_setup.txt). OJT uses the already documented PDF-to-SQL correction and four nullable Java-compatibility columns, then the unchanged Java demo seed and five-login headless harness. The unrelated lending archive was not used.

The Activity 4 plan is [available here](../../activity-4/grp03-Project-OJT-RMA-System/part_b.md). Existing roles/memberships were retained and verified in this same-cluster exercise:

| Login / member | Group | Actual membership options |
|---|---|---|
| `grp03_ojt_app` | `grp03_ojt_runtime_grp` | INHERIT True, SET True, ADMIN False |
| `grp03_ojt_auditor` | `grp03_ojt_readonly_grp` | INHERIT True, SET True, ADMIN False |
| `grp03_ojt_dba` | `grp03_ojt_admin_grp` | INHERIT True, SET True, ADMIN False |

Single-database dumps do **not** create cluster-wide roles or membership/password configuration. For a genuinely fresh cluster, first review/run [fresh_cluster_roles.sql](sql/fresh_cluster_roles.sql), assign distinct login passwords privately, and install matching PostgreSQL/extension versions. That template was generated from the actually inspected role catalog; it was not rerun on existing roles.

Database creation is done by the separate Activity 4 provisioning administrator `lab_admin`, because project logins intentionally lack CREATEDB. Restore object work uses `grp03_ojt_dba` with `grp03_ojt_admin_grp`. Any owner-specific login default ACL or bootstrap-owned extension ACL is restored in its correct authority phase; see Part C. No new elevated privileges were granted to project accounts.

## Safe recovery arrangement

The source `ojt_managementdb` is never a restore destination or incident target. Restore the original archive into `g05_a6_g03_restore`. Create a clearly marked disposable `companies` record there, then back up that copy separately. Independently restore/verify the fixture archive in `g05_a6_g03_snapshot` **before** deleting the fixture. Recover to fresh `g05_a6_g03_recovered` and compare it with the recorded snapshot, including the intentionally absent post-backup late record.
