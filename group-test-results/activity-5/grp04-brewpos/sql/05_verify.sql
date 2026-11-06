-- Existing local BrewPOS database; run directly as brewpos_app.
-- Runtime is the only BrewPOS login found. Inspect within existing grants; no superuser fallback.
\set ON_ERROR_STOP on
\pset pager off
SELECT clock_timestamp() AS captured_at,session_user,current_user,current_database(),version();
SELECT relname,n_live_tup,n_dead_tup,n_mod_since_analyze,last_vacuum,last_analyze,vacuum_count,analyze_count FROM pg_stat_user_tables ORDER BY relname;
SELECT 'menu_category' AS table_name,count(*) AS rows FROM public.menu_category
UNION ALL SELECT 'menu_item' AS table_name,count(*) AS rows FROM public.menu_item
UNION ALL SELECT 'order_line_item' AS table_name,count(*) AS rows FROM public.order_line_item
UNION ALL SELECT 'order_ticket' AS table_name,count(*) AS rows FROM public.order_ticket
UNION ALL SELECT 'staff' AS table_name,count(*) AS rows FROM public.staff ORDER BY table_name;
