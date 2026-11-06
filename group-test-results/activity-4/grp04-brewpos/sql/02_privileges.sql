\set ON_ERROR_STOP on
-- Connect as provisioning administrator to grp_brewposdb after importing
-- upstream schema.sql and seed.sql with SET ROLE brewpos_owner_grp.
ALTER SCHEMA public OWNER TO brewpos_owner_grp;
REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO brewpos_runtime_grp, brewpos_readonly_grp;
GRANT SELECT ON public.staff, public.menu_category, public.menu_item,
    public.order_ticket, public.order_line_item TO brewpos_runtime_grp, brewpos_readonly_grp;
GRANT INSERT, UPDATE, DELETE ON public.menu_category TO brewpos_runtime_grp;
GRANT INSERT, UPDATE ON public.menu_item TO brewpos_runtime_grp;
GRANT INSERT ON public.order_ticket, public.order_line_item TO brewpos_runtime_grp;
GRANT USAGE ON SEQUENCE public.menu_category_category_id_seq,
    public.menu_item_item_id_seq, public.order_ticket_order_id_seq TO brewpos_runtime_grp;
-- No runtime access to staff_staff_id_seq or setval; no auditor sequence grants.
ALTER DEFAULT PRIVILEGES FOR ROLE brewpos_owner_grp IN SCHEMA public
    REVOKE ALL ON TABLES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE brewpos_owner_grp IN SCHEMA public
    REVOKE ALL ON SEQUENCES FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE brewpos_owner_grp
    REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;
-- Future tables/sequences require explicit reviewed grants; no blanket runtime grants.
ALTER ROLE brewpos_app IN DATABASE grp_brewposdb SET search_path = public;
ALTER ROLE brewpos_app IN DATABASE grp_brewposdb SET statement_timeout = '30s';
ALTER ROLE brewpos_app IN DATABASE grp_brewposdb SET lock_timeout = '10s';
