\set ON_ERROR_STOP on
-- Target database: canteen_g05_activity4. Provisioning administrator only.
BEGIN;
DO $$ BEGIN
    IF current_database() <> 'canteen_g05_activity4' THEN
        RAISE EXCEPTION 'Connect to the dedicated canteen_g05_activity4 lab database';
    END IF;
END $$;
REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC, canteen_app, canteen_readonly, canteen_app_grp, canteen_readonly_grp;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC, canteen_app, canteen_readonly, canteen_app_grp, canteen_readonly_grp;
REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO canteen_app_grp, canteen_readonly_grp;
GRANT USAGE, CREATE ON SCHEMA public TO canteen_owner_grp;
GRANT SELECT, INSERT ON student, order_item TO canteen_app_grp;
GRANT SELECT, INSERT, UPDATE ON vendor, customer_order, queue_entry, notification TO canteen_app_grp;
GRANT SELECT, INSERT, UPDATE, DELETE ON menu_item TO canteen_app_grp;
GRANT USAGE ON SEQUENCE student_student_id_seq, vendor_vendor_id_seq,
    menu_item_item_id_seq, customer_order_order_id_seq, order_item_order_item_id_seq,
    queue_entry_queue_id_seq, notification_notification_id_seq TO canteen_app_grp;
GRANT SELECT (vendor_id, vendor_name) ON vendor TO canteen_readonly_grp;
GRANT SELECT (item_id, vendor_id, item_name, price, is_available) ON menu_item TO canteen_readonly_grp;
GRANT SELECT (order_id, vendor_id, order_date, status) ON customer_order TO canteen_readonly_grp;
GRANT SELECT (order_id, item_id, quantity, price_at_order) ON order_item TO canteen_readonly_grp;
-- New objects require a migration-specific grant review. No automatic runtime CRUD.
ALTER DEFAULT PRIVILEGES FOR ROLE canteen_owner_grp REVOKE ALL ON TABLES FROM PUBLIC, canteen_app_grp, canteen_readonly_grp;
ALTER DEFAULT PRIVILEGES FOR ROLE canteen_owner_grp REVOKE ALL ON SEQUENCES FROM PUBLIC, canteen_app_grp, canteen_readonly_grp;
ALTER DEFAULT PRIVILEGES FOR ROLE canteen_owner_grp REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE canteen_owner_grp IN SCHEMA public REVOKE ALL ON TABLES FROM PUBLIC, canteen_app_grp, canteen_readonly_grp;
ALTER DEFAULT PRIVILEGES FOR ROLE canteen_owner_grp IN SCHEMA public REVOKE ALL ON SEQUENCES FROM PUBLIC, canteen_app_grp, canteen_readonly_grp;
-- Also cover direct creations by the maintenance login, which must SET ROLE owner.
ALTER DEFAULT PRIVILEGES FOR ROLE canteen_admin REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;
COMMIT;
