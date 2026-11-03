-- A report/item pair should only be stored once.
-- Check and resolve existing duplicates before applying this migration.
CREATE UNIQUE INDEX IF NOT EXISTS unique_report_item_match
    ON potential_matches (report_id, item_id);
