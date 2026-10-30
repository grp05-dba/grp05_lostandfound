# Application roles and intended database access

Reviewed at `17dfae5`. This maps workflows to intended database privileges for the course; it does not claim the role split is already enforced.

| Application role | Intended workflow | Intended database access |
| --- | --- | --- |
| Student / guest | Browse found items/categories; submit reports/claims; cancel their own submission by reference code | SELECT on permitted public data; scoped INSERT for submissions; cancellation needs a constrained design agreed by the team |
| Campus staff / marshal | Register found items, manage categories, inspect reports/claims, update statuses | SELECT, INSERT and UPDATE on the specific objects needed; sequence USAGE for generated IDs |
| DBA / database owner | Initialize schema, provision accounts, maintain objects, back up and restore | Separate administrative account; not the ordinary app login |

## Actual implementation

There are public and admin route prefixes, but no user-account table, login middleware or enforced split into separate public/admin server instances. Both namespaces are reachable through the same public/index.php. A private-campus deployment remains a concept, not an implemented access boundary.

The DB connection uses one DB_USER value from .env for all requests. The SQL schema script does not create database roles or grants. The actual privileges on another group's installation depend on its DBA configuration.

The local rehearsal used a dedicated pupspot_runtime login with no SUPERUSER, CREATEDB or CREATEROLE attributes. It had table CRUD, schema USAGE and sequence access. This was local evidence, not a checked-in provisioner or proof of student/staff privilege separation. No credentials belong in these pages.

## Verification for Activity 4

For each required project copy, document the chosen role, database, schema, objects, membership and allowed actions. Test database CONNECT, schema USAGE, table/view privileges, sequences, PUBLIC access and default privileges where relevant. Record both permitted and denied operations using the relevant account.

Use separate owner/maintenance credentials for administrative work. A successful API request with an unrestricted account does not establish least privilege. The complete permission plan and cross-group evidence depend on the actual project being tested.

## Current workflow coverage

The present API retrieves staff records and public categories. Public found-item browsing, report/claim submissions and cancellations, staff writes, and notification workflows still need implementation or integration. See [API reference](api.md) before attributing a capability to a role.

The original proposal remains unchanged. Any decision about role separation or restrictions should be agreed with the project lead and reflected here after implementation.

