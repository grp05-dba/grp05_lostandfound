# System architecture

Reviewed against `main` revision `9a803d2` (November 5, 2026). PUP-SPOT uses native PHP, PostgreSQL and browser-side HTML/CSS/JavaScript. It does not use a PHP application framework.

## High-level structure

```text
Browser
  |-- Public UI: public/app.html + public/js/app.js + public/css/
  |       |-- public/index.php
  |       |-- PublicController
  |
  |-- Admin UI: admin/app.html + admin/js/admin.js + admin/css/
          |-- admin/index.php
          |-- AdminController

Controllers -> Services -> Repositories -> PostgreSQL
                    |             |
                    |             +-> Image metadata
                    +-> TextBee / EmailJS integrations
                    +-> ImageService -> storage/
```

The public PHP development server is normally started on port 8000 with `-t public`. The admin server is started separately on port 8001 with `-t admin`. Each folder contains an `app.html` frontend and an `index.php` API entry point.

## Main folders

| Path | Responsibility |
| --- | --- |
| `public/` | Public-facing page, styles, JavaScript and public API entry point |
| `admin/` | Admin-facing page, styles, JavaScript and admin API entry point |
| `src/controllers/` | Match HTTP methods/paths, call services and return JSON or image responses |
| `src/services/` | Business rules for items, reports, claims, categories, search, matching, images and notifications |
| `src/repositories/` | PDO queries and database persistence |
| `src/entities/` | Item, lost-report and claim data objects |
| `src/db/` | Read local INI-style environment configuration and create PDO connections |
| `src/integrations/` | TextBee and EmailJS HTTP clients |
| `src/utils/` | Request parsing and shared validation/response helpers |
| `sql/` | Schema, necessary category data, sample role script and demonstration data |
| `storage/` | Uploaded item, lost-report and claim image files |
| `docs/` | Maintained project documentation |

## Request lifecycle

1. The browser loads the public or admin HTML page and its local JavaScript/CSS.
2. JavaScript sends requests to the corresponding API base path and port.
3. The matching PHP entry point loads the required source files and opens a PostgreSQL PDO connection.
4. The controller matches the HTTP method and URL path, parses request data and delegates work to a service.
5. Services validate input, coordinate repository operations, image storage, matching and notification calls.
6. Repositories execute prepared SQL statements. Services return results which the controller encodes as JSON. Image endpoints stream files using the MIME type recorded in the database.

The entry points catch PDO connection errors and return HTTP 500 with a generic JSON message. PDO errors during controller handling are logged server-side and return a generic HTTP 500 JSON response.

## Data and image handling

The database stores item, report and claim details, potential-match scores and image metadata. Actual image bytes are stored under `storage/items/`, `storage/lost-reports/` and `storage/claims/`. Database rows keep storage keys and MIME types; API responses expose image URLs rather than filesystem paths.

ImageService verifies uploaded files, restricts formats to JPEG/PNG/WebP, applies size/count limits and coordinates file operations with database transactions. Storage directories must be writable by the PHP process and must not be exposed as arbitrary user-controlled paths.

## Matching and notifications

PotentialMatchService compares newly created or relevantly updated items/reports against eligible records. It stores matches meeting the service threshold (60 or higher). When a new found item matches an active report, the service can notify the reporter through the contact method selected on the report. Notification delivery is external and depends on TextBee/EmailJS configuration.

The demonstration SQL script inserts illustrative potential-match rows directly. Those pre-seeded records are not evidence that the matching algorithm ran or that notifications were delivered.

## Deployment and security notes

The public and admin interfaces use separate entry points and ports, but the current public entry point calls `getAdminConnection()`. The public DB credentials defined in the environment template are therefore not evidence of an enforced public database role. No user login/authorization middleware is present in the reviewed controllers. Deploy the admin interface behind appropriate network access controls and do not expose it publicly as an authenticated staff system.

For concrete paths and methods, see [API reference](api.md). For database fields and constraints, see [database reference](database.md).
