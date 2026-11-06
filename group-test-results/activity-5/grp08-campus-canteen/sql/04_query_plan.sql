\set ON_ERROR_STOP on
DO $$ BEGIN IF current_database()<>'canteen_g05_activity4' OR current_setting('port')<>'55408' THEN RAISE EXCEPTION 'Wrong Activity 5 test database'; END IF; END $$;
BEGIN READ ONLY;
EXPLAIN SELECT count(*) FILTER (WHERE o.status = 'completed'), count(*) FILTER (WHERE o.status = 'cancelled'), count(*) FROM customer_order o WHERE o.order_date >= TIMESTAMP '2026-10-08 00:00:00' AND o.order_date < TIMESTAMP '2026-11-07 00:00:00';
EXPLAIN (ANALYZE,BUFFERS) SELECT count(*) FILTER (WHERE o.status = 'completed'), count(*) FILTER (WHERE o.status = 'cancelled'), count(*) FROM customer_order o WHERE o.order_date >= TIMESTAMP '2026-10-08 00:00:00' AND o.order_date < TIMESTAMP '2026-11-07 00:00:00';
ROLLBACK;
