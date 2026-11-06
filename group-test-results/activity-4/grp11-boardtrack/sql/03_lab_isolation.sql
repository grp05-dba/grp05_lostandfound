\set ON_ERROR_STOP on
-- Lab-wide isolation. Never use on a shared cluster. Checks are mandatory.
DO $$ BEGIN
 IF current_setting('port')<>'55411' OR NOT EXISTS(SELECT 1 FROM pg_database WHERE datname='boardtrack_g05_activity4')
 OR EXISTS(SELECT 1 FROM pg_database WHERE datname NOT IN('postgres','template0','template1','boardtrack_g05_activity4','boardtrack_unrelated_lab'))
 THEN RAISE EXCEPTION 'Not the dedicated G11 lab cluster'; END IF;
END $$;
SELECT format('REVOKE ALL ON DATABASE %I FROM PUBLIC',datname) FROM pg_database WHERE datallowconn \gexec
GRANT CONNECT ON DATABASE boardtrack_g05_activity4 TO boardtrack_dba,boardtrack_runtime_grp,boardtrack_readonly_grp;
