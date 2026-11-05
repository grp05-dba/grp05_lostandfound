# User roles and access model

PUP-SPOT has separate public and administrative interfaces with separate database connections. It does not use application-level Admin login accounts.

## Interface responsibilities

| Interface / role | Responsibilities | Database connection |
| --- | --- | --- |
| Public student/guest | Browse and search found items, submit lost reports, submit claims, and use public tracking features | Public DB role (lostandfound_public) with limited privileges |
| Campus Marshal/Admin | Manage found-item records, review claims, and update administrative statuses | Admin DB role (lostandfound_app) with broader application privileges |
| PostgreSQL administrator | Provision the database, run schema and role scripts, and maintain roles/privileges | Setup and maintenance only; not an application connection |

These are interface responsibilities, not individual application accounts. The project does not provide an Admin username/password login or per-person identity management.

## Connection separation

- The public API uses the public database connection configured by DB_PUBLIC_USER and DB_PUBLIC_PASSWORD.
- The admin API uses the admin application connection configured by DB_USER and DB_PASSWORD.
- The public role is restricted to the database operations required by public workflows.
- The admin role has broader permissions required by staff-facing management workflows.
- The application should not connect using PostgreSQL's built-in postgres superuser.

The role-creation SQL script defines the database roles and grants. Each API entry point uses the connection assigned to its interface.

## Deployment and security boundary

The intended deployment separates the public-facing API (Server A) from the administrative API (Server B). The administrative server is intended to be reachable only through the campus private network or equivalent network restrictions.

There is no Admin login layer by design. Network access restriction is therefore the administrative access boundary. Anyone who can reach the administrative server over the permitted network may potentially access its functions. This limitation is accepted for the current course project and should be considered before real-world deployment.

For local demonstrations, both interfaces can run from the same repository on separate PHP server ports (public: 8000, admin: 8001). This simulates the two-server arrangement; two ports on one computer do not provide physical or network isolation. Keep the admin server bound to localhost during local testing unless the demonstration environment specifically requires otherwise.

## Credential handling

Keep real database passwords in the local .env file only. Do not commit .env, real credentials, provider keys, or database dumps. Run the sample role script with private passwords as a PostgreSQL administrator during setup.

See [setup](setup.md) for configuration and [architecture](architecture.md) for the deployment model.
