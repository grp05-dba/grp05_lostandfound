# Part B - Identify Users, Group Roles, and Privileges

## 1. Access-control plan

This plan is based on Group 02's current `main` at `0c01b3e87cf3d623f5f8c4936e3fe7fe56daeeb3`, its `user-role.md`, and the PHP statements actually executed by its features. It was selected before provisioning the new test database. [Parts C and D](part_cd.md) implement it; [Part E](part_e.md) records actual verification.

| Login / account | NOLOGIN group | Application role served | Responsibility and required privileges |
|---|---|---|---|
| `parkit_app` | `parkit_runtime_grp` | Shared PHP service for Admin and Staff sessions | CONNECT, schema USAGE, exact table/column grants below, USAGE on three insert sequences |
| `parkit_auditor` | `parkit_readonly_grp` | External database inspection; no corresponding web role | Read four operational tables and safe staff columns; no writes, password hashes or sequences |
| `parkit_dba` | `parkit_owner_grp` | Trusted project database administrator | Database/schema/table/sequence ownership through its group; seed users/zones, maintain objects and run migrations |
| Local `postgres` provisioner | None | No application role | Initialize this dedicated lab, create cluster-wide roles/databases and assign credentials |

All six project roles lack SUPERUSER, CREATEDB, CREATEROLE, REPLICATION and BYPASSRLS. Each login inherits just its designated group without ADMIN OPTION. The owner group is intentionally powerful within this project; the DBA is trusted to alter/drop project objects but cannot provision cluster roles or databases. It must never serve ordinary PHP requests.

## 2. Table and column matrix

| Table | Runtime SELECT | INSERT | UPDATE columns | DELETE | Auditor |
|---|---|---|---|---|---|
| `parking_zone` | Yes | No | `current_active_count` | No | SELECT |
| `vehicle` | Yes | Yes | `license_plate`, `vehicle_type` | Yes | SELECT |
| `staff_user` | Yes, including hash for authentication | No | None | No | SELECT (`user_id`, `username`, `role`) only |
| `transaction` | Yes | Yes | `exit_time`, `status`, `is_lost_ticket` | No | SELECT |
| `payment` | Yes | Yes | `payment_method` | No | SELECT |

The code's vehicle-deletion endpoint needs DELETE, while foreign keys protect vehicles referenced by history. Payment-method correction needs UPDATE on that column; amount, timestamp, ID and transaction linkage remain protected against UPDATE. Column grants also prevent runtime changes to capacity, staff roles/hashes, original entry times and transaction vehicle/zone links. INSERT still permits caller-supplied values; these grants do not enforce every business rule or make history immutable.

The upstream role guide omits vehicle DELETE and payment-method UPDATE even though the endpoints use them. This evaluation adds only those feature-required privileges, rather than granting blanket UPDATE to every table. Seed-only staff/zone writes belong to the DBA, not the runtime.

## 3. Sequences, schemas and future objects

| Sequence | Runtime | Auditor | Purpose |
|---|---|---|---|
| `vehicle_vehicle_id_seq` | USAGE | None | Vehicle registration |
| `transaction_transaction_id_seq` | USAGE | None | Parking entry |
| `payment_payment_id_seq` | USAGE | None | Payment insertion |
| `parking_zone_zone_id_seq` | None | None | DBA-only zone setup |
| `staff_user_user_id_seq` | None | None | DBA-only staff setup |

USAGE allows `nextval`/`currval`; sequence SELECT and UPDATE (`setval`) are unnecessary. The owner controls all five sequences. CONNECT does not grant object access, and schema USAGE does not grant table access.

PUBLIC project database/schema/table/sequence privileges are revoked. Runtime/auditor have no database CREATE/TEMPORARY, schema CREATE, TRUNCATE, REFERENCES, TRIGGER, MAINTAIN or grant authority. An unrelated lab database, `postgres`, and `template1` have PUBLIC CONNECT revoked in this isolated cluster. These cluster-wide targets require an impact review before similar changes on a shared server.

Future tables/sequences receive no automatic service grants. Migrations use `SET ROLE parkit_owner_grp` and explicit reviewed object grants. PUBLIC execution of future owner-created and DBA-created functions is revoked globally for those creators; a schema-specific revoke alone would not remove the global default. Future-object tests verify this policy.

## 4. Application role boundary

The seed stores `Admin` and `Staff`; `isAdmin()` normalizes case. The role guide describes administrator-only vehicle registration/maintenance, but the reviewed endpoints use `requireLogin()` without calling `isAdmin()`. Both users share `parkit_app`; PostgreSQL cannot distinguish their web sessions. The implemented database roles restrict the service itself. Enforcing the stated human-user policy still requires PHP authorization checks on each restricted action.
