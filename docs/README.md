# PUP-SPOT documentation

Group 5's lost-and-found API documentation. Reviewed October 31, 2026 against application revision `17dfae5` on `main`. These pages describe the checked-in implementation; planned behavior is labeled separately.

| Start here | What it explains |
| --- | --- |
| [Setup](setup.md) | Clone, database initialization, PHP configuration, and local startup |
| [API reference](api.md) | Implemented routes, responses, ID conversion, and current limits |
| [Architecture](architecture.md) | Request flow and responsibilities of each folder |
| [Database](database.md) | Five tables, constraints, relationships, and seed behavior |
| [Application and database roles](user-roles.md) | Intended workflows versus permissions actually implemented |
| [Development history](development-history.md) | Source-backed milestones and verification scope |
| [Documentation branch workflow](branch-workflow.md) | Commit, push, pull, and merge main into this branch |

The application currently provides database-backed retrieval and TextBee gateway-information routes. It does not yet provide a frontend, write endpoints, cancellation workflows, or automatic matching. The EmailJS client and entity classes exist as foundations, not completed end-to-end workflows.

The documentation branch is `docs/project-documentation`. Changes stay under `docs/`; the project lead reviews and merges this branch into `main` when ready. This supersedes the earlier temporary arrangement where course notes were held only outside the repository. Credentials, database dumps, local runtime files, and raw test logs remain outside Git.

The [root setup README](../README.md) and [Activity 2 proposal linked there](../README.md#additional-project-resources) remain unchanged. This documentation does not revise the submitted proposal or certify course completion.

