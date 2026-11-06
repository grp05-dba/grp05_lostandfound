"""Read the current OS user's service journal; print only scoped, safe evidence.

No log configuration or files are modified. Raw SQL, DETAIL/HINT, authentication
material and other projects' messages are never copied. Run without sudo.
"""
import collections
import datetime
import json
import re
import subprocess

end = datetime.datetime.now().astimezone().isoformat(timespec="seconds")
command = ["journalctl", "-u", "postgresql", "--since", "2026-11-06 00:00:00",
           "--until", end, "--no-pager", "-o", "json"]
result = subprocess.run(command, capture_output=True, text=True, check=False)
print("Captured:", end)
print("Reader: existing workspace OS user me; no sudo or database impersonation.")
print("Command:", " ".join(command))
print("Exit status:", result.returncode)
entries = []
for line in result.stdout.splitlines():
    try:
        entries.append(json.loads(line))
    except json.JSONDecodeError:
        continue
print("Readable service entries:", len(entries))
sessions = {}
findings = []
connections = collections.Counter()
severity_counts = collections.Counter()
for entry in entries:
    message = str(entry.get("MESSAGE", ""))
    prefix = re.search(r"\[(\d+)\]", message)
    if not prefix:
        continue
    pid = prefix.group(1)
    authorized = re.search(r"connection authorized: user=(\S+) database=(\S+)", message)
    if authorized:
        sessions[pid] = authorized.groups()
        account, database = authorized.groups()
        if database == "grp07_campussafedb" or account in {"campussafe_app", "campussafe_report", "campussafe_owner", "campussafe_backup"}:
            connections[(account, database)] += 1
    account, database = sessions.get(pid, ("unknown", "unknown"))
    if database != "grp07_campussafedb" and account not in {"campussafe_app", "campussafe_report", "campussafe_owner", "campussafe_backup"}:
        continue
    event = re.search(r"\b(ERROR|FATAL|WARNING):\s+(.*)", message)
    if not event:
        continue
    severity, detail = event.groups()
    severity_counts[severity] += 1
    # Copy only known diagnostic formats, never arbitrary SQL or user values.
    if re.fullmatch(r'permission denied for (?:table|schema|function) [a-zA-Z_][a-zA-Z_0-9]*(?: at character \d+)?', detail):
        safe = detail
    elif re.fullmatch(r'role "campussafe_(?:app|report|backup|owner)" does not exist', detail):
        safe = detail
    elif detail in {"permission denied to create database", "permission denied to create role",
                    'relation "vehicle" does not exist',
                    "terminating connection due to administrator command",
                    'unrecognized privilege type: "MAINTAIN"', 'role "me" does not exist'}:
        safe = detail
    else:
        safe = "[diagnostic omitted: outside safe message allowlist; requires authorized manual review]"
    timestamp = datetime.datetime.fromtimestamp(int(entry["__REALTIME_TIMESTAMP"]) / 1_000_000,
                                               datetime.timezone.utc).isoformat()
    findings.append((timestamp, pid, account, database, severity, safe))
print("\nConnection authorization records (exact database/account match; not proof session startup completed):")
for (account, database), count in sorted(connections.items()):
    print(f"{account} | {database} | {count}")
print("\nProject session diagnostics (UTC timestamps; PID correlated with preceding authorization):")
for row in findings:
    print(" | ".join(row))
print("\nSeverity counts:", dict(severity_counts))
print("No raw SQL, DETAIL/HINT, password values, or other projects' session diagnostics copied.")
print("Limitations: current user's readable service window only; PID correlation needs an authorization")
print("inside the window. Pre-authorization failures, rotated history, other sinks and unlogged durations")
print("are not covered. No observed diagnostic is not proof of no incident.")
