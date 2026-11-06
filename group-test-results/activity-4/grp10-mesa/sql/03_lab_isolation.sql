\set ON_ERROR_STOP on
-- Lab-wide isolation. Never use on a shared cluster. Checks are mandatory.
DO $$ BEGIN
 IF current_setting('port')<>'55410' OR NOT EXISTS(SELECT 1 FROM pg_database WHERE datname='mesa_g05_activity4')
 OR EXISTS(SELECT 1 FROM pg_database WHERE datname NOT IN('postgres','template0','template1','mesa_g05_activity4','rors_unrelated_lab'))
 THEN RAISE EXCEPTION 'Not the dedicated G10 lab cluster'; END IF;
END $$;
SELECT format('REVOKE ALL ON DATABASE %I FROM PUBLIC',datname) FROM pg_database WHERE datallowconn \gexec
GRANT CONNECT ON DATABASE mesa_g05_activity4 TO rors_dba,rors_runtime_grp,rors_readonly_grp;
