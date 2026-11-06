\set ON_ERROR_STOP on
-- Run ONLY after snapshot verification, in g05_a6_g04_restore.
SET ROLE brewpos_owner_grp;
BEGIN;
DO $$ BEGIN
 IF current_database()<>'g05_a6_g04_restore' OR current_setting('port')<>'55404' THEN RAISE EXCEPTION 'Wrong disposable recovery target'; END IF;
 IF (SELECT count(*) FROM public.menu_category WHERE category_name='G05-A6-RECOVER-04')<>1 THEN RAISE EXCEPTION 'Expected one clearly identified disposable fixture'; END IF;
END $$;
DELETE FROM public.menu_category WHERE category_name='G05-A6-RECOVER-04' RETURNING category_id,category_name;
COMMIT;
