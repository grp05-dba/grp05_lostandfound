# Implemented API reference

Source revision: `17dfae5`. Development base URL: `http://127.0.0.1:8000`. Current database routes accept GET requests and need no request body.

## Routes

| Method | Path | Successful response |
| --- | --- | --- |
| GET | /api/admin/test | Health message object |
| GET | /api/admin/items | Array of all found items |
| GET | /api/admin/items/{id} | One item object |
| GET | /api/admin/lost-reports | Array of all lost reports |
| GET | /api/admin/lost-reports/{id} | One lost report object |
| GET | /api/admin/claims | Array of all claims |
| GET | /api/admin/claims/{id} | One claim object |
| GET | /api/public/categories | Array of all categories |
| GET | /api/public/categories/{id} | One category object |
| GET | /api/admin/sms/stats | TextBee gateway statistics wrapper |
| GET | /api/admin/sms/devices | TextBee gateway devices wrapper |

Lists return `[]` when empty. Queries have no ORDER BY, pagination or filtering. Do not depend on a particular record order. Repositories return associative arrays using the table columns in [the data reference](database.md).

For example, a category lookup can return:

```json
{"category_id": 1, "name": "test-category"}
```

Values come from the actual database; sample dates and timestamps are generated when the sample script runs.

## Missing records and routes

| Case | HTTP status | JSON body |
| --- | --- | --- |
| Item ID not found | 404 | `{"message":"No item found."}` |
| Report ID not found | 404 | `{"message":"No report found."}` |
| Claim ID not found | 404 | `{"message":"No claim found."}` |
| Category ID not found | 404 | `{"error":"Category not found"}` |
| Unknown admin route / unsupported method there | 404 | `{"error":"Admin endpoint not found"}` |
| Unknown public route / unsupported method there | 404 | `{"error":"Public endpoint not found"}` |
| Unknown namespace | 404 | `{"error":"Endpoint not found"}` |

Current controllers return 404 for unsupported methods rather than 405. No POST, PATCH or DELETE handler is present in the reviewed controllers.

## IDs and paths

Controllers use `str_starts_with`, remove the resource prefix and cast the remainder to an integer before calling service methods that accept `int $id`. This follows the existing category implementation and the lead's PR review decision.

This is coercion rather than strict validation. For a seeded ID 1, `/items/1abc`, `/items/1.5` and `/items/1/extra` all resolve as ID 1. Nonnumeric text converts to 0 and normally produces the resource's missing-record 404. There is no separate positive-integer 400 check.

`public/index.php` passes the full REQUEST_URI into routing. Collection paths containing a query string do not match the exact list routes; query parameters are not implemented. Detail paths may have their suffix coerced to an integer. Oversized IDs and database failures are not covered by a consistent JSON error contract.

## Gateway wrappers

The two SMS routes call TextBee GET operations; they do not send SMS. The response object contains:

- `success`: whether the upstream status is 2xx.
- `status`: upstream HTTP status, or 0 on a connection failure.
- `response`: decoded JSON or raw upstream body when a response exists.
- `message`: the connection-failure explanation when no response exists.

The wrapper does not set the API's HTTP response status to the upstream status. A local HTTP 200 therefore does not prove the gateway request succeeded; inspect `success` and `status`.

EmailJSClient has a sendEmail method, but no reviewed controller route calls it. No email-sending endpoint, automatic notification workflow or real delivery result is documented as working.

## Proposed database error contract - not yet merged

[PR #25](https://github.com/grp05-dba/grp05_lostandfound/pull/25) proposes HTTP 500 JSON responses for connection/query PDO exceptions instead of the current plain-text termination or uncaught exception output. It does not change integer coercion. See [the repository review](repository-review.md) for the reproduction and validation; this proposal is not main's current error contract until merged.

## Access and verification

Administrative claim/report objects include contact information. The admin prefix is a routing convention, not an authorization boundary. There is no login middleware or enforced separate listener in this entry point; keep local demonstrations private. See [roles](user-roles.md).

Use [setup](setup.md) before making read-only requests. Local verification details and their limits are in [development history](development-history.md). Never infer completed create/update workflows from successful retrieval tests.
