SELECT * FROM items;
SELECT * FROM claims;
SELECT * FROM categories;
SELECT * FROM potential_matches;
SELECT * FROM lost_reports;

-- use to reset a table:
TRUNCATE TABLE claims RESTART IDENTITY CASCADE;

--insert queries:
INSERT INTO categories (name)
VALUES ('test-category');

INSERT INTO items (category_id, title, description, location_found, date_found, time_found)
VALUES (1, 'test-item', 'this is just a test item', 'found near testing site', CURRENT_DATE, LOCALTIME); 

INSERT INTO claims ( claim_code, item_id, full_name, student_number, email, phone_number, created_at)
VALUES ('CLM-00001', 1, 'Juan Dela Cruz', '2024-00001', 'juan@example.com', '09171234567', CURRENT_TIMESTAMP);

INSERT INTO lost_reports (
    report_code,
    category_id,
    title,
    description,
    location_lost,
    date_lost,
    time_lost,
    full_name,
    student_number,
    email,
    phone_number,
    created_at
)
VALUES (
    'LR-00001',
    1,
    'Black Wallet',
    'A black leather wallet containing a school ID.',
    'Near the library',
    CURRENT_DATE,
    LOCALTIME,
    'Maria Santos',
    '2024-00002',
    'maria@example.com',
    '09181234567',
    CURRENT_TIMESTAMP
);

INSERT INTO potential_matches (report_id, item_id)
VALUES (1,1);