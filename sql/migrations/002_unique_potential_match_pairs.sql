-- Keep the earliest row when older data contains duplicate report/item pairs.
DELETE FROM potential_matches older
USING potential_matches newer
WHERE older.report_id = newer.report_id
  AND older.item_id = newer.item_id
  AND older.match_id > newer.match_id;

-- A report/item pair should only be stored once.
CREATE UNIQUE INDEX IF NOT EXISTS unique_report_item_match
    ON potential_matches (report_id, item_id);
