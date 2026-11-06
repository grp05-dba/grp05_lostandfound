\set ON_ERROR_STOP on
DO $$ BEGIN IF current_setting('port')<>'55410' OR current_database() NOT IN('mesa_g05_activity4','g05_a6_g10_restore','g05_a6_g10_snapshot','g05_a6_g10_recovered') THEN RAISE EXCEPTION 'Wrong Activity6 verification environment'; END IF; END $$;
SET ROLE rors_owner_grp;
SELECT 'customer' AS table_name,count(*) FROM public.customer;
SELECT 'staff' AS table_name,count(*) FROM public.staff;
SELECT 'menu_item' AS table_name,count(*) FROM public.menu_item;
SELECT 'restaurant_table' AS table_name,count(*) FROM public.restaurant_table;
SELECT 'orders' AS table_name,count(*) FROM public.orders;
SELECT 'order_item' AS table_name,count(*) FROM public.order_item;
SELECT 'reservation' AS table_name,count(*) FROM public.reservation;
SELECT 'payment' AS table_name,count(*) FROM public.payment;
