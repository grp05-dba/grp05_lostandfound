# Part A - Database Setup and Assessment

## 1. Project and reviewed sources

Group 5 evaluated **Group 02 - Park It** for COMP 018 Activity 4 on **6 November 2026**, using the Activity 4 PDF in the parent directory. This report replaces the previous Group 02 assessment and uses the repository supplied for this task.

| Item | Evaluated value |
|---|---|
| Repository | https://github.com/millerdevera6-glitch/park-it-database |
| Application directory | `park-it/` |
| Branch / commit | `main` / `0c01b3e87cf3d623f5f8c4936e3fe7fe56daeeb3` |
| Application | PHP with PDO PostgreSQL; HTML/CSS/JavaScript |
| Database | PostgreSQL 18.6; `grp_parkitdb`; `public` schema |
| Lab | Dedicated cluster `/tmp/activity4-grp02-lab`, loopback `127.0.0.1:55442` |
| Application test | Private copy served temporarily by PHP on `127.0.0.1:18082` |
| Runtime login | `parkit_app`, a member of `parkit_runtime_grp` |

Reviewed sources, pinned to the evaluated commit:

- [Installation guide](https://github.com/millerdevera6-glitch/park-it-database/blob/0c01b3e87cf3d623f5f8c4936e3fe7fe56daeeb3/park-it/README.md).
- [Database schema dump](https://github.com/millerdevera6-glitch/park-it-database/blob/0c01b3e87cf3d623f5f8c4936e3fe7fe56daeeb3/park-it/schema.sql).
- [Application user roles and proposed database mapping](https://github.com/millerdevera6-glitch/park-it-database/blob/0c01b3e87cf3d623f5f8c4936e3fe7fe56daeeb3/user-role.md).
- [Activity 3 project PDF](https://github.com/millerdevera6-glitch/park-it-database/blob/0c01b3e87cf3d623f5f8c4936e3fe7fe56daeeb3/PARK%20IT_%20DATABASE%20MANAGEMENT%20SYSTEM%20%281%29.pdf).
- PHP database configuration, seeder, session/authorization helpers, login, dashboard, vehicle, payment, history and monitoring modules in that same revision.

[Source review evidence](evidence/source_review.txt) records the commit and SHA-256 values. No source configuration secrets or password hashes are copied into the reports. The upstream checkout remains unchanged.

## 2. Setup performed

The upstream guide uses Windows XAMPP/pgAdmin, creates `grp_parkitdb` owned by `postgres`, imports `schema.sql`, and runs `config/seed.php`. The same database/application steps were executed with psql and installed PHP on Linux. PostgreSQL and the PHP `pdo_pgsql` extension were available; no dependency installation was required.

The default PostgreSQL socket had no running server. A fresh dedicated cluster was initialized in `/tmp`, without replacing an existing database or changing an operating-system service. It listens only on loopback port **55442** and its private Unix socket. Project logins use password authentication with SCRAM; provisioning uses an OS-peer mapping to the lab's `postgres` account.

Executed procedure:

1. Review the source operations and prepare [the access-control plan](part_b.md).
2. Create the three NOLOGIN groups, three restricted logins, project database and unrelated test database using [01_roles_database.sql](sql/01_roles_database.sql).
3. Assign generated private passwords locally. Import upstream `park-it/schema.sql` unchanged with `psql -v ON_ERROR_STOP=1`. Its `\restrict`/`\unrestrict` commands are valid in psql and were retained; the README's removal instruction applies to pgAdmin Query Tool.
4. The dump explicitly sets object owners to `postgres`. Transfer the five tables and their owned sequences to `parkit_owner_grp`, transfer the schema, and apply the reviewed grants with [02_privileges.sql](sql/02_privileges.sql). No table or column definitions were changed.
5. Copy the application outside the checkout into a protected `/tmp` directory. In that copy only, change connection constants to read private environment values. Execute upstream `config/seed.php` by PHP CLI as `parkit_dba`; suppress its credential-bearing HTML from submitted evidence.
6. Run normal application requests as `parkit_app`, never the DBA or provisioning superuser. Test all three logins independently and capture actual outcomes in [Part E](part_e.md).

**Setup result: Success with issues.** [Setup output](evidence/setup.txt), [final catalog](evidence/catalog.txt), [direct-login tests](evidence/results.json), and [application validation](evidence/application_validation.txt) support the result. The PHP test server was stopped after verification; the isolated database cluster remains available for local follow-up. `/tmp` is temporary storage, so this lab must be recreated if those files are cleared.

## 3. Actual database inventory

| Table | Primary key / sequence | Purpose | Rows after test cleanup |
|---|---|---|---:|
| `parking_zone` | `zone_id` / `parking_zone_zone_id_seq` | Zone name, capacity, occupied-space counter | 1 |
| `vehicle` | `vehicle_id` / `vehicle_vehicle_id_seq` | License plate and type | 0 |
| `staff_user` | `user_id` / `staff_user_user_id_seq` | Application username, password hash and role | 2 |
| `transaction` | `transaction_id` / `transaction_transaction_id_seq` | Entry/exit, vehicle/zone, status and lost-ticket flag | 0 |
| `payment` | `payment_id` / `payment_payment_id_seq` | Payment, transaction link, amount, method and timestamp | 0 |

The dump contains structure without sample rows. The PHP seeder creates **Main Parking Lot**, capacity **50**, occupancy **0**, and two users with roles **Admin** and **Staff**. Disposable parking/payment records were created for verification and removed. SQL probes roll back; sequence increments are not rolled back, so ID gaps are expected.

The final catalog contains **five tables, five sequences, nine indexes, five primary keys, four unique constraints, three foreign keys, and two CHECK constraints**. There are no application views/materialized views, custom functions/procedures or user-defined triggers after probe cleanup.

Foreign keys are `transaction.vehicle_id → vehicle.vehicle_id`, `transaction.zone_id → parking_zone.zone_id`, and `payment.transaction_id → transaction.transaction_id`, with default NO ACTION behavior. The unique constraints cover zone name, license plate, username and payment transaction ID. CHECKs enforce `current_active_count <= max_capacity` and `amount >= 0`; they do not enforce nonnegative occupancy, valid role/status/type/method values, or a unique active transaction per vehicle. Nullability and all constraint definitions are captured in the catalog evidence.

## 4. Application operations and required access

| Reviewed feature | Actual operations / relevant objects |
|---|---|
| `auth/login.php` | SELECT staff identity, hash and role; verify hash in PHP |
| `config/seed.php` | SELECT, INSERT zone/staff; run by provisioning/DBA account only |
| `modules/vehicles/index.php` | SELECT/INSERT vehicle and transaction; lock zone; UPDATE occupied count |
| `modules/vehicles/edit.php` | SELECT vehicle; UPDATE license plate/type |
| `modules/vehicles/delete.php` | SELECT references; DELETE only unreferenced vehicles |
| `modules/payments/process.php` | Lock transaction/vehicle and zone; INSERT payment; UPDATE exit/status/lost flag and occupancy, atomically |
| `modules/payments/history.php` | SELECT joined receipts; UPDATE payment method only |
| Dashboard and monitoring | SELECT summaries; `getParkingSummary()` can also UPDATE occupancy to reconcile counters |

The runtime requires three insert-sequence USAGE grants. Staff/zone sequences belong to setup operations. The auditor is a database inspection account added for Activity 4, not an upstream web feature; it reads safe staff columns without reading password hashes.

## 5. Issues and owner recommendations

1. **Source configuration uses `postgres` and contains a hardcoded database credential.** The local copy uses the restricted runtime login and private environment configuration. Owners should remove committed credentials, rotate any that are used, and use local secret configuration.
2. **Documented and actual permissions differ.** `user-role.md` omits sequence grants, vehicle DELETE and payment-method UPDATE required by the implementation. The evaluated plan supplies only the needed sequence and column permissions.
3. **Admin/Staff policy is not enforced by vehicle endpoints.** They call `requireLogin()` but do not enforce `isAdmin()`. Actual Staff HTTP requests registered and edited a vehicle. Both sessions share the database service login, so PostgreSQL roles cannot resolve this human-user authorization gap.
4. **Business invariants depend on PHP.** Direct runtime SQL can create duplicate active entries or negative occupancy; both were reproduced and rolled back. Owners should consider reviewed CHECK/partial-unique constraints and guarded operations. These are recommendations; the upstream schema was preserved.
5. **Seeder is a privileged setup task.** It prints demo credentials on first creation. Run it privately with the DBA, do not publish its output, replace demo credentials for real use, and restrict/remove public setup access after provisioning.

The four reports and supporting scripts/evidence are kept in our repository. Findings are prepared here for owners; no feedback was sent, tracker rows edited, consolidated PDF produced, or commits created as part of this scoped request. Existing Activity 5 reports describe an earlier environment/source and were not changed or represented as verification of this new lab.
