\set ON_ERROR_STOP on
-- ISOLATED LAB ONLY: all databases below belong to this evaluation environment.
-- Do not blindly apply PUBLIC revokes to a shared/production cluster.
-- Preserve any legitimate users' explicit grants before adapting these commands.
REVOKE CONNECT, TEMPORARY ON DATABASE postgres FROM PUBLIC;
REVOKE CONNECT, TEMPORARY ON DATABASE template1 FROM PUBLIC;
REVOKE CONNECT, TEMPORARY ON DATABASE grp_brewposdb FROM PUBLIC;
REVOKE CONNECT, TEMPORARY ON DATABASE brewpos_unrelateddb FROM PUBLIC;
-- The existing Group 4 explicit grants/ownership remain intact.
