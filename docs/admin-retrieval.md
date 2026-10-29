# Administrative record retrieval

Implements ready board issues #1, #4, #7, #11 and #13 using the existing Controller -> Service -> Repository -> PostgreSQL structure. The original proposal and database schema are unchanged.

| Method | Route | Response |
| --- | --- | --- |
| GET | /api/admin/lost-reports | Array of all reports, ordered by report_id; [] when empty |
| GET | /api/admin/lost-reports/{id} | Matching report object |
| GET | /api/admin/items/{id} | Matching item object |
| GET | /api/admin/claims | Array of all claims, ordered by claim_id; [] when empty |
| GET | /api/admin/claims/{id} | Matching claim object |

Missing records return HTTP 404 with `{"message":"No report found."}`, `{"message":"No item found."}` or `{"message":"No claim found."}`. IDs outside PostgreSQL's positive INTEGER range, non-integers and mixed text return HTTP 400. Extra path segments return 404. Requests return actual database fields and status values; claim status is `pending`, not the inconsistent `unclaimed` example in issue #11.

These routes expose contact details for administrative management. Keep the development server bound to localhost. There is no application login or separation of public/admin listeners in this change. A route prefix alone does not enforce network access restrictions. No public claim/report retrieval route is added.

## Verification

Import `tests/admin-retrieval.postman_collection.json` in Postman or run it using Newman against the local supplied seed data. The collection covers valid, missing, malformed, mixed, zero, negative, decimal and oversized IDs, extra path segments, list responses and public namespace rejection. It only sends GET requests.

Run `php tests/empty-retrieval.php` using your configured PHP installation and a disposable local database. It temporarily deletes rows inside a transaction, checks the services return empty JSON arrays and always rolls back; never point test scripts at a shared deployment.

Existing category creation/editing gaps and query-string handling remain separate findings. This change does not implement pending write operations, matching, notification delivery, or a frontend. Integration and issue closure remain subject to project-lead review.
