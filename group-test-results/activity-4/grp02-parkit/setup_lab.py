"""Initialize a fresh, already-running dedicated PostgreSQL lab and private PHP copy.
No owning-repository files are edited. Private credentials must never be committed.
See part_cd.md for initialization, peer mapping and reproduction instructions.
"""
import os, subprocess, secrets, json, shutil, re, argparse
from pathlib import Path
p=Path(__file__).resolve().parent
parser=argparse.ArgumentParser(description='Fresh isolated lab setup only; never replaces existing roles/databases.')
parser.add_argument('--source',default='/tmp/activity4-grp02-source')
parser.add_argument('--private-dir',default='/tmp/activity4-grp02-private')
parser.add_argument('--admin-host',default='/tmp/activity4-grp02-lab')
parser.add_argument('--port',default='55442')
args=parser.parse_args()
source=Path(args.source)
commit=subprocess.check_output(['git','-C',str(source),'rev-parse','HEAD'],text=True).strip()
if commit != '0c01b3e87cf3d623f5f8c4936e3fe7fe56daeeb3':
    raise SystemExit('Source commit differs from evaluated version; inspect before adapting setup.')
private=Path(args.private_dir); private.mkdir(mode=0o700,exist_ok=True)
if (private/'credentials.json').exists():
    raise SystemExit('Private credentials already exist; refusing to overwrite a prior lab setup.')
roles=['parkit_app','parkit_auditor','parkit_dba']
creds={r:secrets.token_urlsafe(32) for r in roles}
f=private/'credentials.json'; f.write_text(json.dumps(creds)); f.chmod(0o600)
env=os.environ.copy();env.update(PGHOST=args.admin_host,PGPORT=args.port,PGUSER='postgres',PGDATABASE='postgres')
def run(args,sql=None):
 r=subprocess.run(['psql','-X','-w','-v','ON_ERROR_STOP=1']+args,input=sql,text=True,capture_output=True,env=env)
 if r.returncode: raise RuntimeError(r.stderr)
 return r.stdout+r.stderr
out=run(['-a','-f',str(p/'sql/01_roles_database.sql')])
# Credentials travel only on stdin, without statement echo; do not retain their SQL.
run([],''.join(f"ALTER ROLE {r} PASSWORD '{creds[r]}';\n" for r in roles))
out+='Private SCRAM credentials assigned to three project logins (values omitted).\n'
env['PGDATABASE']='grp_parkitdb'
# Do not echo source dump/config/seed content into submitted logs.
out+='Imported upstream park-it/schema.sql unchanged:\n'+run(['-f',str(source/'park-it/schema.sql')])
out+=run(['-a','-f',str(p/'sql/02_privileges.sql')])
app=private/'web/park-it';shutil.copytree(source/'park-it',app)
conf=app/'config/database.php';s=conf.read_text()
for key,value in {'DB_HOST':"getenv('PARKIT_HOST')",'DB_PORT':"getenv('PARKIT_PORT')",'DB_USER':"getenv('PARKIT_USER')",'DB_PASS':"getenv('PARKIT_PASSWORD')"}.items():
 s=re.sub(r"define\('"+key+r"',\s*'[^']*'\);[^\n]*",f"define('{key}', {value});",s)
conf.write_text(s)
# Seed as owner login, not runtime; upstream HTML output contains demo passwords and is not saved.
phpenv=env|{'PARKIT_HOST':'127.0.0.1','PARKIT_PORT':args.port,'PARKIT_USER':'parkit_dba','PARKIT_PASSWORD':creds['parkit_dba']}
r=subprocess.run(['php',str(app/'config/seed.php')],text=True,capture_output=True,env=phpenv)
assert r.returncode==0 and 'Database initialization completed successfully!' in r.stdout, 'Seed failed (raw HTML omitted)'
out+='Upstream config/seed.php executed via PHP CLI as parkit_dba: initialization success; raw HTML omitted because it prints demo credentials.\n'
(p/'evidence/setup.txt').write_text(out)
print('Fresh database initialized; original schema imported; ownership/grants applied; PHP seed succeeded as DBA. Evidence saved without credentials.')
