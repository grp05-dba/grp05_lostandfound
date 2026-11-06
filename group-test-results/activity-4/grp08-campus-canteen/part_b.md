# Part B - Identify Users, Group Roles, and Privileges

## 1. Access-control plan

Prepared from G08's application operations before role creation; implemented and verified on 6 November 2026. A public visitor, student, vendor and application administrator are application identities, not PostgreSQL logins. The service login combines the SQL operations required by those workflows. API authorization limits the person; database privileges limit the service process.

| Login account | Group role | Application role served | Responsibility | Required privilege |
|---|---|---|---|---|
| `canteen_app` | `canteen_app_grp` (NOLOGIN) | Public, student, vendor, application administrator through the API | Ordinary runtime | CONNECT; schema USAGE; explicit table grants below; USAGE on seven ID sequences |
| `canteen_readonly` | `canteen_readonly_grp` (NOLOGIN) | Reporting/auditing; no application login | Approved menu and sales inspection | CONNECT; schema USAGE; approved reporting columns only; no sequences/writes |
| `canteen_admin` | `canteen_owner_grp` (NOLOGIN) | Database maintenance; not the application's ADMIN identity | Own/migrate project objects after explicit `SET ROLE` | Owner rights in this database; no cluster role/database creation |

`lab_admin` is the separate provisioning superuser for the new disposable cluster. It initializes the lab, assigns passwords and provisions roles; the API never uses it. The maintenance login does not automatically inherit owner privileges (`NOINHERIT`, membership INHERIT FALSE / SET TRUE / ADMIN FALSE). The runtime and reporting memberships inherit their groups but have no ADMIN OPTION. No login can grant group membership to others.

## 2. Table privilege matrix

S = SELECT, I = INSERT, U = UPDATE, D = DELETE. Unlisted privileges are denied.

| Table | Runtime group | Reporting group | Justification |
|---|---|---|---|
| `student` | S, I | None | Login/registration; no existing student update/delete path |
| `vendor` | S, I, U | S(`vendor_id`, `vendor_name`) | Vendor registration/login; administrator changes active state |
| `menu_item` | S, I, U, D | S(`item_id`, `vendor_id`, `item_name`, `price`, `is_available`) | Vendor menu management and public/report reads |
| `customer_order` | S, I, U | S(`order_id`, `vendor_id`, `order_date`, `status`) | Order placement and status transitions; report aggregation |
| `order_item` | S, I | S(`order_id`, `item_id`, `quantity`, `price_at_order`) | Capture line items once; calculate sales |
| `queue_entry` | S, I, U | None | Create queue and advance service status |
| `notification` | S, I, U | None | Order messages and read flag |

Reporting excludes student identity/contact data, student/vendor password hashes, vendor contact details, queues and notifications. Full `SELECT *` on vendor is intentionally denied even though selected public columns are readable. No TRUNCATE, REFERENCES, TRIGGER, MAINTAIN or grant options are assigned to ordinary accounts.

## 3. Sequence, schema and maintenance access

The runtime inserts into all seven SERIAL-backed tables, so all seven current sequences receive USAGE. USAGE permits generated IDs and `currval`; separate sequence SELECT or UPDATE is unnecessary. Direct sequence-state reads and `setval` are denied. Reporting has no sequence access.

Runtime/reporting have only schema USAGE, with no CREATE or database TEMPORARY privilege. PUBLIC database/schema/object access is removed within the dedicated lab. All project tables/sequences belong to `canteen_owner_grp`; the maintenance login must explicitly assume it for DDL. No project role receives SUPERUSER, CREATEDB, CREATEROLE, REPLICATION or BYPASSRLS. Cluster provisioning remains a separate administrator responsibility.

## 4. Deliberate adaptations and boundaries

The upstream plan gives `canteen_admin` CREATEROLE and direct ownership. This evaluation uses an owner group with explicit maintenance activation and no CREATEROLE, because routine migrations need object ownership rather than cluster-wide role provisioning. Runtime table permissions otherwise follow the source's current workflows; table-wide UPDATE is retained on entities Hibernate modifies, since ordinary JPA updates can include all mutable fields.

The upstream default script automatically grants runtime S/I/U on future tables. This evaluation gives no automatic future table/sequence grants and removes PUBLIC function execution defaults for both the owner group and maintenance login. Migrations must review grants explicitly.

Database grants do not implement a per-student/per-vendor row policy. A runtime credential holder can read all runtime-authorized rows and can directly insert an ADMIN student record; a rolled-back probe confirmed that boundary. Treat the service credential as privileged application infrastructure. End-user API authorization remains essential; RLS or guarded database routines would require an owner-approved design change. No such upstream schema change was made.
