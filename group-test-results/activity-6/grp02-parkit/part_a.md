# Part A – Backup Planning

**Project:** Group 02 – Park It  
**Date:** 6 November 2026  
**Repository:** https://github.com/millerdevera6-glitch/park-it-database/tree/main/park-it  
**Revision reviewed:** `main`, commit `0c01b3e87cf3d623f5f8c4936e3fe7fe56daeeb3`

## Backup plan

| Requirement | Plan |
|---|---|
| Database | `grp_parkitdb`, PostgreSQL 18.6, localhost port `55442` |
| Objects | `public` schema; `parking_zone`, `vehicle`, `staff_user`, `transaction`, `payment`; their data, sequences, indexes, constraints, ownership and privileges |
| Method | Full logical backup using `pg_dump -Fc`, restored using `pg_restore` |
| Reason | Custom archives support inspection and full restoration of this small PostgreSQL database |
| Account | Activity 4 `parkit_dba`, which inherits project ownership through `parkit_owner_grp`; not the application runtime account |
| Storage | `/tmp/activity6-grp02-private/backups/`, outside Git; directory permissions `0700`, completed files `0400` |
| File access | Authorized OS backup operator only; runtime/auditor accounts are not given backup copies. Database grants do not grant filesystem access |
| Verification | Inspect archive; restore separately; check objects, records, constraints, roles, allowed/denied operations and application connection |
| Proposed schedule | Nightly at 02:00 Asia/Manila and before major database changes |
| Proposed retention | Seven daily, four weekly and three monthly recovery points, with an encrypted independent copy |
| Proposed RPO | 24 hours for a classroom/demo deployment |
| Proposed RTO | 60 minutes, including preparation, restoration, verification and application reconnection |

These schedule/retention policies are proposals, not installed jobs. The actual `/tmp` location is temporary and must be replaced with durable backup storage for real deployment.

## Roles after restoration

Single-database dumps do not create cluster-wide roles or memberships. This same-cluster test retained and verified the Activity 4 roles:

| Login | Group | Responsibility |
|---|---|---|
| `parkit_dba` | `parkit_owner_grp` | Backup, restore and project administration |
| `parkit_app` | `parkit_runtime_grp` | Normal application operations |
| `parkit_auditor` | `parkit_readonly_grp` | Approved read-only inspection |

On a fresh cluster, recreate these roles and memberships before restoration and assign passwords privately. Restore object grants from the archive, then explicitly configure CONNECT/PUBLIC permissions and database-specific settings for the new database name. See [Part C](part_c.md).

## Safe test arrangement

Preserve the original database and original archive. Restore into `parkit_a6_restore`. Create the disposable recovery vehicle there, back up that test database separately, and verify that backup in `parkit_a6_snapshot_check` before deleting the vehicle. Recover into fresh `parkit_a6_recovered`.

No destructive operations run on `grp_parkitdb`, and no data-containing backup is committed.
