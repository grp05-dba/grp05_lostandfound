# Photo uploads

Photos are stored in PostgreSQL as `BYTEA` records in `item_photos`, `lost_report_photos`, and `claim_photos`. Each record can have up to five JPEG, PNG, or WebP images; each file is limited to 5 MB.

Apply `sql/migrations/004_add_entity_photos.sql` after the base schema. Upload photos as multipart form data using the `photos` field (one or multiple files):

- `POST /api/admin/items/{itemId}/photos`
- `POST /api/public/lost-reports/{reportId}/photos`
- `POST /api/public/claims/{claimId}/photos`

Use `GET` on the same paths to list photo metadata. Photo bytes are not included in list responses; retrieve an image with `GET /api/{admin|public}/{items|lost-reports|claims}/{recordId}/photos/{photoId}` using the matching record route above. Database-backed storage means database backups also contain uploaded image data.

For local PHP development, configure `upload_max_filesize` to at least `5M` and `post_max_size` to at least `26M` so a request containing five maximum-size images can reach the application.
