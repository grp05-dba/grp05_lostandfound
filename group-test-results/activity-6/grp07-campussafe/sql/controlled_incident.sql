\set ON_ERROR_STOP on
-- Run ONLY after snapshot verification, in g05_a6_g07_restore.
SET ROLE campussafe_owner_grp;
BEGIN;
DO $$ BEGIN
 IF current_database()<>'g05_a6_g07_restore' OR current_setting('port')<>'55407' THEN RAISE EXCEPTION 'Wrong disposable recovery target'; END IF;
 IF (SELECT count(*) FROM public.hazard_category WHERE category_name='G05-A6-RECOVER-07')<>1 THEN RAISE EXCEPTION 'Expected one clearly identified disposable fixture'; END IF;
END $$;
DELETE FROM public.hazard_category WHERE category_name='G05-A6-RECOVER-07' RETURNING category_id,category_name;
COMMIT;
