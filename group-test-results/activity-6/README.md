# Activity 6 - Backup, Restore and Recovery

Group 5 evaluation reports, executed on 6 November 2026 (Asia/Manila).

| Project | Reports | Verification |
|---|---|---|
| G02 ParkIt | [Parts A-E](grp02-parkit/part_a.md) | Existing team reports preserved; not independently rerun in this work |
| G03 OJT | [Part A](grp03-Project-OJT-RMA-System/part_a.md) | Independently tested, Parts A-E and evidence included |
| G04 BrewPOS | [Part A](grp04-brewpos/part_a.md) | Independently tested, Parts A-E and evidence included |
| G06 HabalGo | [Part A](grp06-habalgo/part_a.md) | Independently tested, Parts A-E and evidence included |
| G07 CampusSafe | [Part A](grp07-campussafe/part_a.md) | Independently tested, Parts A-E and evidence included |
| G08 Campus Canteen | [Part A](grp08-campus-canteen/part_a.md) | Independently tested, Parts A-E and evidence included |
| G10 MESA | [Part A](grp10-mesa/part_a.md) | Independently tested, Parts A-E and evidence included |
| G11 BoardTrack | [Part A](grp11-boardtrack/part_a.md) | Independently tested, Parts A-E and evidence included |

Each new project folder contains `part_a.md` through `part_e.md`, safe SQL and recorded evidence. Part C describes application verification precisely: some projects were checked through HTTP; others through their actual database connection component or Java headless harness. These checks do not establish a complete interactive UI test.

For each of the seven independently evaluated projects, two custom-format archives were created and checked. Three separate target databases were used for the initial restore, independent snapshot verification, and recovery. The controlled incident deleted only a disposable fixture from the initial restored copy. Recovery restored that fixture and correctly excluded a row added after the backup. Source preservation, complete recovered row equality, schema, sequence state, ownership, effective privileges, allowed reads and denied reporting writes were checked. See [final validation results](validation-summary.json) and each project's `evidence/final_validation.json`.

Data-bearing archives remain in protected local storage outside Git. Evidence excludes credentials, authentication hashes and raw sample row payloads. Fresh-cluster role scripts are supplied as templates; migration to an entirely new cluster was not tested. Nightly scheduling, retention, encrypted offsite storage, production RPO/RTO and PITR remain proposals, not installed services.

This repository update does not submit a final progress PDF, edit the class tracker, contact project owners or submit to Classroom. Group 2's existing files and the documentation branch remain unchanged.
