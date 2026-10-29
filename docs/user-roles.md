# PUP-SPOT application and database roles

Updated 29 October 2026. The original proposal remains unchanged. Application roles below describe workflows, not new user-account tables or login screens.

| Application role | Intended capabilities | Intended database access |
| --- | --- | --- |
| Student / guest | Browse found items, submit a lost report or claim, cancel their own submission using its reference code | Read item/category data and insert submissions; cancellation must be constrained to the supplied reference code by the application |
| Campus marshal / staff | Register found items, manage categories, read reports and claims, update item/report/claim states | SELECT, INSERT and UPDATE on the relevant tables; sequence USAGE for generated IDs |
| Database administrator | Install schema, provision roles, maintain objects, back up and restore | Separate database owner/maintenance account; never use its credentials for ordinary API requests |

## What exists now

The current application has public/admin route prefixes but no application authentication and no enforced separation of those routes into separate server instances. Both namespaces are reachable on the same local development listener. Prefixes alone do not enforce the proposed network isolation. Keep the development server bound to 127.0.0.1 and do not expose staff routes publicly.

The verified local app connects as `pupspot_runtime`, a dedicated PostgreSQL login with no SUPERUSER, CREATEDB or CREATEROLE attributes. It currently has shared table CRUD privileges, schema USAGE and sequence access. These are the actual local permissions, not a claim that the intended per-role split is implemented. Its generated password is stored only in the ignored local .env.

A public-role/admin-role database split is still a deployment task. It must include separate connections/listeners or other enforced routing restrictions, object-specific grants, PUBLIC access review and positive/negative tests. No account or schema change is introduced by this documentation.

## Database inventory

`grp05_lostandfounddb` uses the public schema and five tables: categories, items, lost_reports, claims and potential_matches. SERIAL primary keys use sequences. Reports and claims contain contact details; their administrative retrieval responses must remain local/private. The database owner and generated credentials must never be placed in the class tracker.

## Course verification checklist

On each other group's local project copy, map its actual workflows to roles; verify CONNECT, schema USAGE, table/view grants, sequence grants, role membership, PUBLIC grants and default privileges. Test both allowed and denied actions using the relevant login; record the SQL, expected result, actual result and evidence. Do not record successful cross-group completion before running those tests on that group's actual database.

The instructor's Activities 4-6 apply to other groups' project copies. Local PUP-SPOT rehearsal and this intended-role document do not substitute for those required cross-group tests.
