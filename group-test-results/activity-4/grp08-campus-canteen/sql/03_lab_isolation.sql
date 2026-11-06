\set ON_ERROR_STOP on
-- ONLY the new dedicated G08 lab cluster. This changes all its databases.
-- Do not run on a shared/service cluster or other groups' environments.
DO $$ BEGIN
    IF current_setting('port') <> '55408'
       OR EXISTS (SELECT 1 FROM pg_database WHERE datname NOT IN
          ('postgres','template0','template1','canteen_g05_activity4','canteen_unrelated_lab'))
       OR NOT EXISTS (SELECT 1 FROM pg_database WHERE datname='canteen_g05_activity4') THEN
        RAISE EXCEPTION 'Expected only the dedicated G08 evaluation databases on port 55408';
    END IF;
END $$;
SELECT format('REVOKE ALL ON DATABASE %I FROM PUBLIC', datname)
FROM pg_database WHERE datallowconn \gexec
GRANT CONNECT ON DATABASE canteen_g05_activity4 TO canteen_admin, canteen_app_grp, canteen_readonly_grp;
