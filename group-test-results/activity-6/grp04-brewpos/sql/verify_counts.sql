\set ON_ERROR_STOP on
DO $$ BEGIN IF current_setting('port')<>'55404' OR current_database() NOT IN('grp_brewposdb','g05_a6_g04_restore','g05_a6_g04_snapshot','g05_a6_g04_recovered') THEN RAISE EXCEPTION 'Wrong Activity6 verification environment'; END IF; END $$;
SET ROLE brewpos_owner_grp;
SELECT 'menu_category' AS table_name,count(*) FROM public.menu_category;
SELECT 'menu_item' AS table_name,count(*) FROM public.menu_item;
SELECT 'order_line_item' AS table_name,count(*) FROM public.order_line_item;
SELECT 'order_ticket' AS table_name,count(*) FROM public.order_ticket;
SELECT 'staff' AS table_name,count(*) FROM public.staff;
