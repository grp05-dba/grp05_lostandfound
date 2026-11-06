# Part A - Database Setup and Assessment

## 1. Objective and review scope

Set up Group 6's HabalGo application and database, identify its objects and actual database operations, and prepare a least-privilege access plan for Activity 4. The assignment PDF is in the parent Activity 4 directory. Group 2's reports were used as a structural reference; all findings below concern the reviewed HabalGo source and executed local tests.

Reviewed and tested on **6 November 2026 (Asia/Manila)**. The four requested files cover assessment, planning, implementation/least privilege and verification. The requested `part_d.md` filename contains the verification required by the PDF's **Part E**; the PDF's Part D is included in [part_cd.md](part_cd.md).

| Item | Verified details |
|---|---|
| Project | HabalGo - Ride and Booking Management System, Group 6 |
| Repository | [https://github.com/jeanaroyo/HabalGo](https://github.com/jeanaroyo/HabalGo) |
| Reviewed branch | `main` |
| Reviewed commit | `c523913b6ffa57dae754a7fb6e4d6ffed4ac7070` |
| Database | `grp00_habalgodb` (the name documented by the repository) |
| Application schema | `habalgo` |
| Tables / sequences / indexes | 8 / 7 / 17 |
| Local server/client | PostgreSQL 18.6, Windows x64; psql |
| Database endpoint | `127.0.0.1:55432`, separate database in the existing isolated evaluation cluster |
| PHP | 8.2.12 with PDO_PGSQL enabled |
| Application endpoint | `http://127.0.0.1:18082`, PHP development server bound to loopback |
| Ordinary runtime account | `habalgo_app`, non-superuser |
| Setup result | **Success with issues**: application and database work; configuration and integrity/security findings remain |

The system PostgreSQL service on port 5432 was not modified. The Group 4 lab database remains separate on the evaluation cluster, and its explicit access grants were preserved.

## 2. Reviewed sources and documented setup

Pinned upstream sources:

- [README and installation guide](https://github.com/jeanaroyo/HabalGo/blob/c523913b6ffa57dae754a7fb6e4d6ffed4ac7070/README.md).
- [Root schema](https://github.com/jeanaroyo/HabalGo/blob/c523913b6ffa57dae754a7fb6e4d6ffed4ac7070/schema.sql) and [documented root sample-data file](https://github.com/jeanaroyo/HabalGo/blob/c523913b6ffa57dae754a7fb6e4d6ffed4ac7070/sample%20data.sql).
- [Alternative numbered schema](https://github.com/jeanaroyo/HabalGo/blob/c523913b6ffa57dae754a7fb6e4d6ffed4ac7070/database/01_schema.sql) and [alternative numbered seed](https://github.com/jeanaroyo/HabalGo/blob/c523913b6ffa57dae754a7fb6e4d6ffed4ac7070/database/02_seed.sql).
- [Existing role/privilege script](https://github.com/jeanaroyo/HabalGo/blob/c523913b6ffa57dae754a7fb6e4d6ffed4ac7070/database/03_roles_and_privileges.sql).
- [Database connection configuration](https://github.com/jeanaroyo/HabalGo/blob/c523913b6ffa57dae754a7fb6e4d6ffed4ac7070/config.php), [API operations](https://github.com/jeanaroyo/HabalGo/blob/c523913b6ffa57dae754a7fb6e4d6ffed4ac7070/api.php) and [frontend requests](https://github.com/jeanaroyo/HabalGo/blob/c523913b6ffa57dae754a7fb6e4d6ffed4ac7070/js/app.js).

No separate PDF progress document or standalone application-user-role document was present in the reviewed checkout. The README, SQL, PHP and JavaScript were therefore the available assessment sources.

The README instructs creating `grp00_habalgodb`, running root `schema.sql`, then root `sample data.sql`. That procedure was followed in the isolated database, under the project owner role. The sample file inserts **10 drivers only**; it does not populate the other seven tables. The alternative `database/02_seed.sql` contains two drivers and two customers and was not run in addition to the documented root seed. Root sample inserts are not idempotent because of unique driver licenses; do not rerun them against an already populated database without a plan.

Executed setup:

1. Run [01_roles_database.sql](sql/01_roles_database.sql) from an administrative database in the isolated cluster.
2. Apply [03_lab_isolation.sql](sql/03_lab_isolation.sql) only to this evaluation cluster; it preserves existing Group 4 explicit grants.
3. Connect to `grp00_habalgodb`, execute `SET ROLE habalgo_owner_grp`, and run the upstream root schema and sample-data files unchanged.
4. As provisioning administrator, apply [02_privileges.sql](sql/02_privileges.sql).
5. Assign distinct random passwords locally; use process environment variables to launch PHP with `habalgo_app`.
6. Verify each account through independent psql TCP connections, then exercise the real HTTP API.

[Setup output](evidence/setup.txt), [catalog inventory](evidence/catalog.txt), [runtime identity](evidence/application_runtime.txt) and [HTTP validation](evidence/application_validation.txt) provide execution evidence.

## 3. Configuration inconsistencies and local resolution

| Finding | Effect | Evaluated resolution |
|---|---|---|
| README tells users to copy `.env`, but `config.php` only calls `getenv()` and loads no `.env` file | Copying the file alone does not configure PHP | Supply variables in the PHP process environment; no source change |
| `.env.example` uses `DB_PASSWORD`, while `config.php` reads `DB_PASS` | Template password name is ineffective for the actual connection code | Supply private `DB_PASS` |
| Default database in `config.php` is `habalgo`, while README names `grp00_habalgodb` | Omitting DB_NAME targets a different database | Explicit `DB_NAME=grp00_habalgodb` |
| Default database user is `postgres` | Unconfigured ordinary traffic could use a superuser | Explicit `DB_USER=habalgo_app` |
| README's clone command contains Markdown link syntax inside a shell command | Copy/paste clone command is invalid | Clone using the actual supplied Git URL |
| Existing role SQL includes fixed password literals, generic group names and blanket CRUD/future grants | Published credentials, collisions and excessive privilege if used unchanged | Do not execute that script; create project-specific groups, local random passwords and reviewed grants |

The upstream fixed password values are deliberately not reproduced or reused. If anyone deployed them, they should replace those credentials locally. No credential file was added to the HabalGo checkout. The owning repository's tracked files were not edited, committed or pushed.

## 4. Database inventory

| Table | Purpose | Primary key | Rows after cleanup |
|---|---|---|---:|
| `customer` | Customer contact records | `customer_id` | 0 |
| `driver` | Driver contact and license records | `driver_id` | 10 |
| `vehicle` | Plates, vehicle type and model | `vehicle_id` | 0 |
| `driver_vehicle` | Driver/vehicle assignments and date ranges | `(driver_id, vehicle_id)` | 0 |
| `location` | Addresses and cities for pickup/dropoff | `location_id` | 0 |
| `booking` | Customer, driver, locations, time and status | `booking_id` | 0 |
| `payment` | Booking, amount, payment method and status | `payment_id` | 0 |
| `rating_feedback` | Booking/customer feedback and rating | `rating_id` | 0 |

Seven SERIAL sequences serve customer, driver, vehicle, location, booking, payment and feedback IDs. `driver_vehicle` has a composite key and no sequence. Seventeen indexes comprise eight primary-key indexes, four unique-constraint indexes and five explicit lookup indexes. No application-defined views, materialized views, functions, procedures or triggers were imported. Temporary future-object probes were removed after verification.

Relationships:

- `driver_vehicle` references driver and vehicle.
- `booking` references customer, optional driver and two location rows.
- `payment` references booking.
- `rating_feedback` references booking and customer independently.

Unique constraints cover customer email, driver license, vehicle plate and `(booking_id, customer_id)` for feedback. CHECK constraints validate assignment end dates, booking-status labels, positive payment amounts and ratings from 1 to 5. Most parent deletes are restricted; deleting a referenced booking driver sets `booking.driver_id` to NULL. Foreign-key updates cascade as declared in the schema.

## 5. Actual application operations

| Feature / API path | Required database access |
|---|---|
| Dashboard | SELECT/aggregate customer, booking, payment, feedback and joined display records |
| Options | SELECT drivers and bookings |
| Customer CRUD | SELECT, INSERT, UPDATE, DELETE customer |
| Vehicle CRUD and driver assignment | SELECT/INSERT/UPDATE/DELETE vehicle and driver_vehicle; SELECT driver |
| Booking CRUD | SELECT/INSERT/UPDATE/DELETE booking; SELECT/INSERT customer and location |
| Payment CRUD | SELECT/INSERT/UPDATE/DELETE payment and joined booking/customer reads |
| Feedback CRUD | SELECT/INSERT/UPDATE/DELETE rating_feedback; read booking/customer/status |

There is no driver-maintenance API resource; drivers are only read for options/display. Location helpers find or insert locations but do not update/delete them. These distinctions justify narrower runtime permissions than blanket CRUD on all eight tables.

No authenticated customer, driver, cashier or administrator application roles are implemented. The PHP endpoint does not establish a user session or perform an authorization check before CRUD. Human role labels must not be invented or confused with the PostgreSQL service accounts introduced for this evaluation.

## 6. Findings and status

The application ran against the non-superuser account and completed real API create/update/delete flows. All 70 main role checks, eight future-object checks and four additional cross-project checks passed. The full result is qualified by unresolved application/business-integrity limits:

- API CRUD accepted requests with no authentication credentials.
- Direct SQL allowed two simultaneously active drivers on one vehicle.
- Direct SQL accepted feedback for a pending booking using a different customer; PHP normally blocks incomplete-booking feedback and derives the customer itself.

These are recorded with proof in [the verification report](part_d.md). The four reports, SQL and evidence are saved in Group 5's local evaluation folder. Owner feedback has not been sent, the class tracker has not been edited, and the consolidated submission PDF has not been generated in this scoped task.
