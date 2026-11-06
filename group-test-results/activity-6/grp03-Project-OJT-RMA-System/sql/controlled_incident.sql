\set ON_ERROR_STOP on
-- Run ONLY after snapshot verification, in g05_a6_g03_restore.
SET ROLE grp03_ojt_admin_grp;
BEGIN;
DO $$ BEGIN
 IF current_database()<>'g05_a6_g03_restore' OR current_setting('port')<>'55403' THEN RAISE EXCEPTION 'Wrong disposable recovery target'; END IF;
 IF (SELECT count(*) FROM public.companies WHERE company_name='G05-A6-RECOVER-03')<>1 THEN RAISE EXCEPTION 'Expected one clearly identified disposable fixture'; END IF;
END $$;
DELETE FROM public.companies WHERE company_name='G05-A6-RECOVER-03' RETURNING company_id,company_name;
COMMIT;
