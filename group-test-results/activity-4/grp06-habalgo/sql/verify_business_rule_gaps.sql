\set ON_ERROR_STOP on
SELECT session_user,current_user,current_database();
BEGIN;
INSERT INTO habalgo.customer(name,phone,email) VALUES ('E4 owner customer','09000000000','e4-owner@example.invalid') RETURNING customer_id AS owner_customer \gset
INSERT INTO habalgo.customer(name,phone,email) VALUES ('E4 other customer','09000000000','e4-other@example.invalid') RETURNING customer_id AS other_customer \gset
INSERT INTO habalgo.vehicle(plate_no,vehicle_type,model) VALUES ('E4-GAP','Motorcycle','Probe') RETURNING vehicle_id \gset
SELECT min(driver_id) AS first_driver,max(driver_id) AS second_driver FROM habalgo.driver \gset
INSERT INTO habalgo.driver_vehicle(driver_id,vehicle_id,assigned_from) VALUES (:first_driver,:vehicle_id,now()),(:second_driver,:vehicle_id,now());
SELECT count(*) AS simultaneously_active_assignments FROM habalgo.driver_vehicle WHERE vehicle_id=:vehicle_id AND assigned_to IS NULL;
INSERT INTO habalgo.location(address,city) VALUES ('E4 gap pickup','Manila') RETURNING location_id AS pickup_id \gset
INSERT INTO habalgo.location(address,city) VALUES ('E4 gap dropoff','Manila') RETURNING location_id AS dropoff_id \gset
INSERT INTO habalgo.booking(customer_id,pickup_location_id,dropoff_location_id) VALUES (:owner_customer,:pickup_id,:dropoff_id) RETURNING booking_id \gset
INSERT INTO habalgo.rating_feedback(booking_id,customer_id,rating,feedback) VALUES (:booking_id,:other_customer,5,'E4 direct SQL probe');
SELECT b.booking_status,b.customer_id AS booking_customer,r.customer_id AS rating_customer,(b.customer_id<>r.customer_id) AS mismatched_customer FROM habalgo.booking b JOIN habalgo.rating_feedback r USING(booking_id) WHERE b.booking_id=:booking_id;
ROLLBACK;
SELECT count(*) AS remaining_probe_customers FROM habalgo.customer WHERE email LIKE 'e4-%@example.invalid';
SELECT count(*) AS remaining_probe_vehicles FROM habalgo.vehicle WHERE plate_no='E4-GAP';
