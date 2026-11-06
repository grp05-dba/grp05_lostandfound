# Part B - Identify Users, Group Roles, and Privileges

## 1. Objective

Define PostgreSQL access from CampusSafe's implemented models and documented runtime, auditor, backup and administrative responsibilities. The account matrix was selected before provisioning. Human web roles and PostgreSQL login/group roles remain separate.

## 2. Accounts and groups

| Login | NOLOGIN group | Application role served | Responsibilities |
|---|---|---|---|
| `campussafe_app` | `campussafe_runtime_grp` | Shared PHP service for authenticated reporters, technicians, admins and web auditors | Only the existing application's table operations and eight insert sequences |
| `campussafe_report` | `campussafe_readonly_grp` | External SQL safety auditor/BI account; not a separate web connection | SELECT on eight approved non-credential tables; no app_user access |
| `campussafe_backup` | `campussafe_backup_grp` | Documented logical-backup operator | SELECT all nine current tables, including credentials, and SELECT all sequence states; no writes |
| `campussafe_dba` | `campussafe_owner_grp` | Project database administration, not the web Administrator | Project database/schema/object ownership through group membership, migration and approved data maintenance |

A separate local provisioning administrator creates databases/roles and assigns passwords. All eight CampusSafe roles lack SUPERUSER, CREATEDB, CREATEROLE, REPLICATION and BYPASSRLS. Each login has only its intended membership and no ADMIN OPTION. Groups cannot log in; logins inherit their group's object privileges. Only the DBA can SET ROLE to the project owner.

The owner-group DBA is trusted within this project and can change or drop its objects and grants. It is not a cluster administrator and cannot access unrelated project databases through the evaluated connections. That owner credential is never used for ordinary PHP traffic.

## 3. Runtime, auditor and backup table matrix

| Table | Runtime SELECT | INSERT | UPDATE | DELETE | SQL auditor SELECT | Backup SELECT |
|---|---|---|---|---|---|---|
| `role` | Yes | No | No | No | Yes | Yes |
| `app_user` | Yes | Yes | Yes | No | **No** | Yes |
| `hazard_category` | Yes | Yes | Yes | No | Yes | Yes |
| `campus_location` | Yes | Yes | Yes | No | Yes | Yes |
| `hazard_report` | Yes | Yes | Yes | No | Yes | Yes |
| `assignment` | Yes | Yes | Yes | No | Yes | Yes |
| `report_status_history` | Yes | Yes | No | No | Yes | Yes |
| `maintenance_action` | Yes | Yes | No | No | Yes | Yes |
| `attachment` | Yes | Yes | No | Yes | Yes | Yes |

Runtime hash access is necessary for password verification; user INSERT/UPDATE is necessary for the current administrator model. The SQL auditor cannot read any app_user columns, so cannot dump password hashes. It can read the role dictionary to interpret role codes, but direct joins needing app_user names require an additional approved safe reporting design.

The backup operator intentionally has more read access than the auditor. A complete logical backup contains app_user credentials and must not be treated as a public report. The actual backup test writes its dump only to local scratch storage; the deliverable includes metadata, not the sensitive dump or data rows.

Hard DELETE is not assigned for users, reports, categories or locations; these are deactivated/closed. Report deletion would cascade to history/actions/assignments/attachments and is reserved to the trusted owner. Runtime assignment DELETE from the upstream script is omitted because the reviewed application only inserts/upserts/updates assignments. Attachment DELETE is supported by its model.

No runtime/auditor/backup TRUNCATE, REFERENCES, TRIGGER, MAINTAIN, DDL, ownership or grant authority is assigned. Backup and auditor accounts have no table writes at all.

## 4. Sequence matrix

| Sequence | Runtime | SQL auditor | Backup |
|---|---|---|---|
| `role_role_id_seq` | None | None | SELECT |
| `app_user_user_id_seq` | USAGE | None | SELECT |
| `hazard_category_category_id_seq` | USAGE | None | SELECT |
| `campus_location_location_id_seq` | USAGE | None | SELECT |
| `hazard_report_report_id_seq` | USAGE | None | SELECT |
| `assignment_assignment_id_seq` | USAGE | None | SELECT |
| `report_status_history_history_id_seq` | USAGE | None | SELECT |
| `maintenance_action_action_id_seq` | USAGE | None | SELECT |
| `attachment_attachment_id_seq` | USAGE | None | SELECT |

Runtime USAGE supports generated IDs without sequence reset authority. Backup SELECT reads last values for pg_dump but does not permit nextval/setval. The DBA owner group controls all sequences.

## 5. Database/schema/future-object policy

The three service/inspection groups receive CONNECT only to `grp07_campussafedb` and USAGE on `public`. They have no database CREATE/TEMPORARY or schema CREATE. The owner DBA inherits owner rights. PUBLIC project database/schema/table/sequence access is revoked; inherited memberships and other databases' PUBLIC ACLs are inspected separately.

Actual connections from all four CampusSafe logins to the unrelated test database, Group 4 and Group 6 databases, postgres and template1 are denied. Reverse tests deny six prior-project logins access to CampusSafe while preserving each previous runtime's legitimate own-database access.

Future tables/sequences receive no automatic runtime, auditor or backup grants. Owner-created future functions lose PUBLIC EXECUTE. Migrations must run as the designated owner and review each new object's grants, including whether backup access is required. Otherwise a future complete backup may fail instead of silently obtaining access to new sensitive objects. These default privileges apply to the creator role, not every possible object creator.

## 6. Human web roles and remaining boundary

Student and Faculty/Staff reporters submit and inspect their own reports; Maintenance handles assigned work; Administrator verifies/dispatches/manages master data; Auditor is documented as read-only. All of these web roles use campussafe_app, which necessarily has combined service permissions. No PostgreSQL row-level policy identifies individual HTTP users.

Server-side authentication, CSRF and ownership checks must therefore enforce human access. The evaluation found gaps in Auditor submission, technician start-work ownership and attachment authorization. The separate database read-only account works as planned, but cannot repair those web guards automatically. No complete per-human security guarantee is made from the role names alone.
