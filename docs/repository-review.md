# Repository review — November 5, 2026

Source baseline: `main` revision `9a803d2`. This review summarizes the current repository structure and identifies limitations that should remain visible in project documentation.

## Changes since the October 31 documentation baseline

The current main branch has advanced from the earlier retrieval-only API. The public/admin entry points now load separate interfaces and controllers. The source includes report and claim submission/tracking, item creation and updates, report/claim updates, image uploads and retrieval, potential-match generation and removal, and TextBee/EmailJS notification services. The schema has expanded from five tables to eight, adding similarity scores and three image-metadata tables.

The root README now documents separate local servers:

- Public: `php -S 127.0.0.1:8000 -t public`
- Admin: `php -S 127.0.0.1:8001 -t admin`

## Important implementation findings

### Public database connection

`src/db/db.php` defines `getAdminConnection()` and `getPublicConnection()`. However, both `public/index.php` and `admin/index.php` currently call `getAdminConnection()`. The public DB credentials in `.env.example` are not used by the public entry point. This should be corrected and verified before describing the application as enforcing separate public/admin database permissions.

### Admin access

The admin page and API are separated by document root and port, but the reviewed entry point/controllers do not show a login or session authorization layer. The separate admin URL is not authentication. Keep the admin server restricted to localhost or a trusted network until access control is implemented.

### Potential matches and notifications

PotentialMatchService generates candidates and stores scores at or above its 60-point threshold. The public API can list matches by report code and remove a match by report code plus match ID. Notification calls are made through TextBee/EmailJS services based on contact preference, but actual delivery requires working provider configuration and runtime testing.

The demo SQL script inserts sample potential matches directly with illustrative scores. These rows should not be presented as results calculated by the matching service.

### Image uploads

ImageService accepts JPEG, PNG and WebP uploads, limits each image to 5 MB and limits a record to five images. Image bytes are stored in `storage/`; the database stores metadata and storage keys. Backups must include both the database and corresponding storage files.

## Remaining items to verify or improve

- Switch the public entry point to the intended public database connection and verify least-privilege grants.
- Add and test an authentication/authorization boundary for admin routes before network exposure.
- Run end-to-end tests for report/claim submission, cancellation, item/report updates, image lifecycle, match refresh/removal and notification behavior.
- Verify TextBee and EmailJS delivery using approved test credentials and record provider responses.
- Confirm filesystem permissions, backup/restore procedures and cleanup behavior for image files.
- Keep the SQL schema, API reference and frontend request behavior synchronized as features change.

This review is based on source inspection, not a fresh runtime test. It does not certify production readiness or course/activity completion.
