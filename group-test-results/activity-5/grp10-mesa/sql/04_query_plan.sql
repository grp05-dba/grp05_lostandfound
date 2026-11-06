\set ON_ERROR_STOP on
DO $$ BEGIN IF current_database()<>'mesa_g05_activity4' OR current_setting('port')<>'55410' THEN RAISE EXCEPTION 'Wrong Activity 5 test database'; END IF; END $$;
BEGIN READ ONLY;
EXPLAIN SELECT menu_item_id, item_name, description, category, price FROM menu_item WHERE availability = true ORDER BY category, item_name;
EXPLAIN (ANALYZE,BUFFERS) SELECT menu_item_id, item_name, description, category, price FROM menu_item WHERE availability = true ORDER BY category, item_name;
ROLLBACK;
