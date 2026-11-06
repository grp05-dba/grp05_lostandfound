# Part B - Create and Inspect a Backup

## Executed commands and metadata

Full logical backups used the existing Activity 4 **`brewpos_dba`** account. Passwords were provided through private process environment configuration, not arguments or submitted files. The OS account performing the command has file access; PostgreSQL role grants do not grant filesystem access.

```powershell
& "C:\Program Files\PostgreSQL\18\bin\pg_dump.exe" -w -h 127.0.0.1 -p 55404 -U brewpos_dba --role=brewpos_owner_grp -Fc -d grp_brewposdb -f "D:\Data Administration\course-review\activity6-private\g04\original.dump"
& "C:\Program Files\PostgreSQL\18\bin\pg_dump.exe" -w -h 127.0.0.1 -p 55404 -U brewpos_dba --role=brewpos_owner_grp -Fc -d g05_a6_g04_restore -f "D:\Data Administration\course-review\activity6-private\g04\fixture.dump"
```

The first command backs up the unchanged source. The second captures the restored copy **after** the disposable recovery fixture was inserted. It is a separate archive; the original was not overwritten.

| Archive | Source database | Completed, Asia/Manila | Bytes | Exit |
|---|---|---|---:|---:|
| `original.dump` | `grp_brewposdb` | 2026-11-06T23:03:23.372231+08:00 | 18,352 | 0 |
| `fixture.dump` | `g05_a6_g04_restore` | 2026-11-06T23:03:34.437591+08:00 | 18,417 | 0 |

SHA-256 values, rechecked after recovery:

```text
5ba78bf4fe0eb9f195e7383cea59e16b7e0360637160c4c3eec36f6175953603  original.dump
6696338d77d2923a9cb70d9cc85b6dc94211aca6bf7e6ec5f2c8c388b95637e0  fixture.dump
```

[Original backup evidence](evidence/original_backup.json) and [fixture backup evidence](evidence/fixture_backup.json) record the exact safe commands, times, sizes, hashes and stderr. Both completed successfully; no archive or authentication data is included in this repository. The source/fixture filenames repeat across group directories but reside in separate protected `g04` directories.

## Archive inspection

```powershell
& "C:\Program Files\PostgreSQL\18\bin\pg_restore.exe" --list "D:\Data Administration\course-review\activity6-private\g04\original.dump"
& "C:\Program Files\PostgreSQL\18\bin\pg_restore.exe" --list "D:\Data Administration\course-review\activity6-private\g04\fixture.dump"
```

The actual [original TOC](evidence/original_archive-list.txt) and [fixture TOC](evidence/fixture_archive-list.txt) are metadata listings, not table-data payloads. They show custom format/version headers, schema/table/data/sequence entries and ownership/grant/default entries. The logical inventory includes **5 tables** and **4 sequences**. TABLE DATA entries can describe empty tables; an entry alone does not prove data was recovered.

The usable-backup test is restoration plus comparison, not merely successful file creation, a nonzero size or a readable TOC. Three independent restore destinations and the comparisons in Part C/D supplied that evidence.
