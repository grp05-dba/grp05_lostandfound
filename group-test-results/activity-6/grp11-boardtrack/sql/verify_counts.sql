\set ON_ERROR_STOP on
DO $$ BEGIN IF current_setting('port')<>'55411' OR current_database() NOT IN('boardtrack_g05_activity4','g05_a6_g11_restore','g05_a6_g11_snapshot','g05_a6_g11_recovered') THEN RAISE EXCEPTION 'Wrong Activity6 verification environment'; END IF; END $$;
SET ROLE boardtrack_owner_grp;
SELECT 'property' AS table_name,count(*) FROM public.property;
SELECT 'room' AS table_name,count(*) FROM public.room;
SELECT 'tenant' AS table_name,count(*) FROM public.tenant;
SELECT 'lease' AS table_name,count(*) FROM public.lease;
SELECT 'payment' AS table_name,count(*) FROM public.payment;
SELECT 'utility_bill' AS table_name,count(*) FROM public.utility_bill;
SELECT 'app_user' AS table_name,count(*) FROM public.app_user;
SELECT 'schema_migrations' AS table_name,count(*) FROM public.schema_migrations;
