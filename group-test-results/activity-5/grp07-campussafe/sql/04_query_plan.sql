-- Exact Report::getStatistics category-count SELECT, used by public/admin/stats.php.
-- Source commit 3684b97cfa8b8c6624d039eda461551ade774701. Safe read; no personal values output.
\set ON_ERROR_STOP on
\pset pager off
SELECT clock_timestamp() AS captured_at,session_user,current_user,current_database();
BEGIN READ ONLY;
SET LOCAL search_path=public,pg_catalog;
SET LOCAL statement_timeout='30s';
EXPLAIN
SELECT c.category_name, COUNT(r.report_id) AS count
FROM hazard_category c
LEFT JOIN hazard_report r ON c.category_id = r.category_id
GROUP BY c.category_name
ORDER BY count DESC;
EXPLAIN (ANALYZE, BUFFERS)
SELECT c.category_name, COUNT(r.report_id) AS count
FROM hazard_category c
LEFT JOIN hazard_report r ON c.category_id = r.category_id
GROUP BY c.category_name
ORDER BY count DESC;
ROLLBACK;
