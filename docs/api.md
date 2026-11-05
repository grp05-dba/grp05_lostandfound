# API reference

Reviewed against `main` revision `9a803d2` (November 5, 2026). The API is implemented in `src/controllers/publicController.php` and `src/controllers/adminController.php`, with business logic in `src/services/`.

Local base URLs:

- Public interface and API: `http://127.0.0.1:8000`
- Admin interface and API: `http://127.0.0.1:8001`

All API responses are JSON unless an image endpoint successfully streams an image file. For multipart requests, send form fields and image files using the `images` field name.

## Public API

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/api/public/items` | List unclaimed found items |
| GET | `/api/public/items/search` | Search/filter found items using query parameters |
| GET | `/api/public/items/images/{imageId}` | Retrieve an item image |
| GET | `/api/public/lost-reports/images/{imageId}` | Retrieve a lost-report image |
| GET | `/api/public/categories` | List categories |
| GET | `/api/public/categories/{id}` | Retrieve a category |
| POST | `/api/public/lost-reports/add` | Submit a lost-item report, optionally with images |
| POST | `/api/public/lost-reports/view` | Look up a report using `report_code` |
| POST | `/api/public/lost-reports/cancel` | Request cancellation using `report_code` |
| GET | `/api/public/lost-reports/matches/{reportCode}` | Retrieve potential matches for a report |
| DELETE | `/api/public/lost-reports/matches/{reportCode}/{matchId}` | Remove a potential match from a report |
| POST | `/api/public/claims/add` | Submit a claim, optionally with images |
| POST | `/api/public/claims/view` | Look up a claim using `claim_code` |

The report and claim tracking endpoints use POST request bodies containing the relevant reference code. The controller reads JSON request bodies for these lookups. Report and claim creation use `RequestUtils::getRequestData()` and may receive uploaded files in `$_FILES['images']`.

## Admin API

| Method | Path | Purpose |
| --- | --- | --- |
| GET | `/api/admin/test` | Check that the admin API can respond |
| GET | `/api/admin/items` | List all found items |
| GET | `/api/admin/items/{id}` | Retrieve one item |
| POST | `/api/admin/items/add` | Create an item with optional images |
| PATCH | `/api/admin/items/update/{id}` | Update item fields |
| POST | `/api/admin/items/{id}/images` | Add images to an item |
| DELETE | `/api/admin/items/{id}/images/{imageId}` | Delete an item image |
| GET | `/api/admin/lost-reports` | List lost reports |
| GET | `/api/admin/lost-reports/{id}` | Retrieve one lost report |
| GET | `/api/admin/lost-reports/matches/{reportCode}` | Retrieve potential matches for a report |
| PATCH | `/api/admin/lost-reports/update/{id}` | Update a lost report |
| GET | `/api/admin/claims` | List claims |
| GET | `/api/admin/claims/{id}` | Retrieve one claim |
| PATCH | `/api/admin/claims/update/{id}` | Update a claim |
| GET | `/api/admin/items/images/{imageId}` | Retrieve an item image |
| GET | `/api/admin/lost-reports/images/{imageId}` | Retrieve a lost-report image |
| GET | `/api/admin/claims/images/{imageId}` | Retrieve a claim image |
| GET | `/api/admin/categories` | List categories |
| GET | `/api/admin/categories/{id}` | Retrieve a category |
| GET | `/api/admin/sms/stats` | Retrieve TextBee gateway statistics |
| GET | `/api/admin/sms/devices` | Retrieve TextBee gateway devices |

## Request and response behavior

- Controllers remove query strings before matching route paths. The public item-search route parses its query string as filters.
- Creation and update services validate required/general fields, date/time values, category references and supported status values where applicable. Validation failures return an error message and an HTTP error status.
- Missing records generally return a JSON message and HTTP 404. Exact message text varies by service.
- Item/report/claim creation can save image files and their database metadata as part of a transaction. If saving fails, the service rolls back the database transaction and removes files saved during that operation.
- Image uploads accept JPEG, PNG and WebP. The service limits uploads to five images per record and 5 MB per image. Item image additions also check the total image count.
- Image responses set the stored MIME type, content length and `X-Content-Type-Options: nosniff`. Admin claim images use private cache headers; item/report images use the configured route behavior.
- Potential-match generation runs after an item or lost report is created and when relevant item/report fields are updated. The service stores candidates at a similarity score of 60 or higher. Removing a match requires both the report code and match ID.

## Notifications

TextBee and EmailJS clients are integrated through SMS/email services. The potential-match service selects the notification channel using the report's `contact_preference` and available contact detail. Claim creation also sends a notification through the selected channel. Actual delivery depends on valid credentials, provider availability and the provider response; code integration alone is not proof of delivery.

The SMS statistics and devices endpoints are gateway diagnostics. They do not send a message.

## Important access-control limitation

The repository has separate public and admin entry points and ports, but the current `public/index.php` calls `Connection::getAdminConnection()`, just like the admin entry point. Do not assume that `DB_PUBLIC_USER` is used for public requests or that separate URLs enforce authorization. There is no login/session authorization layer visible in these controllers. Restrict admin access at the deployment/network level until application authentication and least-privilege database access are implemented.

## Source files

- Controllers: `src/controllers/publicController.php`, `src/controllers/adminController.php`
- Services: `src/services/`
- Repositories: `src/repositories/`
- Request parsing/validation: `src/utils/requestUtils.php`
- Entrypoints: `public/index.php`, `admin/index.php`

Check the controller and service source before relying on an undocumented response field or exact validation rule.
