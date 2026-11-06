# Part E – Recovery Evaluation and Report

**Project:** Group 02 – Park It  
**Date:** 6 November 2026

## Results

| Requirement | Result |
|---|---|
| Backup plan | Completed in [Part A](part_a.md), including schedule, retention, RPO/RTO and roles |
| Backup creation and inspection | Two custom archives created successfully; sizes, checksums and listing evidence in [Part B](part_b.md) |
| Separate restoration | Original backup restored into `parkit_a6_restore`; verification in [Part C](part_c.md) |
| Data and objects | Expected tables, records, sequences, indexes and constraints verified |
| Access control | Activity 4 roles/memberships retained; permitted reads succeeded and unauthorized writes/hash reads were denied |
| Application connection | PHP connected as the restricted runtime account; login/dashboard/monitoring succeeded |
| Recovery simulation | Disposable vehicle recovered exactly into `parkit_a6_recovered`; comparison in [Part D](part_d.md) |
| Preservation | Original database and both backup checksums remained unchanged |

**Overall: successful backup, restore and intended-record recovery, with the limitations below.**

## Evaluation and recommendations

Nightly logical backups with a proposed **24-hour RPO** and **60-minute RTO** are reasonable for a classroom/demo system if losing a day's changes is acceptable. The proposed retention is seven daily, four weekly and three monthly recovery points.

For real parking/payment operations, losing a day's entries or payments is likely unacceptable. Agree tighter targets with the owners, use more frequent recovery points or physical backups plus continuous WAL archiving/PITR, and test restoration with realistic data and application cutover.

The recovery snapshot restored the deleted vehicle but excluded the vehicle created afterwards. This demonstrates why a valid backup cannot recover changes outside its snapshot.

Store approved encrypted copies on durable independent storage, restrict access, monitor backup failures and test restoration regularly. The current archives are protected locally but are in `/tmp`, which is temporary and on the same host. The proposed retention/offsite policies have not been implemented.

## Issues and limitations

- Early inventory/bookkeeping script errors were corrected before continuing; the completed backup/restore operations succeeded. The original backup was preserved rather than overwritten.
- Two owner-only sequence ACLs changed catalog representation from explicit ACLs to PostgreSQL defaults. Their effective permissions were equivalent; no broad grants or error-suppression restore flags were added.
- Roles were verified in the existing cluster. A separate fresh-cluster migration was not tested; cluster roles/passwords and configuration are not contained in a single-database dump.
- Original operational tables were empty. The simulation used a disposable vehicle, not a populated production parking/payment workload.
- Existing Activity 4 application authorization and business-rule issues remain; restoration does not repair them.
- The local test does not prove production RTO, disaster recovery or point-in-time recovery. No production deployment or application cutover occurred.

## Submission status

These five Markdown files contain the plans, commands, output excerpts, verification and recommendations. Actual data-bearing backups remain outside Git. No other group's repository was modified.

Owner feedback is prepared in these reports but has not been sent. Tracker updates, the final submission PDF and commits have not been performed. The Activity 6 Log entry should record **Group 02 – Park It**, **Success with issues** for restoration, **Yes** for access verification, **Recovered** for the intended record, and the proposed **24-hour RPO / 60-minute RTO**.

## AI usage declaration

OpenAI Codex assisted with reading the instructions/source, preparing commands, executing local tests and writing the reports. Commands were checked for correct accounts, source/target databases and destructive scope. Results were validated through actual PostgreSQL output, restored records, constraints, allowed/denied operations and PHP connection/login checks. Credentials, password hashes and data-bearing backups were excluded from the submitted files.
