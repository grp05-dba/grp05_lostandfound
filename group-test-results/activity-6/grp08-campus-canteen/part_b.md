# Part B - Create and Inspect a Backup

## Executed commands and metadata

Full logical backups used the existing Activity 4 **`canteen_admin`** account. Passwords were provided through private process environment configuration, not arguments or submitted files. The OS account performing the command has file access; PostgreSQL role grants do not grant filesystem access.

```powershell
& "C:\Program Files\PostgreSQL\18\bin\pg_dump.exe" -w -h 127.0.0.1 -p 55408 -U canteen_admin --role=canteen_owner_grp -Fc -d canteen_g05_activity4 -f "D:\Data Administration\course-review\activity6-private\g08\original.dump"
& "C:\Program Files\PostgreSQL\18\bin\pg_dump.exe" -w -h 127.0.0.1 -p 55408 -U canteen_admin --role=canteen_owner_grp -Fc -d g05_a6_g08_restore -f "D:\Data Administration\course-review\activity6-private\g08\fixture.dump"
```

The first command backs up the unchanged source. The second captures the restored copy **after** the disposable recovery fixture was inserted. It is a separate archive; the original was not overwritten.

| Archive | Source database | Completed, Asia/Manila | Bytes | Exit |
|---|---|---|---:|---:|
| `original.dump` | `canteen_g05_activity4` | 2026-11-06T22:51:23.093968+08:00 | 31,226 | 0 |
| `fixture.dump` | `g05_a6_g08_restore` | 2026-11-06T22:54:46.498868+08:00 | 31,215 | 0 |

SHA-256 values, rechecked after recovery:

```text
daefc61ad1f266fa3961eeef67390cc54a7a432cee4547257764a78cc56f4deb  original.dump
6ef0d3203d6ab06bf4d253f3051f55320fefc0c37f36e5c8154d367a7a175e54  fixture.dump
```

[Original backup evidence](evidence/original_backup.json) and [fixture backup evidence](evidence/fixture_backup.json) record the exact safe commands, times, sizes, hashes and stderr. Both completed successfully; no archive or authentication data is included in this repository. The source/fixture filenames repeat across group directories but reside in separate protected `g08` directories.

## Archive inspection

```powershell
& "C:\Program Files\PostgreSQL\18\bin\pg_restore.exe" --list "D:\Data Administration\course-review\activity6-private\g08\original.dump"
& "C:\Program Files\PostgreSQL\18\bin\pg_restore.exe" --list "D:\Data Administration\course-review\activity6-private\g08\fixture.dump"
```

The actual [original TOC](evidence/original_archive-list.txt) and [fixture TOC](evidence/fixture_archive-list.txt) are metadata listings, not table-data payloads. They show custom format/version headers, schema/table/data/sequence entries and ownership/grant/default entries. The logical inventory includes **7 tables** and **7 sequences**. TABLE DATA entries can describe empty tables; an entry alone does not prove data was recovered.

The usable-backup test is restoration plus comparison, not merely successful file creation, a nonzero size or a readable TOC. Three independent restore destinations and the comparisons in Part C/D supplied that evidence.
