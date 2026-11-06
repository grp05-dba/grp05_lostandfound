\set ON_ERROR_STOP on
DO $$ BEGIN IF current_database()<>'mesa_g05_activity4' OR current_setting('port')<>'55410' THEN RAISE EXCEPTION 'Wrong Activity 5 test database'; END IF; END $$;
SET lock_timeout='3s';
SET statement_timeout='30s';
SET ROLE rors_owner_grp;
SELECT clock_timestamp() AS captured_at,session_user,current_user,current_database(),current_setting('server_version'),inet_server_addr(),inet_server_port();
-- Refresh planner estimates; approved Activity4 owner membership only.
ANALYZE VERBOSE public.menu_item;
-- Standalone ordinary VACUUM; disable tail truncation to avoid its stronger lock.
VACUUM (VERBOSE, ANALYZE, TRUNCATE FALSE) public.menu_item;
