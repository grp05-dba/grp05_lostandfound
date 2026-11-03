CREATE TABLE IF NOT EXISTS item_photos (
    photo_id SERIAL PRIMARY KEY,
    item_id INT NOT NULL REFERENCES items(item_id) ON DELETE CASCADE,
    file_name VARCHAR(255) NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    photo_data BYTEA NOT NULL,
    uploaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS lost_report_photos (
    photo_id SERIAL PRIMARY KEY,
    report_id INT NOT NULL REFERENCES lost_reports(report_id) ON DELETE CASCADE,
    file_name VARCHAR(255) NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    photo_data BYTEA NOT NULL,
    uploaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS claim_photos (
    photo_id SERIAL PRIMARY KEY,
    claim_id INT NOT NULL REFERENCES claims(claim_id) ON DELETE CASCADE,
    file_name VARCHAR(255) NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    photo_data BYTEA NOT NULL,
    uploaded_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
