"""Run Activity 4 checks in the dedicated Park-It lab; no passwords in output.
Use only on a disposable instance initialized with sql/01_roles_database.sql,
the pinned upstream schema/seed, and sql/02_privileges.sql. Requires private
JSON credentials for the three logins; see part_cd.md. Each probe has its own
connection, and writes are rolled back. Sequence values can still advance.
"""
import argparse
import datetime
import json
import os
from pathlib import Path
import subprocess

P = Path(__file__).resolve().parent
parser = argparse.ArgumentParser()
parser.add_argument('--credentials', default='/tmp/activity4-grp02-private/credentials.json')
parser.add_argument('--host', default='127.0.0.1')
parser.add_argument('--port', default='55442')
args = parser.parse_args()
credentials = json.loads(Path(args.credentials).read_text())
results = []
logs = {}


def execute(role, sql, db='grp_parkitdb'):
    env = os.environ.copy()
    env.update(PGHOST=args.host, PGPORT=args.port, PGUSER=role,
               PGDATABASE=db, PGPASSWORD=credentials[role])
    return subprocess.run(['psql', '-X', '-w', '-a', '-v', 'ON_ERROR_STOP=1',
                           '-v', 'VERBOSITY=verbose'], input=sql,
                          text=True, capture_output=True, env=env)


def check(label, role, sql, expected='allowed', state=None, db='grp_parkitdb', contains=()):
    identity = 'SELECT session_user,current_user,current_database();\n'
    r = execute(role, identity + sql, db)
    output = r.stdout + r.stderr
    # libpq startup errors omit SQLSTATE in psql output; assert the exact CONNECT diagnostic.
    startup_denial = db != 'grp_parkitdb' and 'User does not have CONNECT privilege.' in r.stderr
    ok = (r.returncode == 0) if expected == 'allowed' else (r.returncode != 0 and (startup_denial or state in r.stderr))
    ok = ok and all(s in output for s in contains)
    item = dict(id=f'E{len(results)+1:02d}', test=label, account=role, database=db,
                sql=sql, expected=expected, sqlstate=None if db != 'grp_parkitdb' else state,
                expected_startup_error='User does not have CONNECT privilege.' if db != 'grp_parkitdb' else None, exit_code=r.returncode,
                passed=ok, output=output)
    results.append(item)
    logs.setdefault(role, []).append(f"\n{item['id']} {label}\nExpected: {expected}" +
                                    (' CONNECT privilege diagnostic (psql omits startup SQLSTATE)' if db != 'grp_parkitdb' else f' SQLSTATE {state}' if state else '') + '\n' + output)


app='parkit_app'; auditor='parkit_auditor'; dba='parkit_dba'
for role in (app,auditor,dba):
    check('Direct SCRAM login and identity',role,'SELECT session_user = current_user AS identity_matches;',contains=('t',))
    check('Database creation denied',role,'CREATE DATABASE parkit_forbidden_probe;', 'denied','42501')
    check('Role creation denied',role,'CREATE ROLE parkit_forbidden_role;', 'denied','42501')
    for db in ('parkit_unrelateddb','postgres','template1'):
        check('Unrelated/default database CONNECT denied',role,'SELECT current_database();','denied','42501',db)
    check('Cannot inherit provisioning superuser',role,'SET ROLE postgres;','denied','42501')

for table in ('parking_zone','vehicle','transaction','payment'):
    check('Runtime reads '+table,app,f'SELECT count(*) FROM public."{table}";')
    check('Auditor reads '+table,auditor,f'SELECT count(*) FROM public."{table}";')
check('Runtime staff authentication fields accessible',app,
      'SELECT user_id,username,role,(length(password_hash)>0) AS hash_present FROM public.staff_user;')
check('Auditor approved staff columns',auditor,'SELECT user_id,username,role FROM public.staff_user;')
check('Auditor staff hash denied',auditor,'SELECT password_hash FROM public.staff_user;','denied','42501')
check('Auditor SELECT star staff denied',auditor,'SELECT * FROM public.staff_user;','denied','42501')

# Each normal write probe creates its own rows and rolls back in the same session.
vehicle="INSERT INTO public.vehicle(license_plate,vehicle_type) VALUES ('ACT4-PROBE','Car') RETURNING vehicle_id \\gset\n"
entry=vehicle+'''INSERT INTO public."transaction"(vehicle_id,zone_id,entry_time)
VALUES (:vehicle_id,(SELECT min(zone_id) FROM public.parking_zone),CURRENT_TIMESTAMP)
RETURNING transaction_id \\gset
'''
payment=entry+'''INSERT INTO public.payment(transaction_id,amount,payment_method,payment_time)
VALUES (:transaction_id,50,'Cash',CURRENT_TIMESTAMP) RETURNING payment_id \\gset
'''
check('Runtime complete parking lifecycle, generated IDs and narrow updates',app,
      '''BEGIN;
SELECT zone_id FROM public.parking_zone ORDER BY zone_id LIMIT 1 FOR UPDATE;
'''+entry+'''UPDATE public.parking_zone SET current_active_count=current_active_count+1;
SELECT t.transaction_id,t.status,v.license_plate FROM public."transaction" t
JOIN public.vehicle v USING(vehicle_id) WHERE t.transaction_id=:transaction_id FOR UPDATE;
INSERT INTO public.payment(transaction_id,amount,payment_method,payment_time)
VALUES (:transaction_id,50,'Cash',CURRENT_TIMESTAMP) RETURNING payment_id \\gset
UPDATE public."transaction" SET exit_time=CURRENT_TIMESTAMP,status='Completed',is_lost_ticket=false
WHERE transaction_id=:transaction_id;
UPDATE public.parking_zone SET current_active_count=GREATEST(0,current_active_count-1);
UPDATE public.payment SET payment_method='GCash' WHERE payment_id=:payment_id;
SELECT t.status,p.amount,p.payment_method FROM public."transaction" t
JOIN public.payment p USING(transaction_id) WHERE t.transaction_id=:transaction_id;
ROLLBACK;''',contains=('Completed','50.00','GCash','ROLLBACK'))
check('Runtime edits and deletes unreferenced vehicle',app,'BEGIN;\n'+vehicle+'''
UPDATE public.vehicle SET license_plate='ACT4-EDITED',vehicle_type='Motorcycle' WHERE vehicle_id=:vehicle_id;
DELETE FROM public.vehicle WHERE vehicle_id=:vehicle_id RETURNING license_plate;
ROLLBACK;''',contains=('ACT4-EDITED','DELETE 1','ROLLBACK'))
check('Foreign key protects referenced vehicle',app,'BEGIN;\n'+entry+'DELETE FROM public.vehicle WHERE vehicle_id=:vehicle_id;','denied','23503')
for sql,label in [
 ("UPDATE public.parking_zone SET max_capacity=100;",'capacity'),
 ('UPDATE public.vehicle SET vehicle_id=vehicle_id;','vehicle ID'),
 ('UPDATE public."transaction" SET entry_time=entry_time;','entry timestamp'),
 ('UPDATE public."transaction" SET vehicle_id=vehicle_id;','transaction linkage'),
 ('UPDATE public.payment SET amount=amount;','payment amount'),
 ('UPDATE public.payment SET payment_time=payment_time;','payment timestamp'),
 ('UPDATE public.payment SET transaction_id=transaction_id;','payment linkage'),
 ('UPDATE public.staff_user SET role=role;','staff role'),
 ("INSERT INTO public.parking_zone(zone_name,max_capacity) VALUES('ACT4-NO',1);",'zone insertion'),
 ("INSERT INTO public.staff_user(username,password_hash,role) VALUES('ACT4-NO','noncredential-probe','Staff');",'staff insertion'),
 ('DELETE FROM public.staff_user;','staff deletion'),
 ('DELETE FROM public.parking_zone;','zone deletion'),
 ('DELETE FROM public."transaction";','transaction deletion'),
 ('DELETE FROM public.payment;','payment deletion')]:
    check('Runtime denied '+label,app,'BEGIN;\n'+sql+'\nROLLBACK;','denied','42501')
for role in (app,auditor):
    for sql,label in [
      ('CREATE TABLE public.act4_forbidden(id integer);','schema CREATE'),
      ('CREATE SCHEMA act4_forbidden;','database CREATE'),
      ('CREATE TEMP TABLE act4_forbidden(id integer);','TEMPORARY'),
      ('TRUNCATE public.vehicle;','TRUNCATE'),
      ('ALTER TABLE public.vehicle ADD COLUMN act4_forbidden integer;','ALTER'),
      ('GRANT parkit_owner_grp TO '+role+';','owner membership escalation'),
      ("SELECT nextval('public.staff_user_user_id_seq');",'staff sequence'),
      ("SELECT nextval('public.parking_zone_zone_id_seq');",'zone sequence'),
      ("SELECT setval('public.vehicle_vehicle_id_seq',999);",'setval')]:
        check(label+' denied',role,'BEGIN;\n'+sql+'\nROLLBACK;','denied','42501')
for table in ('parking_zone','vehicle','staff_user','transaction','payment'):
    for op,sql in [
      ('INSERT',f'INSERT INTO public."{table}" DEFAULT VALUES;'),
      ('UPDATE',f'UPDATE public."{table}" SET '+{'parking_zone':'current_active_count','vehicle':'vehicle_type','staff_user':'role','transaction':'status','payment':'payment_method'}[table]+'='+{'parking_zone':'current_active_count','vehicle':'vehicle_type','staff_user':'role','transaction':'status','payment':'payment_method'}[table]+';'),
      ('DELETE',f'DELETE FROM public."{table}";')]:
        check('Auditor '+op+' '+table+' denied',auditor,'BEGIN;\n'+sql+'\nROLLBACK;','denied','42501')
for seq in ('vehicle_vehicle_id_seq','transaction_transaction_id_seq','payment_payment_id_seq'):
    check('Auditor operational sequence denied',auditor,f"SELECT nextval('public.{seq}');",'denied','42501')
check('DBA owns/migrates project objects and provisions zone data',dba,'''BEGIN;
SET ROLE parkit_owner_grp;
CREATE TABLE public.act4_owner_probe(id integer);
ALTER TABLE public.act4_owner_probe ADD COLUMN note text;
INSERT INTO public.parking_zone(zone_name,max_capacity) VALUES('ACT4-DBA',5) RETURNING zone_id;
SELECT session_user,current_user;
DROP TABLE public.act4_owner_probe;
ROLLBACK;''',contains=('parkit_owner_grp','ROLLBACK'))
check('DBA can maintain project table',dba,'ANALYZE public.vehicle;')
# Commit temporary future objects so genuinely separate sessions can test their ACLs.
r=execute(dba,'''SET ROLE parkit_owner_grp;
CREATE TABLE public.act4_future_probe(id serial);
CREATE FUNCTION public.act4_future_function() RETURNS integer LANGUAGE sql AS 'SELECT 1';''')
if r.returncode: raise RuntimeError(r.stderr)
try:
    for role in (app,auditor):
        check('Future table has no automatic grants',role,'SELECT * FROM public.act4_future_probe;','denied','42501')
        check('Future sequence has no automatic grants',role,"SELECT nextval('public.act4_future_probe_id_seq');",'denied','42501')
        check('Future function PUBLIC execute revoked',role,'SELECT public.act4_future_function();','denied','42501')
finally:
    r=execute(dba,'SET ROLE parkit_owner_grp; DROP TABLE public.act4_future_probe; DROP FUNCTION public.act4_future_function();')
    if r.returncode: raise RuntimeError(r.stderr)

# Demonstrate that GRANT/REVOKE alone cannot implement application business rules.
check('Business rule gap: duplicate active entries permitted by schema',app,
      'BEGIN;\n'+entry+'''INSERT INTO public."transaction"(vehicle_id,zone_id,entry_time)
VALUES (:vehicle_id,(SELECT min(zone_id) FROM public.parking_zone),CURRENT_TIMESTAMP);
SELECT count(*) AS active_entries FROM public."transaction" WHERE vehicle_id=:vehicle_id AND status='Active';
ROLLBACK;''',contains=('2','ROLLBACK'))
check('Business rule gap: negative occupancy permitted by schema',app,
      'BEGIN; UPDATE public.parking_zone SET current_active_count=-1 RETURNING current_active_count; ROLLBACK;',contains=('-1','ROLLBACK'))

stamp=datetime.datetime.now(datetime.timezone.utc).isoformat()
for role,entries in logs.items():
    (P/'evidence'/f'{role}.txt').write_text('Captured UTC: '+stamp+'\n'+''.join(entries))
(P/'evidence/results.json').write_text(json.dumps({'captured_at_utc':stamp,'host':args.host,'port':args.port,'results':results},indent=2)+'\n')
print(f'{sum(r["passed"] for r in results)}/{len(results)} checks matched expectations.')
for r in results:
    if not r['passed']: print(r['id'],r['test'],r['output'])
raise SystemExit(0 if all(r['passed'] for r in results) else 1)
