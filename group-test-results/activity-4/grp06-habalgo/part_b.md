# Part B - Identify Users, Group Roles, and Privileges

## 1. Objective

Define database accounts from the operations actually performed by HabalGo's `api.php`. The database service account, inspection account and project DBA are distinct from human web users. The reviewed application has no authenticated per-user role system.

## 2. Accounts and group memberships

| Login / account | NOLOGIN group | Application role served | Responsibility and required privilege |
|---|---|---|---|
| `habalgo_app` | `habalgo_runtime_grp` | Shared PHP service supporting the current CRUD interface | CONNECT, habalgo schema USAGE, table grants below and six sequence USAGE grants |
| `habalgo_auditor` | `habalgo_readonly_grp` | External database inspection/reporting; no web auditor login exists | CONNECT, schema USAGE, SELECT on the eight approved demo tables |
| `habalgo_dba` | `habalgo_owner_grp` | Project database administration, not an application user | Inherited ownership of the project database, schema, tables and sequences; DDL and approved maintenance |
| Local provisioning administrator | Not a project group | No ordinary application role | Cluster/database/role creation and local password assignment |

Each project login receives only its designated group membership, with no ADMIN OPTION. All six HabalGo roles are NOSUPERUSER, NOCREATEDB, NOCREATEROLE, NOREPLICATION and NOBYPASSRLS. Group roles are NOLOGIN. Logins inherit the group's object privileges; only the DBA can SET ROLE to the project owner.

The DBA is a trusted project owner and can alter/drop project objects and repair project data. It cannot create roles/databases or administer other project databases. Runtime traffic never uses that account. Ownership is deliberately broader than ordinary CRUD privileges and is not an appropriate application credential.

## 3. Table privilege matrix

| Table | Runtime SELECT | INSERT | UPDATE | DELETE | Auditor |
|---|---|---|---|---|---|
| `customer` | Yes | Yes | Yes | Yes | SELECT only |
| `driver` | Yes | No | No | No | SELECT only |
| `vehicle` | Yes | Yes | Yes | Yes | SELECT only |
| `driver_vehicle` | Yes | Yes | Yes | Yes | SELECT only |
| `location` | Yes | Yes | No | No | SELECT only |
| `booking` | Yes | Yes | Yes | Yes | SELECT only |
| `payment` | Yes | Yes | Yes | Yes | SELECT only |
| `rating_feedback` | Yes | Yes | Yes | Yes | SELECT only |

The runtime needs customer auto-creation, vehicle reassignment, booking edits/deletes, payment corrections/deletes and feedback edits/deletes because the existing application implements those operations. This differs from an append-only financial ledger: historical-record immutability is not claimed. Foreign keys still restrict deletion of referenced parent records.

Driver records are provisioned by the DBA, because the current API exposes no driver CRUD endpoint. Locations are created by booking helpers and retained when unused; only the DBA may clean up unused locations. There is no normal UPDATE/DELETE location route.

The auditor is an approved inspection account for this demo dataset and can read its contact fields; it is not a redacted public reporting account. It has no write or sequence privileges. No runtime/auditor TRUNCATE, REFERENCES, TRIGGER, MAINTAIN, DDL, grant authority or ownership is assigned.

## 4. Sequences and other objects

| Sequence | Runtime privilege | Reason |
|---|---|---|
| `customer_customer_id_seq` | USAGE | Customer creation |
| `vehicle_vehicle_id_seq` | USAGE | Vehicle creation |
| `location_location_id_seq` | USAGE | Pickup/dropoff creation |
| `booking_booking_id_seq` | USAGE | Booking creation |
| `payment_payment_id_seq` | USAGE | Payment creation |
| `rating_feedback_rating_id_seq` | USAGE | Feedback creation |
| `driver_driver_id_seq` | None | Driver provisioning is DBA-only |

USAGE supports generated IDs and current sequence values but not `setval`. Blanket sequence SELECT/UPDATE is unnecessary. The auditor receives no sequence access; the owner group controls all seven sequences.

No application-defined view or routine requires a runtime grant in the imported schema. Owner-created future functions do not receive PUBLIC EXECUTE. Future tables/sequences have no automatic runtime/auditor grants; migrations require an explicit privilege review.

## 5. Database and schema boundaries

Runtime and auditor receive CONNECT to `grp00_habalgodb` and USAGE only on schema `habalgo`. They receive neither database CREATE/TEMPORARY nor schema CREATE. PUBLIC access is removed from the project database, `habalgo`, `public`, project tables and sequences.

Other databases are reviewed separately: grants on HabalGo cannot by themselves prevent access inherited from PUBLIC elsewhere. Actual connections to the dedicated unrelated database, Group 4's databases, `postgres` and `template1` are denied. Reverse Group 4-to-HabalGo connection tests are also denied, while Group 4's runtime retains its own access. These changes apply to the isolated evaluation cluster, not the user's PostgreSQL service on port 5432.

The runtime's search path and timeouts are configured explicitly. The PHP code also selects schema `habalgo` on connection. A schema name/search path is not an authorization boundary without the corresponding ACLs.

## 6. Limits of the role plan

One PHP service credential provides all current feature permissions. Database roles do not identify individual HTTP callers. Authentication, authorization, logging of human actors and more restrictive business workflows require application changes outside this evaluation's tracked-source scope.

GRANT/REVOKE also does not create missing relational rules. Runtime INSERT can create conflicting active vehicle assignments and mismatched/non-completed feedback because those conditions are not enforced by the schema. The reproduced gaps are documented in Part D rather than reported as fixed by role creation.
