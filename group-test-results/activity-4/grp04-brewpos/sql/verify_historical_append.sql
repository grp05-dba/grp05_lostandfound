\set ON_ERROR_STOP on
SELECT session_user,current_user,current_database();
BEGIN;
INSERT INTO order_line_item(order_id,item_id,quantity,sold_price)
SELECT t.order_id,m.item_id,1,m.price
FROM order_ticket t CROSS JOIN menu_item m
WHERE NOT EXISTS (SELECT 1 FROM order_line_item l WHERE l.order_id=t.order_id AND l.item_id=m.item_id)
ORDER BY t.order_id,m.item_id LIMIT 1
RETURNING order_id,item_id,quantity,sold_price;
ROLLBACK;
SELECT count(*) AS lines_after_rollback FROM order_line_item;
