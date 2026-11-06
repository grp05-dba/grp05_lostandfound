\set ON_ERROR_STOP on
-- ONLY for this owned, isolated evaluation cluster. Preserve existing project grants.
-- Review legitimate users before adapting any PUBLIC revokes to a shared server.
REVOKE CONNECT, TEMPORARY ON DATABASE postgres FROM PUBLIC;
REVOKE CONNECT, TEMPORARY ON DATABASE template1 FROM PUBLIC;
REVOKE CONNECT, TEMPORARY ON DATABASE grp_brewposdb FROM PUBLIC;
REVOKE CONNECT, TEMPORARY ON DATABASE brewpos_unrelateddb FROM PUBLIC;
REVOKE CONNECT, TEMPORARY ON DATABASE grp00_habalgodb FROM PUBLIC;
REVOKE CONNECT, TEMPORARY ON DATABASE habalgo_unrelateddb FROM PUBLIC;
