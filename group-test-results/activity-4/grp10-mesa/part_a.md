# Part A - Database Setup and Assessment

## 1. Scope and source identity

Group 5 evaluated **Group 10 - MESA - Restaurant Online Ordering and Table Reservation System** on **6 November 2026 (Asia/Manila)**. Instructions: the Activity 4 PDF in the parent directory. Group 2's report structure was the reference; this report records executed work rather than copying an unverified setup claim.

| Item | Verified value |
|---|---|
| Repository | [MESA - Restaurant Online Ordering and Table Reservation System](https://github.com/kathlenmaecallos11-arch/Restaurant-Online-Ordering-Table-Reservation-System) |
| Reviewed branch / commit | `main` / `9e1141a51515fcede0fe176ee5f47cfb6c8abf9b` |
| Upstream default database | `grp_binarysisters_projectdb` |
| Separate evaluated database | `mesa_g05_activity4`, schema `public` |
| Server/client | PostgreSQL **18.3**, Windows x64, psql |
| Dedicated endpoint | `127.0.0.1:55410`, SCRAM-SHA-256 |
| Application runtime | `PHP 8.5.10 with PDO PostgreSQL` |
| Ordinary database login | `rors_app` |
| HTTP test port | `18090` |

Reviewed source: [README/setup](https://github.com/kathlenmaecallos11-arch/Restaurant-Online-Ordering-Table-Reservation-System/blob/9e1141a51515fcede0fe176ee5f47cfb6c8abf9b/restaurant-ordering-reservation-system/README.md), [application/database role documentation](https://github.com/kathlenmaecallos11-arch/Restaurant-Online-Ordering-Table-Reservation-System/blob/9e1141a51515fcede0fe176ee5f47cfb6c8abf9b/restaurant-ordering-reservation-system/docs/user-roles.md), database migrations, integrity logic, views, indexes, seed data, role scripts, setup helpers and PHP controllers/configuration. Exact source commit is also recorded in [source inventory](evidence/source-inventory.json).

The Windows clone fetched the source commit but checkout failed on an unrelated test folder containing the Windows-invalid component `G08-Campus Canteen Pre ` (trailing space). A committed Git archive was exported into a separate snapshot, excluding `evaluate_other_groups/` and invalid names. Git's NTFS validation was disabled only for that in-memory archive command, not globally; invalid members were never written. Application/migration/seed files were preserved byte-for-byte. No owning-repository commit, push or application-source fix was made.

## 2. Documented setup and evaluated procedure

The documented setup is PostgreSQL roles/database, migrations 000–004, sample data, local environment configuration, then PHP's built-in server. Migration 000 hardcodes `grp_binarysisters_projectdb`, and the documented `database/roles/03_set_passwords.psql` is absent. This evaluation explicitly creates its separate database and runs migrations **001–004**, then `database/seeds/001_seed_data.sql`, without changing those SQL files. It does not pretend that the missing password helper worked. Distinct random local login passwords were set through private administrator sessions.

The upstream progress PDF `docs/progress/BinarySisters_Progress_Documentation.pdf` was reviewed: seven pages, 28 `[TO COMPLETE]` markers, and repository/tracker placeholders remain. Its existence does not establish a finished course submission.

Executed local procedure:

1. Initialize a new loopback-only PostgreSQL cluster under `D:/Data Administration/course-review/g10-activity4-lab/pgdata`. Existing services, G08's lab and other projects were not modified.
2. Apply [01_roles_database.sql](sql/01_roles_database.sql) as the separate lab provisioning administrator in `postgres`. Set three distinct random local passwords without recording them in submitted files.
3. Connect to `mesa_g05_activity4`, execute `SET ROLE rors_owner_grp`, and load the documented upstream SQL files unchanged. [Setup transcript](evidence/setup.txt) records the files and actual output, without echoing seed passwords/hashes.
4. Apply [02_privileges.sql](sql/02_privileges.sql) to the target database and [03_lab_isolation.sql](sql/03_lab_isolation.sql) only to this dedicated cluster.
5. Start the unchanged application using the non-superuser `rors_app` account and process-local credentials. PHP uses the existing local extension-enabled ini and a writable lab-only session directory. No .env or source edit was needed.
6. Verify each PostgreSQL login independently through psql; exercise real authenticated HTTP workflows; remove HTTP-created rows and roll back SQL probe changes.

**Database/application setup result: Success with issues.** The adapted access policy and restricted runtime were actually exercised. The exact upstream one-command setup is not claimed to work unchanged. [Startup](evidence/application-startup.txt), [runtime identity](evidence/application-runtime.txt), [HTTP results](evidence/application-tests.json), [catalog](evidence/catalog.txt) and [final cleanup](evidence/final-cleanup.txt) support this result. No interactive browser testing is claimed.

## 3. Inventory and initial data

| Table | Seed rows after cleanup |
|---|---:|
| `customer` | 51 |
| `staff` | 10 |
| `menu_item` | 50 |
| `restaurant_table` | 20 |
| `orders` | 60 |
| `order_item` | 167 |
| `reservation` | 50 |
| `payment` | 56 |

Eight business tables, seven SERIAL sequences, four views, three application trigger functions and four non-internal triggers were reviewed. The extension inventory and exact owner/constraint definitions are in [catalog evidence](evidence/catalog.txt). Views: `v_customer_directory`, `v_staff_directory`, `v_order_summary`, `v_reservation_schedule`.

Order-item subtotal CHECKs and triggers maintain order totals; deferred checks reject an empty order. Reservation capacity is trigger-checked and overlapping two-hour active reservations are rejected by a GiST exclusion constraint. Customer and staff password hashes stay out of the directory/reporting views.

## 4. Access requirements identified before grants

Customer registration/login/profile uses customer S/I/U. Menu/table/staff management requires CRUD; checkout reads menu/customer and inserts orders, order_item and payment. Trigger total maintenance and customer/staff order actions require orders UPDATE. Reservation create/cancel/admin removal needs reservation CRUD. Payment reconciliation needs payment UPDATE but no DELETE. The app never updates/deletes order_item directly. Administrators and staff share the runtime SQL identity; PHP session checks distinguish their routes.

The resulting plan is in [Part B](part_b.md); implementation and least privilege are in [Parts C/D](part_cd.md); verified results are in [part_d.md](part_d.md), the requested filename for PDF Part E.
