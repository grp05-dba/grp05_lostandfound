# Part C - Restore to Separate Test Databases

## Fresh targets and explicit authority phases

The provisioning administrator created new databases from template0, owned by `grp03_ojt_admin_grp`, on port 55403. PUBLIC access was revoked; only the planned maintenance, runtime, reporting roles received target CONNECT. Source `ojt_managementdb` was excluded by explicit target-name checks. No source per-database runtime overrides needed to be copied for this plan; the source default environment/configuration was kept.

The restore preserved owners and grants. It did **not** use `--no-owner`, `--no-acl`, `--clean`, `--disable-triggers` or `--create` to suppress problems or accidentally restore to the source database name.

| Restore phase | Account / active role | TOC entries | Exit |
|---|---|---:|---:|
| objects | `grp03_ojt_dba` / `grp03_ojt_admin_grp` | 158 | 0 |

Actual initial-restore commands:

```powershell
& "C:\Program Files\PostgreSQL\18\bin\pg_restore.exe" -w --exit-on-error --single-transaction -h 127.0.0.1 -p 55403 -U grp03_ojt_dba --role=grp03_ojt_admin_grp "--use-list=D:\Data Administration\course-review\activity6-private\g03\restore_objects.list" -d g05_a6_g03_restore "D:\Data Administration\course-review\activity6-private\g03\original.dump"
```

Metadata-only use-list files are included beside the evidence. All TOC entries are assigned exactly once; data/schema/object work is restored by the DBA/owner. No separate login-owned default-ACL pass was needed. No bootstrap-owned extension ACL pass was needed.

Each phase uses `--exit-on-error --single-transaction`; **the multi-phase restore as a whole is not one atomic transaction**. Any failed/incomplete target must be treated as invalid until repaired or discarded. Application connection tests were delayed until every phase and comparison passed. Database creation/target policy output and exact phase commands are in [restore evidence](evidence/restore_restore.json).

## Data, schema and privilege comparison

| Table | Original rows | Initial restored rows |
|---|---:|---:|
| `academic_supervisors` | 1 | 1 |
| `attendance` | 0 | 0 |
| `audit_log` | 0 | 0 |
| `companies` | 1 | 1 |
| `company_supervisors` | 1 | 1 |
| `evaluations` | 0 | 0 |
| `ojt_applications` | 0 | 0 |
| `ojt_placements` | 0 | 0 |
| `requirements` | 3 | 3 |
| `student_requirements` | 0 | 0 |
| `students` | 1 | 1 |
| `users` | 5 | 5 |

[Initial comparison](evidence/initial_restore_comparison.json) verified matching counts and in-memory whole-row fingerprints for every table, including authentication data without publishing row values/hashes. The checks also compared columns/defaults/nullability, relations/owners, constraints, indexes, views, routine definitions/security, triggers, extension versions, sequence values/settings, role attributes/memberships, effective table/column/sequence/function privileges and creator defaults.

Some PostgreSQL dump/reparse expressions render varchar-array casts differently. Comparison normalizes only the specific equivalent text-array cast pattern while retaining operators/columns/allowed values. It does not ignore missing constraints or permission changes. [Invalid enum probes](evidence/enum_constraint_verification.json) record CHECK rejection on populated applicable tables; empty enum tables were not presented as behavior-tested. Source/restored schema comparison and recovered-row equality remained mandatory.

## Real account and application checks

On the initial restore, independently verified snapshot and recovered database, the runtime/reporting account could execute the approved representative count query; reporting UPDATE was denied with **42501**. The exact accounts, SQL and outputs are in [initial access](evidence/initial_restore_access.json), [snapshot access](evidence/snapshot_verified_access.json) and [recovered access](evidence/recovered_access.json). No ordinary account was switched to a superuser to make the test pass.

[Application connection evidence](evidence/application_connection.json):

| Target | Actual check | Result |
|---|---|---|
| `restore` | Unchanged Java JDBC app, five demo logins and initial role-tab reads; headless | Exit 0 |
| `recovered` | Unchanged Java JDBC app, five demo logins and initial role-tab reads; headless | Exit 0 |

The unchanged Java application authenticated all five demo roles and constructed their initial tabs headlessly; full interactive workflows were not tested.

**Result: successful restoration with documented qualifications.** These are same-cluster restores with existing roles, not an independently tested fresh-cluster migration, production cutover or cross-version restore. [Snapshot verification](evidence/snapshot_verified_comparison.json) and [recovered verification](evidence/recovered_comparison.json) use the same full comparison policy.
