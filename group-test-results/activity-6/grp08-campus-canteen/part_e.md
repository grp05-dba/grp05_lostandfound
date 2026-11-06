# Part E - Recovery Evaluation and Report

**Project:** Group 08 - Campus Canteen Pre-Order and Queue Management System. **Date:** 6 November 2026, Asia/Manila.

## Results

| Requirement | Actual outcome |
|---|---|
| Backup plan | Objects, account, protected local storage, verification, proposed schedule/retention and RPO/RTO in [Part A](part_a.md) |
| Initial and fixture backups | Custom-format archives created by `canteen_admin`, inspected, sized and SHA-256 checked; [Part B](part_b.md) |
| Separate original restore | `g05_a6_g08_restore` verified against source data/schema/access policy; [Part C](part_c.md) |
| Verified simulation backup | Independently restored to `g05_a6_g08_snapshot` before loss was simulated |
| Controlled incident/recovery | Only test marker deleted; intended row recovered into `g05_a6_g08_recovered`; [Part D](part_d.md) |
| Privilege checks | Actual runtime/report reads allowed; reporting writes denied; effective table/column/sequence/function permissions compared |
| Application reconnection | Actual component/JDBC/HTTP checks against initial restored and recovered targets; scope recorded in Part C |
| Preservation | Source data/schema/sequence/access fingerprints and both archive checksums preserved |

**Overall: successful backup, restoration and intended-record recovery, with documented issues/limits.** Source/target names and commands contain no credentials; actual data-bearing archives stay in the protected local directory outside Git.

## Sufficiency and recommendations

The proposed classroom policy is a nightly logical backup, **24-hour RPO** and **60-minute RTO**, retaining seven daily/four weekly/three monthly points. This can suit a demonstration only if losing a day's changes is acceptable. It is not automatically sufficient for food ordering and payments in actual operation.

The simulation proves the snapshot can recover the intended deleted fixture and excludes post-snapshot changes. Agree production objectives with the owners; consider more frequent tested logical recovery points or physical backups plus continuous WAL archiving/PITR when a much tighter RPO is required. A real RTO must include roles/extensions, infrastructure, data validation, application reconnection, stakeholder approval and cutover—not just the observed local pg_restore time.

Keep independent encrypted copies on approved storage, restrict OS access, monitor failures and conduct regular restore drills. Local ACL protection does not equal encrypted/offsite disaster recovery. Proposed schedules/retention/encryption were not installed or claimed as operational services.

## Issues and limitations

- The existing local Activity4/5 evaluation instance was used; it is not a production owning-group deployment.
- Dump/reparse moved casts in some enum/array predicates without changing their meaning. Narrow semantic normalization and applicable negative enum probes were used; raw ACL representation alone was not used as a substitute for effective permission checks.
- Preparation comparisons/probe bookkeeping were corrected before final verification; one initially overlong invalid enum marker tested length instead of CHECK, then was replaced by a short invalid value. Final recorded probes assert the intended SQLSTATE. No restore errors were hidden by broad error-suppression flags.
- Restore authority is explicit: objects as DBA/owner, login-creator defaults as that login where present, and bootstrap-owned extension ACLs as provisioning administrator only where required. Each phase is atomic separately, not one globally atomic restore.
- Cluster roles remain available here. Fresh-cluster role recreation SQL is supplied but that separate migration was not tested. Per-database target policy/settings were applied explicitly; a single-database archive does not replace cluster/configuration/OS backup.
- The source is a small sample dataset, with empty workflow tables where present. The disposable fixture adds controlled coverage, not a realistic production transaction stream. No benchmark, production RTO, failover/cutover or PITR is claimed.
- Existing application authorization/integrity limitations from Activity4 are preserved, not repaired by restoration. Application verification scope is stated precisely in Part C.

## Submission and AI usage

These five reports, safe SQL, archive metadata/checksums, actual account tests and comparison evidence are stored only in Group 5's repository. No owning group's tracked source was modified or pushed. Existing Group2 reports are preserved; the new independent tests cover this project only.

No owner feedback message, tracker edit, final progress PDF submission or classroom submission was performed in this task. Reports provide the evidence for those subsequent steps. Restoration should be logged **Success with issues**, access verification **Yes**, intended-record recovery **Recovered**, with the proposed 24-hour RPO/60-minute RTO. Full course submission is not claimed merely because these files exist.

**AI usage:** OpenAI Codex read the Activity6 PDF/Group2 reference, reviewed setup/role sources, prepared/provisioned isolated prerequisites where necessary, executed logical backup/restore/recovery and application-connection checks, and wrote these reports. Validation checked exact source/target scope, archive integrity, complete row equality in memory without publishing row payloads, schema/sequence/constraint/ownership/effective privilege comparisons, positive/negative account behavior and marker states. No human validation is claimed. Credentials, password hashes, raw row payloads and data-bearing backups were excluded from submitted evidence.

Official tool references: [pg_dump](https://www.postgresql.org/docs/18/app-pgdump.html), [pg_restore](https://www.postgresql.org/docs/18/app-pgrestore.html).
