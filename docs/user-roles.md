# User roles and access model

Reviewed against `main` revision `9a803d2` (November 5, 2026). PUP-SPOT currently has separate public and admin interfaces, but the repository does not show a complete authentication and authorization system.

## Interface responsibilities

| Interface | Current purpose | Examples |
| --- | --- | --- |
| Public | Student/visitor-facing lost-and-found actions | Browse/search unclaimed items, submit and track lost reports, submit and track claims, view potential matches and remove a potential match from a report |
| Admin | Staff-facing record management | Review items/reports/claims, create and update items, update reports/claims, manage item images, inspect categories and view TextBee gateway diagnostics |
| Database administrator | Database provisioning and maintenance | Create the database, run schema/seed scripts, manage roles/privileges, backup and restore |

These are application responsibilities, not proof of authenticated user identities. The public/admin page separation is currently implemented through separate document roots and route prefixes/ports.

## Current implementation details

- Public interface: `public/app.html`, `public/js/app.js`, `public/index.php`.
- Admin interface: `admin/app.html`, `admin/js/admin.js`, `admin/index.php`.
- Both entry points call `Connection::getAdminConnection()`.
- `Connection::getPublicConnection()` exists and reads `DB_PUBLIC_USER` and `DB_PUBLIC_PASSWORD`, but the public entry point does not currently use it.
- The reviewed controllers do not implement login/session checks or per-user authorization before admin operations.
- A separate port or URL is not an access-control mechanism.

## Security guidance

Until authentication and least-privilege connection handling are implemented, run the admin server only on localhost or behind trusted network access controls. Do not publish the admin interface to the public internet. Do not place real credentials in documentation, source files or commits.

The database role-creation sample is a starting point for local setup, not proof that the running application uses separate public and admin database roles. Verify the actual grants and the connection method used by each entry point before claiming privilege separation.

## Suggested verification

For a deployment that requires separate privileges, verify the actual database user used by each entry point, database CONNECT, schema USAGE, table and sequence privileges, and denied operations. Test admin route access with and without authentication once an authentication layer exists. Record the exact database role and test results for each environment.

See [setup](setup.md) for environment configuration and [API reference](api.md) for implemented routes.
