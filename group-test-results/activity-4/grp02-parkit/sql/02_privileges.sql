\set ON_ERROR_STOP on
-- Connect as provisioning administrator to grp_parkitdb after importing upstream schema.sql.
-- The upstream plain dump explicitly assigns postgres ownership. Transfer each table;
-- PostgreSQL also transfers its owned sequence. Do not globally REASSIGN postgres objects.
ALTER SCHEMA public OWNER TO parkit_owner_grp;
ALTER TABLE public.parking_zone OWNER TO parkit_owner_grp;
ALTER TABLE public.vehicle OWNER TO parkit_owner_grp;
ALTER TABLE public.staff_user OWNER TO parkit_owner_grp;
ALTER TABLE public."transaction" OWNER TO parkit_owner_grp;
ALTER TABLE public.payment OWNER TO parkit_owner_grp;
REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO parkit_runtime_grp, parkit_readonly_grp;
GRANT SELECT ON public.parking_zone, public.vehicle, public.staff_user,
    public."transaction", public.payment TO parkit_runtime_grp;
GRANT INSERT ON public.vehicle, public."transaction", public.payment TO parkit_runtime_grp;
GRANT DELETE ON public.vehicle TO parkit_runtime_grp;
GRANT UPDATE (license_plate, vehicle_type) ON public.vehicle TO parkit_runtime_grp;
GRANT UPDATE (current_active_count) ON public.parking_zone TO parkit_runtime_grp;
GRANT UPDATE (exit_time, status, is_lost_ticket) ON public."transaction" TO parkit_runtime_grp;
GRANT UPDATE (payment_method) ON public.payment TO parkit_runtime_grp;
GRANT USAGE ON SEQUENCE public.vehicle_vehicle_id_seq,
    public.transaction_transaction_id_seq, public.payment_payment_id_seq TO parkit_runtime_grp;
GRANT SELECT ON public.parking_zone, public.vehicle, public."transaction", public.payment TO parkit_readonly_grp;
GRANT SELECT (user_id, username, role) ON public.staff_user TO parkit_readonly_grp;
-- Future objects fail closed until explicit, reviewed grants are applied.
ALTER DEFAULT PRIVILEGES FOR ROLE parkit_owner_grp IN SCHEMA public REVOKE ALL ON TABLES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE parkit_owner_grp IN SCHEMA public REVOKE ALL ON SEQUENCES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE parkit_owner_grp REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE parkit_dba REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;
ALTER ROLE parkit_app IN DATABASE grp_parkitdb SET search_path = public;
ALTER ROLE parkit_app IN DATABASE grp_parkitdb SET statement_timeout = '30s';
ALTER ROLE parkit_app IN DATABASE grp_parkitdb SET lock_timeout = '10s';
