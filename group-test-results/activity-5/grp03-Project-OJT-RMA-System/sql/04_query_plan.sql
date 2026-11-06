-- Actual STUDENT My requirements query: system/Roles.java MY_REQS and STUDENT tab.
-- Commit 6a899fbc5882c2916be0af3a91457b1c0c54084b. Substitute an existing profile ID, not a fabricated one.
-- Only SELECT plans are executed. Java Db.init()/seed() are not called.
\set ON_ERROR_STOP on
\pset pager off
SELECT clock_timestamp() AS captured_at,session_user,current_user,current_database();
BEGIN READ ONLY;
SET LOCAL statement_timeout='30s';
SET LOCAL search_path=public,pg_catalog;
SELECT student_id FROM public.students WHERE deleted_at IS NULL ORDER BY student_id LIMIT 1
\gset
\echo Selected existing student profile ID: :student_id
EXPLAIN
SELECT r.req_id, r.title, r.is_mandatory,
       coalesce(sr.status,'Not submitted') status, sr.remarks
FROM requirements r
LEFT JOIN student_requirements sr ON sr.req_id=r.req_id AND sr.student_id=:student_id
ORDER BY r.req_id;
EXPLAIN (ANALYZE, BUFFERS)
SELECT r.req_id, r.title, r.is_mandatory,
       coalesce(sr.status,'Not submitted') status, sr.remarks
FROM requirements r
LEFT JOIN student_requirements sr ON sr.req_id=r.req_id AND sr.student_id=:student_id
ORDER BY r.req_id;
ROLLBACK;
