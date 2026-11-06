# Part B – Create and Inspect a Backup

## Backup creation

Backups were executed on **6 November 2026** using PostgreSQL 18.6 and Activity 4 account **`parkit_dba`**. Passwords were supplied through private local configuration, not command arguments or submitted files.

Original database:

```sh
pg_dump -w -h 127.0.0.1 -p 55442 -U parkit_dba -Fc -d grp_parkitdb -f /tmp/activity6-grp02-private/backups/grp_parkitdb_activity6.dump
```

A second backup was created from the restored test database after adding the disposable recovery vehicle described in Part D:

```sh
pg_dump -w -h 127.0.0.1 -p 55442 -U parkit_dba -Fc -d parkit_a6_restore -f /tmp/activity6-grp02-private/backups/parkit_a6_fixture_activity6.dump
```

Both commands completed with **exit 0 and no error output**.

| Backup file | Source | Creation time, Asia/Manila | Size |
|---|---|---|---:|
| `grp_parkitdb_activity6.dump` | `grp_parkitdb` | 6 Nov 2026, 22:14:27 | 21,459 bytes |
| `parkit_a6_fixture_activity6.dump` | `parkit_a6_restore` | 6 Nov 2026, 22:17:20 | 21,542 bytes |

## Checksums

Run `sha256sum` against the two files. Recorded and subsequently rechecked output:

```text
a737e2fbd25bd3a1c45242fcfef699dbe361f5fb652c05411ead33603d7c3810  grp_parkitdb_activity6.dump
717b54d9c27e5a696613fd6d0915b06713f20e32baabecacdd0379a748892064  parkit_a6_fixture_activity6.dump
```

Both files remain outside the repository in the protected directory listed above. They contain data, including authentication hashes, and must not be published. No actual password or hash value is included in these reports.

## Archive inspection

```sh
pg_restore --list /tmp/activity6-grp02-private/backups/grp_parkitdb_activity6.dump
pg_restore --list /tmp/activity6-grp02-private/backups/parkit_a6_fixture_activity6.dump
```

Both listings completed successfully. Original archive header excerpt:

```text
Archive created at 2026-11-06 22:14:27 PST
    dbname: grp_parkitdb
    TOC Entries: 70
    Compression: gzip
    Format: CUSTOM
    Dumped from database version: 18.6
    Dumped by pg_dump version: 18.6
```

The listings include the five table definitions/data entries, five sequence definitions/states, constraints, foreign keys, ownership, table/column grants and default privileges. TABLE DATA entries can represent empty tables.

An archive existing or having a readable listing does not prove recovery. It must be restored and its data, objects and permissions verified, as performed in [Part C](part_c.md).
