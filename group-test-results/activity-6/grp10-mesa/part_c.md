# Part C - Restore to Separate Test Databases

## Fresh targets and explicit authority phases

The provisioning administrator created new databases from template0, owned by `rors_owner_grp`, on port 55410. PUBLIC access was revoked; only the planned maintenance, runtime, reporting roles received target CONNECT. Source `mesa_g05_activity4` was excluded by explicit target-name checks. No source per-database runtime overrides needed to be copied for this plan; the source default environment/configuration was kept.

The restore preserved owners and grants. It did **not** use `--no-owner`, `--no-acl`, `--clean`, `--disable-triggers` or `--create` to suppress problems or accidentally restore to the source database name.

| Restore phase | Account / active role | TOC entries | Exit |
|---|---|---:|---:|
| objects | `rors_dba` / `rors_owner_grp` | 108 | 0 |
| login_defaults | `rors_dba` / `login identity` | 1 | 0 |
| extension_acl | `lab_admin` / `login identity` | 249 | 0 |

Actual initial-restore commands:

```powershell
& "C:\Program Files\PostgreSQL\18\bin\pg_restore.exe" -w --exit-on-error --single-transaction -h 127.0.0.1 -p 55410 -U rors_dba --role=rors_owner_grp "--use-list=D:\Data Administration\course-review\activity6-private\g10\restore_objects.list" -d g05_a6_g10_restore "D:\Data Administration\course-review\activity6-private\g10\original.dump"
& "C:\Program Files\PostgreSQL\18\bin\pg_restore.exe" -w --exit-on-error --single-transaction -h 127.0.0.1 -p 55410 -U rors_dba "--use-list=D:\Data Administration\course-review\activity6-private\g10\restore_login_defaults.list" -d g05_a6_g10_restore "D:\Data Administration\course-review\activity6-private\g10\original.dump"
& "C:\Program Files\PostgreSQL\18\bin\pg_restore.exe" -w --exit-on-error --single-transaction -h 127.0.0.1 -p 55410 -U lab_admin "--use-list=D:\Data Administration\course-review\activity6-private\g10\restore_extension_acl.list" -d g05_a6_g10_restore "D:\Data Administration\course-review\activity6-private\g10\original.dump"
```

Metadata-only use-list files are included beside the evidence. All TOC entries are assigned exactly once; data/schema/object work is restored by the DBA/owner. Login-owned default ACLs are applied by that login, since its NOINHERIT owner group cannot alter the login creator defaults. Bootstrap-owned trusted-extension function ACLs are applied by the provisioning administrator only to these new targets; the DBA is not granted superuser or membership in lab_admin.

Each phase uses `--exit-on-error --single-transaction`; **the multi-phase restore as a whole is not one atomic transaction**. Any failed/incomplete target must be treated as invalid until repaired or discarded. Application connection tests were delayed until every phase and comparison passed. Database creation/target policy output and exact phase commands are in [restore evidence](evidence/restore_restore.json).

## Data, schema and privilege comparison

| Table | Original rows | Initial restored rows |
|---|---:|---:|
| `customer` | 51 | 51 |
| `staff` | 10 | 10 |
| `menu_item` | 50 | 50 |
| `restaurant_table` | 20 | 20 |
| `orders` | 60 | 60 |
| `order_item` | 167 | 167 |
| `reservation` | 50 | 50 |
| `payment` | 56 | 56 |

[Initial comparison](evidence/initial_restore_comparison.json) verified matching counts and in-memory whole-row fingerprints for every table, including authentication data without publishing row values/hashes. The checks also compared columns/defaults/nullability, relations/owners, constraints, indexes, views, routine definitions/security, triggers, extension versions, sequence values/settings, role attributes/memberships, effective table/column/sequence/function privileges and creator defaults.

Some PostgreSQL dump/reparse expressions render varchar-array casts differently. Comparison normalizes only the specific equivalent text-array cast pattern while retaining operators/columns/allowed values. It does not ignore missing constraints or permission changes. [Invalid enum probes](evidence/enum_constraint_verification.json) record CHECK rejection on populated applicable tables; empty enum tables were not presented as behavior-tested. Source/restored schema comparison and recovered-row equality remained mandatory.

## Real account and application checks

On the initial restore, independently verified snapshot and recovered database, the runtime/reporting account could execute the approved representative count query; reporting UPDATE was denied with **42501**. The exact accounts, SQL and outputs are in [initial access](evidence/initial_restore_access.json), [snapshot access](evidence/snapshot_verified_access.json) and [recovered access](evidence/recovered_access.json). No ordinary account was switched to a superuser to make the test pass.

[Application connection evidence](evidence/application_connection.json):

| Target | Actual check | Result |
|---|---|---|
| `restore` | Unchanged application database/configuration component via PHP PDO CLI | Exit 0 |
| `recovered` | Unchanged application database/configuration component via PHP PDO CLI | Exit 0 |

The actual application database/configuration component connected and read the target using the restricted runtime account. This is component/driver verification, not a claim that a full interactive web workflow was rerun.

**Result: successful restoration with documented qualifications.** These are same-cluster restores with existing roles, not an independently tested fresh-cluster migration, production cutover or cross-version restore. [Snapshot verification](evidence/snapshot_verified_comparison.json) and [recovered verification](evidence/recovered_comparison.json) use the same full comparison policy.
