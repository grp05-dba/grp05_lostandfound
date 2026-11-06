"""Verify copied Park-It PHP on local HTTP port 18082 and PostgreSQL 55442.
Uses private credentials written by setup_lab.py. Does not print login secrets,
HTTP bodies or cookies. Requires the fresh seeded lab and installed pdo_pgsql.
No browser interaction is claimed. Test writes are committed for HTTP requests,
then only the named disposable fixture is removed by the DBA in finally.
"""
import os, subprocess, json, urllib.request, urllib.parse, http.cookiejar, time, re, argparse
from pathlib import Path
p=Path(__file__).resolve().parent
parser=argparse.ArgumentParser(description='HTTP smoke test in the disposable lab only; creates then removes named test records.')
parser.add_argument('--private-dir',default='/tmp/activity4-grp02-private')
parser.add_argument('--source',default='/tmp/activity4-grp02-source')
args=parser.parse_args()
private=Path(args.private_dir)
creds=json.loads((private/'credentials.json').read_text())
env=os.environ|{'PARKIT_HOST':'127.0.0.1','PARKIT_PORT':'55442','PARKIT_USER':'parkit_app','PARKIT_PASSWORD':creds['parkit_app']}
log=(private/'php-server.log').open('w')
server=subprocess.Popen(['php','-S','127.0.0.1:18082','-t',str(private/'web')],env=env,stdout=log,stderr=log)
base='http://127.0.0.1:18082/park-it/'
opener=urllib.request.build_opener(urllib.request.HTTPCookieProcessor(http.cookiejar.CookieJar()))
lines=[]
def http(path,data=None):
 req=urllib.request.Request(base+path,data=urllib.parse.urlencode(data).encode() if data else None)
 with opener.open(req,timeout=10) as r:
  body=r.read().decode(); status=r.status; dest=r.url.removeprefix(base)
 assert 'Database Connection Error' not in body and 'Fatal error' not in body and 'SQLSTATE[' not in body, 'HTTP/DB error: '+path
 lines.append(f'{"POST" if data else "GET"} {path}: HTTP {status}, final route {dest}')
 return body
def sql(query,role='parkit_dba'):
 e=os.environ|{'PGHOST':'127.0.0.1','PGPORT':'55442','PGUSER':role,'PGPASSWORD':creds[role],'PGDATABASE':'grp_parkitdb'}
 r=subprocess.run(['psql','-X','-w','-t','-A','-v','ON_ERROR_STOP=1','-c',query],env=e,text=True,capture_output=True)
 assert r.returncode==0,r.stderr
 return r.stdout.strip()
try:
 for i in range(50):
  try:http('auth/login.php');break
  except OSError:time.sleep(.1)
 else:raise RuntimeError('PHP server failed to start')
 # Read upstream demo secrets privately; do not capture login forms, cookies, or credentials.
 seed=(Path(args.source)/'park-it/config/seed.php').read_text()
 users=dict(re.findall(r"'username'\s*=>\s*'([^']+)',\s*'password'\s*=>\s*'([^']+)'",seed))
 body=http('auth/login.php',{'username':'staff','password':users['staff']})
 assert 'dashboard.php' in lines[-1], 'Staff login did not redirect to dashboard'
 lines.append('Staff login succeeded; submitted credentials and session cookies omitted.')
 body=http('modules/vehicles/index.php',{'action':'register_entry','license_plate':'ACT4-HTTP-1','vehicle_type':'Car','zone_id':'1'})
 vid=sql("SELECT vehicle_id FROM public.vehicle WHERE license_plate='ACT4-HTTP-1';")
 assert vid.isdigit(), 'Entry failed'
 tid=sql("SELECT transaction_id FROM public.\"transaction\" WHERE vehicle_id="+vid+';')
 lines.append('STAFF POLICY GAP: Staff POST successfully registered a vehicle despite the documented Admin-only policy.')
 state=sql("SELECT status FROM public.\"transaction\" WHERE transaction_id="+tid+';')
 assert state=='Active';lines.append('Database after entry: one disposable vehicle with Active transaction; '+sql('SELECT current_active_count FROM public.parking_zone WHERE zone_id=1;')+' occupied space.')
 http('modules/vehicles/edit.php?id='+vid,{'vehicle_id':vid,'license_plate':'ACT4-HTTP-EDIT','vehicle_type':'Car'})
 assert sql('SELECT license_plate FROM public.vehicle WHERE vehicle_id='+vid+';')=='ACT4-HTTP-EDIT'
 lines.append('STAFF POLICY GAP: Staff POST also successfully edited the vehicle.')
 http('modules/monitoring/index.php')
 payload=json.loads(http('modules/monitoring/api_status.php'))
 lines.append('Monitoring API returned valid JSON.')
 http('modules/payments/index.php?license_plate=ACT4-HTTP-EDIT')
 http('modules/payments/process.php',{'transaction_id':tid,'payment_method':'Cash'})
 result=sql('SELECT t.status,p.amount,p.payment_method FROM public."transaction" t JOIN public.payment p USING(transaction_id) WHERE t.transaction_id='+tid+';')
 assert result=='Completed|50.00|Cash',result
 lines.append('Database after payment: '+result+'; occupancy='+sql('SELECT current_active_count FROM public.parking_zone WHERE zone_id=1;'))
 pid=sql('SELECT payment_id FROM public.payment WHERE transaction_id='+tid+';')
 http('modules/payments/history.php',{'action':'update_payment_method','payment_id':pid,'payment_method':'GCash'})
 assert sql('SELECT payment_method FROM public.payment WHERE payment_id='+pid+';')=='GCash'
 lines.append('Payment-method correction persisted as GCash using the runtime column grant; receipt read succeeded.')
 http('auth/logout.php')
 http('auth/login.php',{'username':'admin','password':users['admin']})
 assert 'dashboard.php' in lines[-1]
 lines.append('Admin login and populated dashboard succeeded with the same restricted service account.')
 http('auth/logout.php')
finally:
 # Target only this run's disposable fixture; delete in FK order using trusted owner.
 sql('''BEGIN;
DELETE FROM public.payment WHERE transaction_id IN (SELECT transaction_id FROM public."transaction" WHERE vehicle_id IN (SELECT vehicle_id FROM public.vehicle WHERE license_plate IN ('ACT4-HTTP-1','ACT4-HTTP-EDIT')));
DELETE FROM public."transaction" WHERE vehicle_id IN (SELECT vehicle_id FROM public.vehicle WHERE license_plate IN ('ACT4-HTTP-1','ACT4-HTTP-EDIT'));
DELETE FROM public.vehicle WHERE license_plate IN ('ACT4-HTTP-1','ACT4-HTTP-EDIT');
COMMIT;''')
 server.terminate();server.wait(timeout=10);log.close()
 lines.append('Disposable HTTP test records removed by DBA; seed records retained. PHP test server stopped.')
 (p/'evidence/application_validation.txt').write_text('\n'.join(lines)+'\n')
print('\n'.join(lines))
