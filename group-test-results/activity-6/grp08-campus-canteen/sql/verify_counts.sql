\set ON_ERROR_STOP on
DO $$ BEGIN IF current_setting('port')<>'55408' OR current_database() NOT IN('canteen_g05_activity4','g05_a6_g08_restore','g05_a6_g08_snapshot','g05_a6_g08_recovered') THEN RAISE EXCEPTION 'Wrong Activity6 verification environment'; END IF; END $$;
SET ROLE canteen_owner_grp;
SELECT 'student' AS table_name,count(*) FROM public.student;
SELECT 'vendor' AS table_name,count(*) FROM public.vendor;
SELECT 'menu_item' AS table_name,count(*) FROM public.menu_item;
SELECT 'customer_order' AS table_name,count(*) FROM public.customer_order;
SELECT 'order_item' AS table_name,count(*) FROM public.order_item;
SELECT 'queue_entry' AS table_name,count(*) FROM public.queue_entry;
SELECT 'notification' AS table_name,count(*) FROM public.notification;
