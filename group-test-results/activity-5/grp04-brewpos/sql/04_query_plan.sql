-- SQL translation of OrderLineItemRepository.dailyTotals JPQL, not captured Hibernate SQL.
-- SalesReportService supplies the same half-open local-day timestamp range.
-- Source commit f2af982d7cd2709ebcb0e0f0fd00af27bc4286d4; run as brewpos_app.
\set ON_ERROR_STOP on
\pset pager off
SELECT clock_timestamp() AS captured_at,session_user,current_user,current_database();
BEGIN READ ONLY;
SET LOCAL statement_timeout='30s';
SELECT coalesce(min(order_timestamp)::date,current_date) AS report_date FROM public.order_ticket
\gset
\echo Selected existing order day (or today if empty): :report_date
EXPLAIN
SELECT sum(l.quantity * l.sold_price), count(DISTINCT t.order_id)
FROM public.order_line_item l JOIN public.order_ticket t ON t.order_id=l.order_id
WHERE t.order_timestamp >= :'report_date'::date::timestamp
  AND t.order_timestamp < (:'report_date'::date + 1)::timestamp;
EXPLAIN (ANALYZE, BUFFERS)
SELECT sum(l.quantity * l.sold_price), count(DISTINCT t.order_id)
FROM public.order_line_item l JOIN public.order_ticket t ON t.order_id=l.order_id
WHERE t.order_timestamp >= :'report_date'::date::timestamp
  AND t.order_timestamp < (:'report_date'::date + 1)::timestamp;
-- The aggregate itself is safe to record and validates report semantics.
SELECT sum(l.quantity * l.sold_price), count(DISTINCT t.order_id)
FROM public.order_line_item l JOIN public.order_ticket t ON t.order_id=l.order_id
WHERE t.order_timestamp >= :'report_date'::date::timestamp
  AND t.order_timestamp < (:'report_date'::date + 1)::timestamp;
ROLLBACK;
