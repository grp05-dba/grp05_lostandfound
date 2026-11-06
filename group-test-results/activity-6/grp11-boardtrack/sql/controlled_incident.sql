\set ON_ERROR_STOP on
-- Run ONLY after snapshot verification, in g05_a6_g11_restore.
SET ROLE boardtrack_owner_grp;
BEGIN;
DO $$ BEGIN
 IF current_database()<>'g05_a6_g11_restore' OR current_setting('port')<>'55411' THEN RAISE EXCEPTION 'Wrong disposable recovery target'; END IF;
 IF (SELECT count(*) FROM public.property WHERE property_name='G05-A6-RECOVER-11')<>1 THEN RAISE EXCEPTION 'Expected one clearly identified disposable fixture'; END IF;
END $$;
DELETE FROM public.property WHERE property_name='G05-A6-RECOVER-11' RETURNING property_id,property_name;
COMMIT;
