# Part B - Create and Inspect a Backup

## Executed commands and metadata

Full logical backups used the existing Activity 4 **`grp03_ojt_dba`** account. Passwords were provided through private process environment configuration, not arguments or submitted files. The OS account performing the command has file access; PostgreSQL role grants do not grant filesystem access.

```powershell
& "C:\Program Files\PostgreSQL\18\bin\pg_dump.exe" -w -h 127.0.0.1 -p 55403 -U grp03_ojt_dba --role=grp03_ojt_admin_grp -Fc -d ojt_managementdb -f "D:\Data Administration\course-review\activity6-private\g03\original.dump"
& "C:\Program Files\PostgreSQL\18\bin\pg_dump.exe" -w -h 127.0.0.1 -p 55403 -U grp03_ojt_dba --role=grp03_ojt_admin_grp -Fc -d g05_a6_g03_restore -f "D:\Data Administration\course-review\activity6-private\g03\fixture.dump"
```

The first command backs up the unchanged source. The second captures the restored copy **after** the disposable recovery fixture was inserted. It is a separate archive; the original was not overwritten.

| Archive | Source database | Completed, Asia/Manila | Bytes | Exit |
|---|---|---|---:|---:|
| `original.dump` | `ojt_managementdb` | 2026-11-06T23:02:31.104808+08:00 | 59,505 | 0 |
| `fixture.dump` | `g05_a6_g03_restore` | 2026-11-06T23:03:00.067868+08:00 | 59,600 | 0 |

SHA-256 values, rechecked after recovery:

```text
b73949bf0ba8af876d8a31b7598170a7ba4c98b8f5fa15b658d55a5984b79bb4  original.dump
e377cb37edfd47c6601fd48c15d18fa6947d3eb8891ae9c9fd10983b9de8d7d5  fixture.dump
```

[Original backup evidence](evidence/original_backup.json) and [fixture backup evidence](evidence/fixture_backup.json) record the exact safe commands, times, sizes, hashes and stderr. Both completed successfully; no archive or authentication data is included in this repository. The source/fixture filenames repeat across group directories but reside in separate protected `g03` directories.

## Archive inspection

```powershell
& "C:\Program Files\PostgreSQL\18\bin\pg_restore.exe" --list "D:\Data Administration\course-review\activity6-private\g03\original.dump"
& "C:\Program Files\PostgreSQL\18\bin\pg_restore.exe" --list "D:\Data Administration\course-review\activity6-private\g03\fixture.dump"
```

The actual [original TOC](evidence/original_archive-list.txt) and [fixture TOC](evidence/fixture_archive-list.txt) are metadata listings, not table-data payloads. They show custom format/version headers, schema/table/data/sequence entries and ownership/grant/default entries. The logical inventory includes **12 tables** and **12 sequences**. TABLE DATA entries can describe empty tables; an entry alone does not prove data was recovered.

The usable-backup test is restoration plus comparison, not merely successful file creation, a nonzero size or a readable TOC. Three independent restore destinations and the comparisons in Part C/D supplied that evidence.
