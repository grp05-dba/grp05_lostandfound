# Part D – Controlled Recovery Simulation

## Incident and preparation

The incident deleted one clearly labeled disposable vehicle from **`parkit_a6_restore` only**. The original database contained no vehicles, so the test record was created after initial restoration and captured in a separate simulation backup.

```sql
-- Connected to parkit_a6_restore as parkit_dba.
INSERT INTO public.vehicle (license_plate, vehicle_type)
VALUES ('ACT6-RECOVER-02', 'Car')
RETURNING vehicle_id, license_plate, vehicle_type;
```

Recorded result:

```text
12 | ACT6-RECOVER-02 | Car
```

The test database was backed up as `parkit_a6_fixture_activity6.dump` using the command in [Part B](part_b.md). Before deletion, this snapshot was successfully restored into a fresh `parkit_a6_snapshot_check`, and its objects, records, privileges and recovery vehicle were verified. The archive checksum was checked again.

A second vehicle, `ACT6-LATE-02`, was inserted after the snapshot to demonstrate the recovery-point limitation:

```sql
INSERT INTO public.vehicle (license_plate, vehicle_type)
VALUES ('ACT6-LATE-02', 'Motorcycle');
```

## Simulated loss

After confirming the verified backup and disposable database, the incident transaction checked the target database and marker count, then deleted only the recovery vehicle:

```sql
BEGIN;
DO $$ BEGIN
  IF current_database() <> 'parkit_a6_restore' THEN
    RAISE EXCEPTION 'Wrong database for recovery simulation';
  END IF;
  IF (SELECT count(*) FROM public.vehicle
      WHERE license_plate='ACT6-RECOVER-02') <> 1 THEN
    RAISE EXCEPTION 'Expected exactly one disposable recovery record';
  END IF;
END $$;
DELETE FROM public.vehicle WHERE license_plate='ACT6-RECOVER-02'
RETURNING vehicle_id, license_plate, vehicle_type;
COMMIT;
```

The deletion returned vehicle 12, `ACT6-RECOVER-02`, Car. The late vehicle remained present. No table, real parking history or original data was deleted.

## Recovery

The provisioner created a fresh recovery database and applied its database access settings. The DBA restored the verified simulation snapshot:

```sh
createdb -w -h /tmp/activity4-grp02-lab -p 55442 -U postgres -O parkit_owner_grp -T template0 parkit_a6_recovered
pg_restore -w --exit-on-error --single-transaction -h 127.0.0.1 -p 55442 -U parkit_dba -d parkit_a6_recovered /tmp/activity6-grp02-private/backups/parkit_a6_fixture_activity6.dump
```

Both succeeded. A full restore into a fresh database was appropriate for this small dataset and preserved the incident database for comparison.

```sql
SELECT vehicle_id, license_plate, vehicle_type FROM public.vehicle;
```

Actual states, confirmed again after the test:

| Database / state | Vehicle records |
|---|---|
| Original `grp_parkitdb` | None; original preserved |
| Test database before incident | 12 / ACT6-RECOVER-02 / Car; 13 / ACT6-LATE-02 / Motorcycle |
| `parkit_a6_restore` after incident | 13 / ACT6-LATE-02 / Motorcycle |
| Verified `parkit_a6_snapshot_check` | 12 / ACT6-RECOVER-02 / Car |
| `parkit_a6_recovered` | 12 / ACT6-RECOVER-02 / Car |

## Timeline and outcome

All times are 6 November 2026, Asia/Manila.

| Event | Time |
|---|---|
| Recovery record created | 22:17:20 |
| Simulation snapshot independently verified | 22:17:21 |
| Late record inserted, then recovery record deleted | 22:17:21 |
| Fresh recovery restore and record verification completed | 22:17:21 |

**Result: the intended record was recovered exactly.** Its ID, plate and type matched the recorded state. Permissions and PHP login also worked against the recovered database.

The late row was absent from the recovered database because it was created after the backup. A real incident could similarly lose valid changes since the latest snapshot. More frequent backups or tested WAL/PITR are needed for tighter recovery objectives. No application cutover or merging of the late record was performed.
