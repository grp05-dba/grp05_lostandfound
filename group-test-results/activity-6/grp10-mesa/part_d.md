# Part D - Controlled Recovery Simulation

## Intended scope and recorded state

Only **`g05_a6_g10_restore`** was modified. The original `mesa_g05_activity4` was excluded, and no real operational row or table was deleted. The initial source archive was first restored and verified, then this clearly labeled disposable record was added to the restored copy:

```sql
INSERT INTO menu_item(item_name,category,price) VALUES('G05-A6-RECOVER-10','Activity6 disposable',1) RETURNING menu_item_id,item_name;
```

[Fixture insertion output](evidence/fixture_insert.txt) records the generated ID and marker `G05-A6-RECOVER-10`. The source remains free of both recovery/late markers. A new **fixture archive** captured this state; the initial source archive stayed intact.

Before deletion, the fixture archive was independently restored to `g05_a6_g10_snapshot` and fully compared with its expected data/schema/permissions/sequence state. Thus backup usability was established **before** the destructive test.

A second marker `G05-A6-LATE-10` was inserted only after that snapshot. [Late insertion](evidence/late_insert.txt) records this post-backup change; it intentionally demonstrates the recovery-point boundary.

## Guarded simulated loss

```sql
\set ON_ERROR_STOP on
-- Run ONLY after snapshot verification, in g05_a6_g10_restore.
SET ROLE rors_owner_grp;
BEGIN;
DO $$ BEGIN
 IF current_database()<>'g05_a6_g10_restore' OR current_setting('port')<>'55410' THEN RAISE EXCEPTION 'Wrong disposable recovery target'; END IF;
 IF (SELECT count(*) FROM public.menu_item WHERE item_name='G05-A6-RECOVER-10')<>1 THEN RAISE EXCEPTION 'Expected one clearly identified disposable fixture'; END IF;
END $$;
DELETE FROM public.menu_item WHERE item_name='G05-A6-RECOVER-10' RETURNING menu_item_id,item_name;
COMMIT;
```

[Deletion output](evidence/incident_delete.txt) confirms exactly one clearly marked record was deleted. The transaction guards verified database name, port and marker count. It did not drop a table, wipe application data or act on the source.

## Recovery and comparison

The verified fixture archive was restored to the separate fresh database **`g05_a6_g10_recovered`**, using the same authority-aware restore phases and explicit target policy. Full recovery was chosen because this small logical database is inexpensive to restore and keeping the incident copy enables comparison without overwriting it.

| Database state | Marker result |
|---|---|
| original | recovery fixture absent; late fixture absent |
| after_incident | recovery fixture absent; late fixture present |
| verified_snapshot | recovery fixture present; late fixture absent |
| recovered | recovery fixture present; late fixture absent |

[Exact safe marker outputs](evidence/recovery_states.json) include the generated identifier and test label only. [Recovered comparison](evidence/recovered_comparison.json) confirms all recovered data/objects/permissions/sequences equal the verified fixture snapshot; [source preservation](evidence/source_preserved_comparison.json) confirms the original remained unchanged. Both original/fixture archive SHA-256 values were rechecked.

## Timeline and recovery-point limit

| Event | Actual timestamp, Asia/Manila |
|---|---|
| source inspection started | 2026-11-06T22:55:55.865225+08:00 |
| recovery fixture inserted | 2026-11-06T22:55:59.631519+08:00 |
| fixture backup and listing completed | 2026-11-06T22:56:01.878831+08:00 |
| snapshot database provisioned | 2026-11-06T22:56:02.678297+08:00 |
| snapshot restore completed | 2026-11-06T22:56:03.792690+08:00 |
| fixture archive independently restored and verified before deletion | 2026-11-06T22:56:05.316807+08:00 |
| late fixture inserted | 2026-11-06T22:56:05.423672+08:00 |
| fixture deleted only in disposable restore database | 2026-11-06T22:56:05.542416+08:00 |
| recovered database provisioned | 2026-11-06T22:56:06.315069+08:00 |
| recovered restore completed | 2026-11-06T22:56:07.226486+08:00 |
| recovery, access, original preservation and archive checksums verified | 2026-11-06T22:56:10.737261+08:00 |

**Outcome: intended disposable record recovered exactly.** The late record is absent from the recovered copy because it was created after the snapshot. This is a deliberate demonstration of the logical backup recovery point, not a failed attempt to recover that late change. No merging of newer transactions, application cutover or WAL point-in-time recovery was attempted.
