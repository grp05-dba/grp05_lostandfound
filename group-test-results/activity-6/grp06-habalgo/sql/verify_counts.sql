\set ON_ERROR_STOP on
DO $$ BEGIN IF current_setting('port')<>'55406' OR current_database() NOT IN('grp00_habalgodb','g05_a6_g06_restore','g05_a6_g06_snapshot','g05_a6_g06_recovered') THEN RAISE EXCEPTION 'Wrong Activity6 verification environment'; END IF; END $$;
SET ROLE habalgo_owner_grp;
SELECT 'booking' AS table_name,count(*) FROM habalgo.booking;
SELECT 'customer' AS table_name,count(*) FROM habalgo.customer;
SELECT 'driver' AS table_name,count(*) FROM habalgo.driver;
SELECT 'driver_vehicle' AS table_name,count(*) FROM habalgo.driver_vehicle;
SELECT 'location' AS table_name,count(*) FROM habalgo.location;
SELECT 'payment' AS table_name,count(*) FROM habalgo.payment;
SELECT 'rating_feedback' AS table_name,count(*) FROM habalgo.rating_feedback;
SELECT 'vehicle' AS table_name,count(*) FROM habalgo.vehicle;
