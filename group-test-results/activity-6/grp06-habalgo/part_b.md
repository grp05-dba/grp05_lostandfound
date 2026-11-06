# Part B - Create and Inspect a Backup

## Executed commands and metadata

Full logical backups used the existing Activity 4 **`habalgo_dba`** account. Passwords were provided through private process environment configuration, not arguments or submitted files. The OS account performing the command has file access; PostgreSQL role grants do not grant filesystem access.

```powershell
& "C:\Program Files\PostgreSQL\18\bin\pg_dump.exe" -w -h 127.0.0.1 -p 55406 -U habalgo_dba --role=habalgo_owner_grp -Fc -d grp00_habalgodb -f "D:\Data Administration\course-review\activity6-private\g06\original.dump"
& "C:\Program Files\PostgreSQL\18\bin\pg_dump.exe" -w -h 127.0.0.1 -p 55406 -U habalgo_dba --role=habalgo_owner_grp -Fc -d g05_a6_g06_restore -f "D:\Data Administration\course-review\activity6-private\g06\fixture.dump"
```

The first command backs up the unchanged source. The second captures the restored copy **after** the disposable recovery fixture was inserted. It is a separate archive; the original was not overwritten.

| Archive | Source database | Completed, Asia/Manila | Bytes | Exit |
|---|---|---|---:|---:|
| `original.dump` | `grp00_habalgodb` | 2026-11-06T23:03:13.465408+08:00 | 31,120 | 0 |
| `fixture.dump` | `g05_a6_g06_restore` | 2026-11-06T23:04:56.485549+08:00 | 31,184 | 0 |

SHA-256 values, rechecked after recovery:

```text
1d81457062867a9af5f1d32a17846b3e3335d4c05492035c4de887800b80a1fe  original.dump
fe7df50cbccb60c809fb388ebc2ee85bebd0e1124d1c6341c82144efe81455eb  fixture.dump
```

[Original backup evidence](evidence/original_backup.json) and [fixture backup evidence](evidence/fixture_backup.json) record the exact safe commands, times, sizes, hashes and stderr. Both completed successfully; no archive or authentication data is included in this repository. The source/fixture filenames repeat across group directories but reside in separate protected `g06` directories.

## Archive inspection

```powershell
& "C:\Program Files\PostgreSQL\18\bin\pg_restore.exe" --list "D:\Data Administration\course-review\activity6-private\g06\original.dump"
& "C:\Program Files\PostgreSQL\18\bin\pg_restore.exe" --list "D:\Data Administration\course-review\activity6-private\g06\fixture.dump"
```

The actual [original TOC](evidence/original_archive-list.txt) and [fixture TOC](evidence/fixture_archive-list.txt) are metadata listings, not table-data payloads. They show custom format/version headers, schema/table/data/sequence entries and ownership/grant/default entries. The logical inventory includes **8 tables** and **7 sequences**. TABLE DATA entries can describe empty tables; an entry alone does not prove data was recovered.

The usable-backup test is restoration plus comparison, not merely successful file creation, a nonzero size or a readable TOC. Three independent restore destinations and the comparisons in Part C/D supplied that evidence.
