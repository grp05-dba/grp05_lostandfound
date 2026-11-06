\pset pager off
\set VERBOSITY verbose
SELECT current_database(), session_user, current_user;
\echo A01: runtime reads
SELECT count(*) AS users FROM users;
SELECT count(*) AS audit_records FROM audit_log;
\echo A02: linked inserts exercise all eleven runtime sequences
BEGIN;
INSERT INTO users(username,email,password_hash,role) VALUES ('a4_student_probe','a4_student@invalid.test','not-an-authentication-hash','STUDENT') RETURNING user_id AS uid \gset
INSERT INTO students(user_id,student_number,first_name,last_name,course,year_level,contact_number)
VALUES (:uid,'A4-PROBE','Activity','Probe','BSIT',3,'000') RETURNING student_id AS sid \gset
INSERT INTO users(username,email,password_hash,role) VALUES ('a4_academic_probe','a4_academic@invalid.test','not-an-authentication-hash','ACADEMIC_SUPERVISOR') RETURNING user_id AS auid \gset
INSERT INTO academic_supervisors(user_id,first_name,last_name,employee_number,department,contact_number)
VALUES (:auid,'Activity','Academic','A4-PROBE','IT','000') RETURNING academic_sup_id AS aid \gset
INSERT INTO companies(company_name,industry,address,contact_number,email,is_partner)
VALUES ('Activity4 Probe','IT','Test','000','a4_company@invalid.test',true) RETURNING company_id AS cid \gset
INSERT INTO users(username,email,password_hash,role) VALUES ('a4_company_probe','a4_supervisor@invalid.test','not-an-authentication-hash','COMPANY_SUPERVISOR') RETURNING user_id AS cuid \gset
INSERT INTO company_supervisors(user_id,company_id,first_name,last_name,position,department,contact_number)
VALUES (:cuid,:cid,'Activity','Mentor','Mentor','IT','000') RETURNING company_sup_id AS csid \gset
INSERT INTO requirements(title) VALUES ('Activity4 Probe') RETURNING req_id AS rid \gset
INSERT INTO ojt_applications(student_id,company_id) VALUES (:sid,:cid) RETURNING application_id AS apid \gset
INSERT INTO student_requirements(student_id,req_id) VALUES (:sid,:rid) RETURNING student_req_id AS srid \gset
INSERT INTO ojt_placements(application_id,student_id,company_id,company_sup_id,academic_sup_id,start_date,end_date,required_hours)
VALUES (:apid,:sid,:cid,:csid,:aid,CURRENT_DATE,CURRENT_DATE+30,100) RETURNING placement_id AS pid \gset
INSERT INTO attendance(placement_id,attendance_date,time_in,time_out,hours_rendered)
VALUES (:pid,CURRENT_DATE,'08:00','16:00',8) RETURNING attendance_id AS atid \gset
INSERT INTO evaluations(placement_id,company_sup_id,score) VALUES (:pid,:csid,90) RETURNING evaluation_id;
\echo A03: permitted updates to actual test records
UPDATE users SET is_active=false, updated_at=now() WHERE user_id=:uid;
UPDATE ojt_applications SET status='Approved', remarks='test' WHERE application_id=:apid;
UPDATE student_requirements SET status='Approved', file_path='test', submission_date=now(),
verified_by_sup_id=:aid, verified_at=now(), remarks='test' WHERE student_req_id=:srid;
UPDATE ojt_placements SET status='Completed' WHERE placement_id=:pid;
UPDATE attendance SET is_verified=true WHERE attendance_id=:atid;
ROLLBACK;
SELECT count(*) AS remaining_probe_users FROM users WHERE username LIKE 'a4_%_probe';
\echo A04: expected denial
BEGIN;
UPDATE users SET role=role WHERE false;
ROLLBACK;
\echo A05: expected denial
BEGIN;
UPDATE attendance SET hours_rendered=hours_rendered WHERE false;
ROLLBACK;
\echo A06: expected denial
BEGIN;
INSERT INTO audit_log(table_name,action,row_id) VALUES ('test','test',0);
ROLLBACK;
\echo A07: expected denial
BEGIN;
DELETE FROM companies WHERE false;
ROLLBACK;
\echo A08: expected denial
BEGIN;
TRUNCATE audit_log;
ROLLBACK;
\echo A09: expected denial
BEGIN;
SELECT nextval('audit_log_audit_id_seq');
ROLLBACK;
\echo A10: expected denial
BEGIN;
CREATE TABLE public.a4_forbidden(id int);
ROLLBACK;
\echo A11: expected denial
BEGIN;
SET ROLE grp03_ojt_admin_grp;
ROLLBACK;
\echo A12: expected cluster privilege denials
CREATE DATABASE grp03_a4_forbidden;
CREATE ROLE grp03_a4_forbidden NOLOGIN;
