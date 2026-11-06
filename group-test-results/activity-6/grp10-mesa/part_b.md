# Part B - Create and Inspect a Backup

## Executed commands and metadata

Full logical backups used the existing Activity 4 **`rors_dba`** account. Passwords were provided through private process environment configuration, not arguments or submitted files. The OS account performing the command has file access; PostgreSQL role grants do not grant filesystem access.

```powershell
& "C:\Program Files\PostgreSQL\18\bin\pg_dump.exe" -w -h 127.0.0.1 -p 55410 -U rors_dba --role=rors_owner_grp -Fc -d mesa_g05_activity4 -f "D:\Data Administration\course-review\activity6-private\g10\original.dump"
& "C:\Program Files\PostgreSQL\18\bin\pg_dump.exe" -w -h 127.0.0.1 -p 55410 -U rors_dba --role=rors_owner_grp -Fc -d g05_a6_g10_restore -f "D:\Data Administration\course-review\activity6-private\g10\fixture.dump"
```

The first command backs up the unchanged source. The second captures the restored copy **after** the disposable recovery fixture was inserted. It is a separate archive; the original was not overwritten.

| Archive | Source database | Completed, Asia/Manila | Bytes | Exit |
|---|---|---|---:|---:|
| `original.dump` | `mesa_g05_activity4` | 2026-11-06T22:51:24.109978+08:00 | 115,386 | 0 |
| `fixture.dump` | `g05_a6_g10_restore` | 2026-11-06T22:56:01.877832+08:00 | 115,540 | 0 |

SHA-256 values, rechecked after recovery:

```text
ab2274d3b5cc1218c221d2aa69604e97fe9220b834799da0efb1937833a4632a  original.dump
fcf81ca02c62d68e241f2dfa8bfef81a7fd4e15cafbacd1c5ef387a9e9018ef9  fixture.dump
```

[Original backup evidence](evidence/original_backup.json) and [fixture backup evidence](evidence/fixture_backup.json) record the exact safe commands, times, sizes, hashes and stderr. Both completed successfully; no archive or authentication data is included in this repository. The source/fixture filenames repeat across group directories but reside in separate protected `g10` directories.

## Archive inspection

```powershell
& "C:\Program Files\PostgreSQL\18\bin\pg_restore.exe" --list "D:\Data Administration\course-review\activity6-private\g10\original.dump"
& "C:\Program Files\PostgreSQL\18\bin\pg_restore.exe" --list "D:\Data Administration\course-review\activity6-private\g10\fixture.dump"
```

The actual [original TOC](evidence/original_archive-list.txt) and [fixture TOC](evidence/fixture_archive-list.txt) are metadata listings, not table-data payloads. They show custom format/version headers, schema/table/data/sequence entries and ownership/grant/default entries. The logical inventory includes **8 tables** and **7 sequences**. TABLE DATA entries can describe empty tables; an entry alone does not prove data was recovered.

The usable-backup test is restoration plus comparison, not merely successful file creation, a nonzero size or a readable TOC. Three independent restore destinations and the comparisons in Part C/D supplied that evidence.
