-- Run as park_it_app. Exact live-monitor SELECT from the supplied repository:
-- park-it/modules/monitoring/api_status.php, $stmtActive, commit
-- d369a457ce2dc88a024428513360f0ad76473f43.
-- Only this SELECT is executed, not getParkingSummary(), which can UPDATE occupancy.
\set ON_ERROR_STOP on
\pset pager off
SELECT clock_timestamp() AS captured_at,session_user,current_user,current_database();
BEGIN READ ONLY;
SET LOCAL statement_timeout='30s';
EXPLAIN
SELECT t.transaction_id, t.entry_time, t.status,
       v.license_plate, v.vehicle_type, z.zone_name
FROM public."transaction" t
JOIN public.vehicle v ON t.vehicle_id = v.vehicle_id
JOIN public.parking_zone z ON t.zone_id = z.zone_id
WHERE t.status = 'Active'
ORDER BY t.entry_time DESC;
EXPLAIN (ANALYZE, BUFFERS)
SELECT t.transaction_id, t.entry_time, t.status,
       v.license_plate, v.vehicle_type, z.zone_name
FROM public."transaction" t
JOIN public.vehicle v ON t.vehicle_id = v.vehicle_id
JOIN public.parking_zone z ON t.zone_id = z.zone_id
WHERE t.status = 'Active'
ORDER BY t.entry_time DESC;
ROLLBACK;
