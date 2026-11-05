-- ============================================================
-- LOST & FOUND DEMONSTRATION DATA
-- PostgreSQL | grp05_lostandfounddb
--
-- Run this AFTER the database schema script.
-- This script is safe to run more than once: it removes only its
-- own DEMO records, then recreates them.
--
-- The potential_matches rows below are pre-seeded examples so
-- the public tracking page and admin review page can demonstrate
-- matching immediately. They do NOT trigger SMS/email because
-- this script writes directly to the database.
--
-- No image rows are inserted. Image records must point to files
-- that actually exist in the application's storage directory.
-- ============================================================

BEGIN;

-- Ensure the standard categories exist (without duplicating them).
INSERT INTO categories (name)
SELECT seed.name
FROM (VALUES
    ('IDs and Documents'),
    ('Wallets and Pouches'),
    ('Phones and Gadgets'),
    ('Chargers, Cables and Accessories'),
    ('Keys and Keychains'),
    ('Bags'),
    ('Books and School Supplies'),
    ('Clothing and Wearables'),
    ('Umbrellas'),
    ('Bottles and Food Containers'),
    ('Others')
) AS seed(name)
WHERE NOT EXISTS (
    SELECT 1 FROM categories existing WHERE existing.name = seed.name
);

-- Remove previous run's demo data only.
DELETE FROM claims
WHERE claim_code LIKE 'DEMO-CLM-%';

DELETE FROM lost_reports
WHERE report_code LIKE 'DEMO-LR-%';

DELETE FROM items
WHERE title LIKE '[DEMO] %';

-- ------------------------------------------------------------
-- 1. FOUND ITEMS
-- Mix of categories, locations, dates, and item statuses.
-- ------------------------------------------------------------
INSERT INTO items (
    category_id, title, description, location_found,
    date_found, time_found, status
)
SELECT
    c.category_id,
    seed.title,
    seed.description,
    seed.location_found,
    seed.date_found,
    seed.time_found,
    seed.status
FROM (VALUES
    ('Wallets and Pouches', '[DEMO] Black leather wallet',
     'Black leather bifold wallet containing a student ID and several cards.',
     'Library', CURRENT_DATE - 2, TIME '10:15', 'unclaimed'),
    ('Bottles and Food Containers', '[DEMO] Blue Hydro Flask bottle',
     'Blue insulated stainless steel water bottle with a silver cap and small sticker.',
     'Computer Laboratory', CURRENT_DATE - 1, TIME '14:30', 'unclaimed'),
    ('Books and School Supplies', '[DEMO] Casio scientific calculator',
     'Black Casio scientific calculator, model FX-991ES Plus.',
     'Engineering Building', CURRENT_DATE - 3, TIME '09:20', 'unclaimed'),
    ('Bags', '[DEMO] Navy blue backpack',
     'Navy blue backpack with two main compartments and a small front pocket.',
     'Cafeteria', CURRENT_DATE - 1, TIME '12:05', 'claimed'),
    ('Keys and Keychains', '[DEMO] Set of three silver keys',
     'Three silver keys attached to a round blue keychain.',
     'Main Lobby', CURRENT_DATE - 4, TIME '16:40', 'unclaimed'),
    ('Umbrellas', '[DEMO] Foldable black umbrella',
     'Compact black folding umbrella with a curved handle.',
     'Library', CURRENT_DATE - 2, TIME '11:00', 'archived')
) AS seed(category_name, title, description, location_found, date_found, time_found, status)
JOIN categories c ON c.name = seed.category_name;

-- ------------------------------------------------------------
-- 2. LOST REPORTS
-- Several active reports have deliberately similar found items.
-- One resolved and one cancelled report demonstrate other states.
-- ------------------------------------------------------------
INSERT INTO lost_reports (
    report_code, category_id, title, description,
    location_lost, date_lost, time_lost,
    full_name, student_number, email, phone_number,
    contact_preference, status, created_at
)
SELECT
    seed.report_code,
    c.category_id,
    seed.title,
    seed.description,
    seed.location_lost,
    seed.date_lost,
    seed.time_lost,
    seed.full_name,
    seed.student_number,
    seed.email,
    seed.phone_number,
    seed.contact_preference,
    seed.status,
    CURRENT_TIMESTAMP - seed.created_offset
FROM (VALUES
    ('DEMO-LR-001', 'Wallets and Pouches',
     'Black wallet',
     'A black leather wallet with my school ID and bank cards inside.',
     'Library', CURRENT_DATE - 2, TIME '09:45',
     'Maria Santos', 'DEMO-2024-001', 'maria.demo@example.com', '09170000001',
     'email', 'active', INTERVAL '2 days'),
    ('DEMO-LR-002', 'Bottles and Food Containers',
     'Blue water bottle',
     'Blue insulated water bottle, silver lid, with a sticker on the side.',
     'Computer Laboratory', CURRENT_DATE - 1, TIME '13:00',
     'Juan Dela Cruz', 'DEMO-2024-002', 'juan.demo@example.com', '09170000002',
     'sms', 'active', INTERVAL '1 day'),
    ('DEMO-LR-003', 'Books and School Supplies',
     'Casio calculator',
     'Black Casio FX-991ES Plus scientific calculator.',
     'Engineering Building', CURRENT_DATE - 3, TIME '08:30',
     'Angela Reyes', 'DEMO-2024-003', 'angela.demo@example.com', '09170000003',
     'email', 'active', INTERVAL '3 days'),
    ('DEMO-LR-004', 'Bags',
     'Blue backpack',
     'Navy backpack with a front pocket. I left it around the cafeteria.',
     'Cafeteria', CURRENT_DATE - 1, TIME '11:30',
     'Miguel Garcia', 'DEMO-2024-004', 'miguel.demo@example.com', '09170000004',
     'sms', 'active', INTERVAL '1 day'),
    ('DEMO-LR-005', 'Keys and Keychains',
     'Keys with blue keychain',
     'Three silver keys attached to a small round blue keychain.',
     'Main Lobby', CURRENT_DATE - 4, TIME '15:00',
     'Sofia Lim', 'DEMO-2024-005', 'sofia.demo@example.com', '09170000005',
     'email', 'active', INTERVAL '4 days'),
    ('DEMO-LR-006', 'Umbrellas',
     'Black umbrella',
     'A small foldable black umbrella with a curved handle.',
     'Library', CURRENT_DATE - 2, TIME '10:00',
     'Paolo Cruz', 'DEMO-2024-006', 'paolo.demo@example.com', '09170000006',
     'email', 'resolved', INTERVAL '5 days'),
    ('DEMO-LR-007', 'Phones and Gadgets',
     'White wireless earbuds',
     'White wireless earbuds in a charging case.',
     'Student Lounge', CURRENT_DATE - 6, TIME '14:00',
     'Carla Mendoza', 'DEMO-2024-007', 'carla.demo@example.com', '09170000007',
     'sms', 'cancelled', INTERVAL '6 days')
) AS seed(
    report_code, category_name, title, description,
    location_lost, date_lost, time_lost,
    full_name, student_number, email, phone_number,
    contact_preference, status, created_offset
)
JOIN categories c ON c.name = seed.category_name;

-- ------------------------------------------------------------
-- 3. CLAIMS
-- Pending, approved, and rejected examples for the admin panel.
-- Approved claim corresponds to an item already marked claimed.
-- ------------------------------------------------------------
INSERT INTO claims (
    claim_code, item_id, full_name, student_number,
    email, phone_number, contact_preference, status, created_at
)
SELECT
    seed.claim_code,
    i.item_id,
    seed.full_name,
    seed.student_number,
    seed.email,
    seed.phone_number,
    seed.contact_preference,
    seed.status,
    CURRENT_TIMESTAMP - seed.created_offset
FROM (VALUES
    ('DEMO-CLM-001', '[DEMO] Black leather wallet',
     'Maria Santos', 'DEMO-2024-001', 'maria.demo@example.com', '09170000001',
     'email', 'pending', INTERVAL '2 hours'),
    ('DEMO-CLM-002', '[DEMO] Navy blue backpack',
     'Miguel Garcia', 'DEMO-2024-004', 'miguel.demo@example.com', '09170000004',
     'sms', 'approved', INTERVAL '1 day'),
    ('DEMO-CLM-003', '[DEMO] Casio scientific calculator',
     'Rafael Torres', 'DEMO-2024-008', 'rafael.demo@example.com', '09170000008',
     'email', 'rejected', INTERVAL '3 days')
) AS seed(
    claim_code, item_title, full_name, student_number,
    email, phone_number, contact_preference, status, created_offset
)
JOIN items i ON i.title = seed.item_title;

-- ------------------------------------------------------------
-- 4. POTENTIAL MATCHES
-- Scores are illustrative demo values (0-100), not generated by
-- the PHP matching service. Each report has one or more candidates.
-- ------------------------------------------------------------
INSERT INTO potential_matches (report_id, item_id, similarity_score)
SELECT r.report_id, i.item_id, seed.similarity_score
FROM (VALUES
    ('DEMO-LR-001', '[DEMO] Black leather wallet', 96.50),
    ('DEMO-LR-001', '[DEMO] Foldable black umbrella', 61.25),
    ('DEMO-LR-002', '[DEMO] Blue Hydro Flask bottle', 94.80),
    ('DEMO-LR-003', '[DEMO] Casio scientific calculator', 99.00),
    ('DEMO-LR-004', '[DEMO] Navy blue backpack', 91.40),
    ('DEMO-LR-005', '[DEMO] Set of three silver keys', 97.25)
) AS seed(report_code, item_title, similarity_score)
JOIN lost_reports r ON r.report_code = seed.report_code
JOIN items i ON i.title = seed.item_title;

COMMIT;

-- ------------------------------------------------------------
-- DEMO LOOKUP QUICK REFERENCE
-- Public tracking codes:
--   Lost reports: DEMO-LR-001 through DEMO-LR-007
--   Claims:       DEMO-CLM-001 through DEMO-CLM-003
--
-- Suggested walkthrough:
--   1. Track DEMO-LR-001 to show multiple potential matches.
--   2. Track DEMO-LR-003 to show a high-confidence match.
--   3. Track DEMO-LR-006 / DEMO-LR-007 to show resolved/cancelled.
--   4. Track DEMO-CLM-001 / 002 / 003 to show claim statuses.
--   5. Open the admin panel to review the demo reports, items,
--      claims, and their potential matches.
--
-- Note: DEMO-LR-006 and DEMO-LR-007 are not active, so they will
-- not appear as active public tracking submissions/match results.
-- ------------------------------------------------------------
