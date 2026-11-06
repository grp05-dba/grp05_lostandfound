\set ON_ERROR_STOP on
DO $$ BEGIN IF current_database()<>'boardtrack_g05_activity4' OR current_setting('port')<>'55411' THEN RAISE EXCEPTION 'Wrong Activity 5 test database'; END IF; END $$;
BEGIN READ ONLY;
EXPLAIN SELECT lease_id, tenant_id, tenant, property_name, room_number, start_date, end_date, monthly_rent, status, total_paid, utilities_billed FROM v_lease_summary ORDER BY 1;
EXPLAIN (ANALYZE,BUFFERS) SELECT lease_id, tenant_id, tenant, property_name, room_number, start_date, end_date, monthly_rent, status, total_paid, utilities_billed FROM v_lease_summary ORDER BY 1;
ROLLBACK;
