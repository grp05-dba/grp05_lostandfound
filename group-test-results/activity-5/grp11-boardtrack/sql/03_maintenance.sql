\set ON_ERROR_STOP on
DO $$ BEGIN IF current_database()<>'boardtrack_g05_activity4' OR current_setting('port')<>'55411' THEN RAISE EXCEPTION 'Wrong Activity 5 test database'; END IF; END $$;
SET lock_timeout='3s';
SET statement_timeout='30s';
SET ROLE boardtrack_owner_grp;
SELECT clock_timestamp() AS captured_at,session_user,current_user,current_database(),current_setting('server_version'),inet_server_addr(),inet_server_port();
-- Refresh planner estimates; approved Activity4 owner membership only.
ANALYZE VERBOSE public.property;
ANALYZE VERBOSE public.room;
ANALYZE VERBOSE public.tenant;
ANALYZE VERBOSE public.lease;
ANALYZE VERBOSE public.payment;
ANALYZE VERBOSE public.utility_bill;
-- Standalone ordinary VACUUM; disable tail truncation to avoid its stronger lock.
VACUUM (VERBOSE, ANALYZE, TRUNCATE FALSE) public.lease;
