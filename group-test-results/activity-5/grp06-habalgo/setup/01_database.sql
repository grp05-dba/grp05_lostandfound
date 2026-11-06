-- Fresh local prerequisites only, after confirming database/roles are absent.
-- Run as the cluster setup administrator connected to postgres; never rerun blindly.
\set ON_ERROR_STOP on
CREATE DATABASE grp00_habalgodb;
