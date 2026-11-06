\set ON_ERROR_STOP on
-- Run as provisioning administrator in grp00_habalgodb after importing upstream
-- schema.sql and "sample data.sql" with SET ROLE habalgo_owner_grp.
ALTER SCHEMA habalgo OWNER TO habalgo_owner_grp;
REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA habalgo FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA habalgo FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA habalgo FROM PUBLIC;
GRANT USAGE ON SCHEMA habalgo TO habalgo_runtime_grp, habalgo_readonly_grp;
GRANT SELECT ON habalgo.customer, habalgo.driver, habalgo.vehicle,
    habalgo.driver_vehicle, habalgo.location, habalgo.booking,
    habalgo.payment, habalgo.rating_feedback
    TO habalgo_runtime_grp, habalgo_readonly_grp;
GRANT INSERT, UPDATE, DELETE ON habalgo.customer, habalgo.vehicle,
    habalgo.driver_vehicle, habalgo.booking, habalgo.payment, habalgo.rating_feedback
    TO habalgo_runtime_grp;
GRANT INSERT ON habalgo.location TO habalgo_runtime_grp;
GRANT USAGE ON SEQUENCE habalgo.customer_customer_id_seq,
    habalgo.vehicle_vehicle_id_seq, habalgo.location_location_id_seq,
    habalgo.booking_booking_id_seq, habalgo.payment_payment_id_seq,
    habalgo.rating_feedback_rating_id_seq TO habalgo_runtime_grp;
ALTER DEFAULT PRIVILEGES FOR ROLE habalgo_owner_grp IN SCHEMA habalgo REVOKE ALL ON TABLES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE habalgo_owner_grp IN SCHEMA habalgo REVOKE ALL ON SEQUENCES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE habalgo_owner_grp REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;
ALTER ROLE habalgo_app IN DATABASE grp00_habalgodb SET search_path = habalgo;
ALTER ROLE habalgo_app IN DATABASE grp00_habalgodb SET statement_timeout = '30s';
ALTER ROLE habalgo_app IN DATABASE grp00_habalgodb SET lock_timeout = '10s';
