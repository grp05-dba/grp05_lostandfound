# Part C – Restore to a Separate Test Database

## Restoration

The provisioning account created a fresh database because `parkit_dba` intentionally lacks CREATEDB. The DBA then restored the archive:

```sh
createdb -w -h /tmp/activity4-grp02-lab -p 55442 -U postgres -O parkit_owner_grp -T template0 parkit_a6_restore
pg_restore -w --exit-on-error --single-transaction -h 127.0.0.1 -p 55442 -U parkit_dba -d parkit_a6_restore /tmp/activity6-grp02-private/backups/grp_parkitdb_activity6.dump
```

Both operations succeeded. The original database was never a restore destination. `--single-transaction` made this small restore atomic; ownership and ACLs were preserved without `--no-owner`, `--no-acl` or `--clean`.

The provisioner applied these target-specific settings before restoration:

```sql
REVOKE ALL ON DATABASE parkit_a6_restore FROM PUBLIC;
GRANT CONNECT ON DATABASE parkit_a6_restore TO parkit_runtime_grp, parkit_readonly_grp;
ALTER ROLE parkit_app IN DATABASE parkit_a6_restore SET search_path = public;
ALTER ROLE parkit_app IN DATABASE parkit_a6_restore SET statement_timeout = '30s';
ALTER ROLE parkit_app IN DATABASE parkit_a6_restore SET lock_timeout = '10s';
```

The same settings were applied to the other two disposable target databases using their respective names.

## Verification results

Initial counts were checked before adding recovery records:

| Table | Original | Initial restore |
|---|---:|---:|
| `parking_zone` | 1 | 1 |
| `staff_user` | 2 | 2 |
| `vehicle` | 0 | 0 |
| `transaction` | 0 | 0 |
| `payment` | 0 | 0 |

All five tables, five sequences and nine indexes were present. Columns/defaults, sequence states, ownership, effective privileges and records matched. Constraints included five primary keys, four unique constraints, three foreign keys, two CHECK constraints and 22 NOT NULL constraints. No source application views, custom routines or user-defined triggers were missing.

Representative queries:

```sql
SELECT zone_name, max_capacity, current_active_count FROM public.parking_zone;
SELECT user_id, username, role FROM public.staff_user ORDER BY user_id;
```

Actual result excerpts, also confirmed in the recovered database:

```text
Main Parking Lot | 50 | 0

1 | admin | Admin
2 | staff | Staff
```

## Roles and permissions

The six Activity 4 roles and three memberships remained in the same cluster. Project logins have no SUPERUSER, CREATEDB or CREATEROLE attributes. Object grants came from the archive; database-level settings were applied separately.

For a fresh cluster only, recreate the roles before restoring:

```sql
CREATE ROLE parkit_owner_grp NOLOGIN;
CREATE ROLE parkit_runtime_grp NOLOGIN;
CREATE ROLE parkit_readonly_grp NOLOGIN;
CREATE ROLE parkit_dba LOGIN INHERIT;
CREATE ROLE parkit_app LOGIN INHERIT;
CREATE ROLE parkit_auditor LOGIN INHERIT;
GRANT parkit_owner_grp TO parkit_dba;
GRANT parkit_runtime_grp TO parkit_app;
GRANT parkit_readonly_grp TO parkit_auditor;
```

PostgreSQL's default role attributes omit elevated privileges. Set distinct passwords privately using psql `\password`. These fresh-cluster statements were not rerun over the existing roles.

| Account | Test statement | Expected | Actual |
|---|---|---|---|
| `parkit_app` | `SELECT zone_name, max_capacity FROM public.parking_zone;` | Allowed | Returned Main Parking Lot, 50 |
| `parkit_auditor` | `SELECT user_id, username, role FROM public.staff_user;` | Allowed | Returned the two users |
| `parkit_auditor` | `UPDATE public.parking_zone SET current_active_count=current_active_count;` | Denied | Permission denied for table parking_zone |
| `parkit_auditor` | `SELECT password_hash FROM public.staff_user;` | Denied | Permission denied for table staff_user |

The UPDATE test ran inside a transaction; no change was committed. These checks were performed during restoration and rechecked against `parkit_a6_recovered` when simplifying this report.

The private PHP copy connected as `parkit_app` to each restored/recovered database. PDO confirmed the correct database/account, and Staff login, dashboard, monitoring and logout succeeded. The temporary web server was stopped afterwards.

**Result: successful restoration with documented issues.** Two owner-only sequence ACLs appeared as default NULL ACLs after restore; PostgreSQL's effective permissions were equivalent. Existing application authorization limitations remain unchanged.
