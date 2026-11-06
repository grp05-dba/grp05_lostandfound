# Part A - Database Setup and Assessment

## 1. Scope and source identity

Group 5 evaluated **Group 11 - BoardTrack - Boarding House and Rental Management System** on **6 November 2026 (Asia/Manila)**. Instructions: the Activity 4 PDF in the parent directory. Group 2's report structure was the reference; this report records executed work rather than copying an unverified setup claim.

| Item | Verified value |
|---|---|
| Repository | [BoardTrack - Boarding House and Rental Management System](https://github.com/karlrobertc-art/BoardTrack) |
| Reviewed branch / commit | `main` / `242b366936f17324dca7e4435bc1d6abe59b27d7` |
| Upstream default database | `boardtrack_db` |
| Separate evaluated database | `boardtrack_g05_activity4`, schema `public` |
| Server/client | PostgreSQL **18.3**, Windows x64, psql |
| Dedicated endpoint | `127.0.0.1:55411`, SCRAM-SHA-256 |
| Application runtime | `Node.js 24.17.0; Express/EJS/pg` |
| Ordinary database login | `boardtrack_app` |
| HTTP test port | `18091` |

Reviewed source: [README/setup](https://github.com/karlrobertc-art/BoardTrack/blob/242b366936f17324dca7e4435bc1d6abe59b27d7/README.md), [application/database role documentation](https://github.com/karlrobertc-art/BoardTrack/blob/242b366936f17324dca7e4435bc1d6abe59b27d7/docs/user-roles.md), the full SQL bundle, migration/seed, bootstrap/configuration, authentication permissions and routes. Exact source commit is also recorded in [source inventory](evidence/source-inventory.json).

The repository cloned normally. Its tracked source was left unchanged. `npm ci --ignore-scripts --no-audit --no-fund` installed the locked dependencies; [installation output](evidence/dependency-install.txt) records 94 packages. No upstream automated test script exists in package.json. Generated dependencies remain outside Group 5's submission repository.

## 2. Documented setup and evaluated procedure

The documented plain-SQL alternative was used: execute `db/boardtrack_full_setup.sql` on a fresh database, which creates schema objects, sample data and the `schema_migrations` row. This bundle includes `btree_gist`/`pgcrypto`, the schema migration and seed data; it was not run in addition to separate duplicate migrations/seeds.

The normal app startup attempts schema setup by default. Runtime must not receive migration/DDL privileges simply to satisfy that bootstrap. The local process therefore uses the documented `AUTO_SETUP=false` switch, plus `AUTO_CREATE_DB=false` and `AUTO_SEED=false`, after administrator initialization. No own-project progress PDF was found. The AI-usage document still has a group-completion placeholder.

Executed local procedure:

1. Initialize a new loopback-only PostgreSQL cluster under `D:/Data Administration/course-review/g11-activity4-lab/pgdata`. Existing services, G08's lab and other projects were not modified.
2. Apply [01_roles_database.sql](sql/01_roles_database.sql) as the separate lab provisioning administrator in `postgres`. Set three distinct random local passwords without recording them in submitted files.
3. Connect to `boardtrack_g05_activity4`, execute `SET ROLE boardtrack_owner_grp`, and load the documented upstream SQL files unchanged. [Setup transcript](evidence/setup.txt) records the files and actual output, without echoing seed passwords/hashes.
4. Apply [02_privileges.sql](sql/02_privileges.sql) to the target database and [03_lab_isolation.sql](sql/03_lab_isolation.sql) only to this dedicated cluster.
5. Start the unchanged application using the non-superuser `boardtrack_app` account and process-local credentials. The process receives DATABASE_URL, a private SESSION_SECRET and AUTO_SETUP=false. A lab-only Node preload forces the source server to listen on 127.0.0.1; it changes only the bind address, not routes or business logic, and leaves tracked source untouched.
6. Verify each PostgreSQL login independently through psql; exercise real authenticated HTTP workflows; remove HTTP-created rows and roll back SQL probe changes.

**Database/application setup result: Success with issues.** The adapted access policy and restricted runtime were actually exercised. The exact upstream one-command setup is not claimed to work unchanged. [Startup](evidence/application-startup.txt), [runtime identity](evidence/application-runtime.txt), [HTTP results](evidence/application-tests.json), [catalog](evidence/catalog.txt) and [final cleanup](evidence/final-cleanup.txt) support this result. No interactive browser testing is claimed.

## 3. Inventory and initial data

| Table | Seed rows after cleanup |
|---|---:|
| `property` | 2 |
| `room` | 6 |
| `tenant` | 4 |
| `lease` | 4 |
| `payment` | 6 |
| `utility_bill` | 4 |
| `app_user` | 3 |
| `schema_migrations` | 1 |

Six business tables plus app_user and schema_migrations, seven SERIAL sequences (six granted to runtime), one summary view, two application trigger functions and two non-internal triggers were reviewed. The extension inventory and exact owner/constraint definitions are in [catalog evidence](evidence/catalog.txt). Views: `v_lease_summary`.

Primary/foreign/unique/CHECK constraints protect the model. The lease exclusion constraint rejects overlapping ACTIVE room leases; triggers synchronize room status and reject contradictory manual status changes. v_lease_summary calculates payments and utility totals. schema_migrations is provisioning metadata, not a business table.

## 4. Access requirements identified before grants

Administrator workflows require CRUD on property, room, tenant, lease, payment and utility_bill. Authentication reads app_user and invokes pgcrypto crypt(text,text). Lease triggers need the runtime to update rooms and read leases. Read-only reporting can use v_lease_summary alone; it need not read authentication hashes or tenant contact/ID columns. Staff and tenant limits are implemented by auth.js and tenant_id filters, not separate database logins.

The resulting plan is in [Part B](part_b.md); implementation and least privilege are in [Parts C/D](part_cd.md); verified results are in [part_d.md](part_d.md), the requested filename for PDF Part E.
