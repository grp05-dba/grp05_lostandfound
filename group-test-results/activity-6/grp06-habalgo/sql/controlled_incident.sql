\set ON_ERROR_STOP on
-- Run ONLY after snapshot verification, in g05_a6_g06_restore.
SET ROLE habalgo_owner_grp;
BEGIN;
DO $$ BEGIN
 IF current_database()<>'g05_a6_g06_restore' OR current_setting('port')<>'55406' THEN RAISE EXCEPTION 'Wrong disposable recovery target'; END IF;
 IF (SELECT count(*) FROM habalgo.vehicle WHERE plate_no='G05-A6-RECOVER-06')<>1 THEN RAISE EXCEPTION 'Expected one clearly identified disposable fixture'; END IF;
END $$;
DELETE FROM habalgo.vehicle WHERE plate_no='G05-A6-RECOVER-06' RETURNING vehicle_id,plate_no;
COMMIT;
