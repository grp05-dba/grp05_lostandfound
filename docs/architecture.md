# System architecture

PUP-SPOT uses native PHP, PostgreSQL and browser-side HTML/CSS/JavaScript. It does not use a PHP application framework.

## High-level structure

~~~text
Browser
  |-- Public UI: public/app.html + public/js/app.js + public/css/
  |       |-- public/index.php
  |       |-- PublicController
  |       |-- Public database connection (restricted role)
  |
  |-- Admin UI: admin/app.html + admin/js/admin.js + admin/css/
          |-- admin/index.php
          |-- AdminController
          |-- Admin database connection (broader application role)

Controllers -> Services -> Repositories -> PostgreSQL
                    |             |
                    |             +-> Image metadata
                    +-> TextBee / EmailJS integrations
                    +-> ImageService -> storage/
~~~

The public and admin APIs are separate entry points. The public API connects using the public database credentials; the admin API connects using the admin application credentials. Each interface has its own document root and API routes.

## Deployment model

The intended deployment uses two server roles:

- **Server A — Public API:** serves the student/guest interface and public API operations. It uses the restricted public database role.
- **Server B — Admin API:** serves the Campus Marshal/Admin interface and administrative API operations. It uses the broader admin application database role and is intended to be reachable only through the campus private network or equivalent network restrictions.

The public and admin code remain in the same repository and project folder. They are separate deployment entry points, not separate repositories.

For local development and demonstrations, both interfaces can be started from the same project folder using separate PHP server instances and ports:

- Public: 127.0.0.1:8000, document root public
- Admin: 127.0.0.1:8001, document root admin

This is a local simulation of the two-server deployment model. Running two ports on one machine does not create true network isolation or an air gap.

## Main folders

| Path | Responsibility |
| --- | --- |
| public/ | Public-facing page, styles, JavaScript and public API entry point |
| admin/ | Admin-facing page, styles, JavaScript and admin API entry point |
| src/controllers/ | Match HTTP methods/paths, call services and return JSON or image responses |
| src/services/ | Business rules for items, reports, claims, categories, search, matching, images and notifications |
| src/repositories/ | PDO queries and database persistence |
| src/entities/ | Item, lost-report and claim data objects |
| src/db/ | Read local INI-style environment configuration and create PDO connections |
| src/integrations/ | TextBee and EmailJS HTTP clients |
| src/utils/ | Request parsing and shared validation/response helpers |
| sql/ | Schema, necessary category data, sample role script and demonstration data |
| storage/ | Uploaded item, lost-report and claim image files |
| docs/ | Maintained project documentation |

## Request lifecycle

1. The browser loads the public or admin HTML page and its local JavaScript/CSS.
2. JavaScript sends requests to the corresponding API base path and server/port.
3. The matching PHP entry point loads the required source files and opens a PostgreSQL PDO connection using the role assigned to that interface.
4. The controller matches the HTTP method and URL path, parses request data and delegates work to a service.
5. Services validate input, coordinate repository operations, image storage, matching and notification calls.
6. Repositories execute prepared SQL statements. Services return results which the controller encodes as JSON. Image endpoints stream files using the MIME type recorded in the database.

The database role used by an API limits the database operations available to that interface. The application does not connect using the PostgreSQL postgres superuser.

## Data and image handling

The database stores item, report and claim details, potential-match scores and image metadata. Actual image bytes are stored under storage/items/, storage/lost-reports/ and storage/claims/. Database rows keep storage keys and MIME types; API responses expose image URLs rather than filesystem paths.

ImageService verifies uploaded files, restricts formats to JPEG/PNG/WebP, applies size/count limits and coordinates file operations with database transactions. Storage directories must be writable by the PHP process and must not be exposed as arbitrary user-controlled paths.

## Matching and notifications

PotentialMatchService compares newly created or relevantly updated items/reports against eligible records. It stores matches meeting the service threshold (60 or higher). When a new found item matches an active report, the service can notify the reporter through the contact method selected on the report. Notification delivery is external and depends on TextBee/EmailJS configuration.

The demonstration SQL script inserts illustrative potential-match rows directly. Those pre-seeded records are not evidence that the matching algorithm ran or that notifications were delivered.

## Administrative access and security

PUP-SPOT does not provide an Admin username/password login or individual account-based authorization. The intended security boundary for administrative functions is network isolation/restriction: the admin server should be accessible only through the campus private network or an equivalent trusted network boundary.

This design has a known limitation: a person who can reach the admin server through the permitted network may potentially access administrative functions. This is accepted for the current course project and should not be treated as a complete production security model. Keep the admin server off the public internet.

See [user roles](user-roles.md) for the access model, [setup](setup.md) for local configuration, and [database reference](database.md) for tables and database roles.
