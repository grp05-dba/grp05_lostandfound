# Part B - Create and Inspect a Backup

## Executed commands and metadata

Full logical backups used the existing Activity 4 **`boardtrack_dba`** account. Passwords were provided through private process environment configuration, not arguments or submitted files. The OS account performing the command has file access; PostgreSQL role grants do not grant filesystem access.

```powershell
& "C:\Program Files\PostgreSQL\18\bin\pg_dump.exe" -w -h 127.0.0.1 -p 55411 -U boardtrack_dba --role=boardtrack_owner_grp -Fc -d boardtrack_g05_activity4 -f "D:\Data Administration\course-review\activity6-private\g11\original.dump"
& "C:\Program Files\PostgreSQL\18\bin\pg_dump.exe" -w -h 127.0.0.1 -p 55411 -U boardtrack_dba --role=boardtrack_owner_grp -Fc -d g05_a6_g11_restore -f "D:\Data Administration\course-review\activity6-private\g11\fixture.dump"
```

The first command backs up the unchanged source. The second captures the restored copy **after** the disposable recovery fixture was inserted. It is a separate archive; the original was not overwritten.

| Archive | Source database | Completed, Asia/Manila | Bytes | Exit |
|---|---|---|---:|---:|
| `original.dump` | `boardtrack_g05_activity4` | 2026-11-06T22:51:24.973005+08:00 | 100,082 | 0 |
| `fixture.dump` | `g05_a6_g11_restore` | 2026-11-06T22:56:18.139563+08:00 | 100,103 | 0 |

SHA-256 values, rechecked after recovery:

```text
aaf0c05ce132c23d5164e8595c51f576fdf63b670f8bbabac73596ca73e71beb  original.dump
cf2ff9f95130bd4f6c603f297a5b128ec6fbbcccb8a7d1db774153fe4e86ceae  fixture.dump
```

[Original backup evidence](evidence/original_backup.json) and [fixture backup evidence](evidence/fixture_backup.json) record the exact safe commands, times, sizes, hashes and stderr. Both completed successfully; no archive or authentication data is included in this repository. The source/fixture filenames repeat across group directories but reside in separate protected `g11` directories.

## Archive inspection

```powershell
& "C:\Program Files\PostgreSQL\18\bin\pg_restore.exe" --list "D:\Data Administration\course-review\activity6-private\g11\original.dump"
& "C:\Program Files\PostgreSQL\18\bin\pg_restore.exe" --list "D:\Data Administration\course-review\activity6-private\g11\fixture.dump"
```

The actual [original TOC](evidence/original_archive-list.txt) and [fixture TOC](evidence/fixture_archive-list.txt) are metadata listings, not table-data payloads. They show custom format/version headers, schema/table/data/sequence entries and ownership/grant/default entries. The logical inventory includes **8 tables** and **7 sequences**. TABLE DATA entries can describe empty tables; an entry alone does not prove data was recovered.

The usable-backup test is restoration plus comparison, not merely successful file creation, a nonzero size or a readable TOC. Three independent restore destinations and the comparisons in Part C/D supplied that evidence.
