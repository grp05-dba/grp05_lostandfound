# Current API and setup verification

This describes code at `5fcbccdcbb23b2e980b82bd0785b0cffa179e556`. It records local observations on October 29, 2026; board status alone is not proof that an endpoint exists in `main`.

## Routes implemented in the checked revision

Use `http://127.0.0.1:8000` as the local base URL after starting the PHP development server. The server connects to PostgreSQL before dispatching every route.

| Method | Path | Observed response |
|---|---|---|
| GET | `/api/admin/test` | 200, `{"message":"its working! :D"}` |
| GET | `/api/admin/items` | 200, JSON array of item records |
| GET | `/api/public/categories` | 200, JSON array of category records |
| GET | `/api/public/categories/1` | 200, the seeded category object |
| GET | `/api/public/categories/999999` | 404, `{"error":"Category not found"}` with the supplied seed data |
| GET | `/api/admin/sms/stats` | Gateway result wrapper with `success`, `status`, and `response`; unavailable gateway returns `success:false`, `status:0`, and a message |
| GET | `/api/admin/sms/devices` | Gateway result wrapper with `success`, `status`, and `response` |

The SMS routes return local HTTP 200 even when the wrapper reports a gateway failure. Check the JSON `success` and `status` fields. They are read-only gateway-information endpoints; they do not implement message delivery.

## Results and limitations

The checked setup used PHP 8.5.10 with `pdo_pgsql`, `pgsql`, and `curl`, an isolated PostgreSQL 18.3 instance on local port 5433, a non-superuser application login, the unchanged schema script, and the supplied sample-data script. Local port 5433 is an environment choice, not a required project port. The application listens on port 8000.

- All 10 PHP source files passed syntax checks.
- The Postman v2.1 collection passed 14 assertions across seven requests using Newman. The separate broader verification exercised 16 cases, with 13 expected results and the three findings listed below.
- Each of the five tables contained its one supplied seed record. The application login has no SUPERUSER, CREATEDB, or CREATEROLE attribute.
- The health endpoint, seeded item list, category list, and category lookup returned the expected JSON.
- Missing/non-numeric category IDs, unknown routes, and unsupported methods returned JSON errors with HTTP 404. This records current behavior, not a requirement that all invalid input should use 404.
- TextBee wrapper success paths were tested against a temporary local stub. Connection-failure behavior was tested after the stub stopped. No real API key, real gateway account, EmailJS delivery, or SMS delivery was verified.
- No application feature was implemented or marked complete as part of this verification.

### Findings to address in separate changes

1. `POST /api/public/categories` returns 404. The category-creation card is marked Done, but the current public controller has no POST handler. If another route is intended, it needs to be implemented or documented.
2. `PATCH /api/public/categories/1` returns 404. The category-update card is marked Done, but the checked controller has no PATCH handler.
3. `GET /api/public/categories?limit=5` returns 404. Routing compares the complete request URI, including its query string, against the collection route. Parsing the path separately would permit query strings; that alone would not implement pagination.

The board's “My items” view had zero issues assigned to the testing account. No unrelated feature task was selected, reassigned, or closed.

## Try the database-backed endpoints

Import `pupspot.postman_collection.json` into Postman. Set the collection variables:

- `baseUrl`: normally `http://127.0.0.1:8000`
- `categoryId`: an existing category, normally `1` after fresh seed data
- `missingCategoryId`: an ID verified absent from your test database

The collection uses only GET requests. Run it against your local test environment. A passing run verifies the listed responses, not full CRUD functionality, access control, or external notifications.

## Seed script note

The supplied sample-data file includes a `TRUNCATE ... CASCADE` statement. Use it only when initializing a new disposable test database after reading the file. Do not rerun it over a database whose records you need to preserve.
