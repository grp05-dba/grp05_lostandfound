# Potential matching API

The PHP service compares active lost reports with unclaimed found items. It scores title (60%), description (25%), location (10%), and category (5%). Matching runs after a lost report or found item is created; matching errors are logged without failing the original create request.

Apply `sql/migrations/002_unique_potential_match_pairs.sql` once to an existing database before deploying this branch. It removes duplicate report/item pairs and adds the unique index required for safe repeated matching.

Admin endpoints:

- `GET /api/admin/potential-matches` — list saved matches.
- `GET /api/admin/potential-matches/report/{reportId}` — matches for a lost report.
- `GET /api/admin/potential-matches/item/{itemId}` — matches for a found item.
- `POST /api/admin/potential-matches/generate` — rerun matching across active reports and unclaimed items; only new pairs are inserted.

The matcher currently uses PHP's built-in `similar_text` function because the repository's backend is native PHP and has no JavaScript runtime. Fuse.js is a JavaScript library and is handled separately by the client-side helper in issue #30.
