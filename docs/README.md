# PUP-SPOT project documentation

This folder documents the current PUP-SPOT campus Lost and Found system. It was reviewed against `main` revision `9a803d2` (November 5, 2026). The application is a PHP and PostgreSQL project with separate public and admin web interfaces.

## Documentation map

| Page | Contents |
| --- | --- |
| [Setup](setup.md) | Requirements, database initialization, environment configuration and local startup |
| [API reference](api.md) | Public and admin routes, request methods, uploads and current behavior |
| [Architecture](architecture.md) | Frontend/backend structure, request flow and service responsibilities |
| [Database](database.md) | Eight tables, constraints, image metadata and demo data |
| [User roles](user-roles.md) | Public/admin responsibilities and current access-control limitations |
| [Development history](development-history.md) | Recent implementation milestones and documentation baseline |
| [Repository review](repository-review.md) | Current implementation notes and items that still need verification |
| [Branch workflow](branch-workflow.md) | How to maintain and publish this documentation branch |

## Current system at a glance

- Public interface: found-item browsing and search, lost-report submission and tracking, claim submission and tracking, and potential-match viewing/removal.
- Admin interface: item, report and claim review; item creation and updates; report and claim updates; image management; and SMS gateway diagnostics.
- Backend: native PHP using PDO and PostgreSQL, organized into controllers, services, repositories, entities, integrations and request utilities.
- Images: JPEG, PNG and WebP uploads are validated and stored under `storage/`; image metadata is kept in PostgreSQL.
- Potential matching: the service compares newly submitted reports/items and stores candidates that meet its matching threshold. Notifications depend on TextBee/EmailJS configuration and provider availability.
- Local deployment: run the public interface on port 8000 and the admin interface on port 8001.

## Documentation scope

These pages describe behavior found in the repository, not a guarantee that every workflow has been tested in a live deployment. The public entry point currently obtains a database connection through `getAdminConnection()`; the separate public database credentials in the environment template are not used by that entry point. The admin URL is a separate interface, not a substitute for authentication or network access controls.

The root [README](../README.md) remains the quick-start guide. Keep secrets, real provider credentials, local `.env` files, uploaded user data and database dumps out of Git.

Update these pages whenever implementation changes affect routes, schema, setup or user-visible behavior. Record the exact source revision used for each review.
