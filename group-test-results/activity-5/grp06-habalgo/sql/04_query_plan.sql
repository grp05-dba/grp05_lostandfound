-- Exact SELECT from api.php options endpoint, driver dropdown.
-- c523913b6ffa57dae754a7fb6e4d6ffed4ac7070. Run directly as habalgo_app_user.
-- Only the SELECT runs; no PHP/API mutation or personal result values are captured.
\set ON_ERROR_STOP on
\pset pager off
SELECT clock_timestamp() AS captured_at,session_user,current_user,current_database();
BEGIN READ ONLY;
SET LOCAL statement_timeout='30s';
SET LOCAL search_path=habalgo,pg_catalog;
EXPLAIN SELECT driver_id,name FROM driver ORDER BY name;
EXPLAIN (ANALYZE, BUFFERS) SELECT driver_id,name FROM driver ORDER BY name;
ROLLBACK;
