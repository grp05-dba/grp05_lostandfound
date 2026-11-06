\set ON_ERROR_STOP on
-- Run ONLY after snapshot verification, in g05_a6_g08_restore.
SET ROLE canteen_owner_grp;
BEGIN;
DO $$ BEGIN
 IF current_database()<>'g05_a6_g08_restore' OR current_setting('port')<>'55408' THEN RAISE EXCEPTION 'Wrong disposable recovery target'; END IF;
 IF (SELECT count(*) FROM public.menu_item WHERE item_name='G05-A6-RECOVER-08')<>1 THEN RAISE EXCEPTION 'Expected one clearly identified disposable fixture'; END IF;
END $$;
DELETE FROM public.menu_item WHERE item_name='G05-A6-RECOVER-08' RETURNING item_id,item_name;
COMMIT;
