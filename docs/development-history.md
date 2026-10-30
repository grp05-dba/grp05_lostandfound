# Development history and verification

Documentation reviewed October 31, 2026 against main revision `17dfae5`. Milestones below come from Git history and local verification records, not an assumption that every planned feature is complete.

| Date | Revision / event | Result |
| --- | --- | --- |
| Oct 27-28 | Early controller, service and repository commits | PDO connectivity, item listing and category retrieval established |
| Oct 28 | 5fcbccd | SMS service and TextBee gateway-information routes added |
| Oct 29 | 3a11b92 | Standalone EmailJS client added |
| Oct 29 | 85f5cea | docs folder introduced |
| Oct 30 | 2b9346b, merged through PR #23 / 5aaac06 | Five administrative retrieval routes added; lead-requested integer conversion and unsorted queries retained |
| Oct 30 | 17dfae5 | Controller prefix removal aligned with category style; Claim, Item and LostReport entity classes added |
| Oct 31 | Documentation branch | Current setup, API, architecture, schema, role mapping and branch workflow documented for review |

PR #22, the earlier setup-documentation proposal, was closed without merge. Its content is not a claim about main. Earlier course files were temporarily kept outside the app repo; the lead's later direction places maintained project documentation under docs on its own branch.

## Verification already performed

On October 30, local checks of the merged retrieval implementation passed 29 retrieval requests / 55 assertions and seven baseline requests / 14 assertions. The tests followed the lead's integer-coercion contract rather than asserting strict 400 validation. The empty-list helper passed using a transaction that rolled its temporary deletions back. Raw helper scripts and logs remain outside this documentation branch.

The local database contained one supplied seed record per table. A separate local DBA rehearsal verified restored row counts/content hashes, constraint metadata, rejection of invalid statuses, permitted SELECT/UPDATE and denied CREATE TABLE for the runtime role. Recovery was performed on disposable copies and left the source database unchanged. This is rehearsal evidence, not completed cross-group Activities 4-6.

Previous TextBee success-path tests used a local stub. No live SMS or email delivery is verified. The EmailJS client and entity constructors require integration before they become an end-to-end workflow.

## Current review limits

On October 31, revision 17dfae5 passed syntax checks for all 18 application PHP files. The separate read-only Postman collections passed 29 retrieval requests / 55 assertions and seven baseline requests / 14 assertions: 36 requests, 69 assertions, zero failures. The docs' 27 relative file links and code-fence pairing were also checked. No sample-data reload, external messaging, schema change or application-code edit was needed for this documentation update.

These HTTP checks cover seeded retrieval, missing records, integer coercion, namespace rejection and existing health/category routes. They do not validate the unused entity constructors as an integrated workflow, EmailJS delivery or every error condition. Read the [API](api.md), [architecture](architecture.md) and [schema](database.md) references for the source behavior.

This documentation does not establish a full working frontend, write flows, matching, notification delivery, independent installation on every group's machine, instructor approval, or midterm completion. Other groups' actual repositories, instructor pairings and required evidence must be obtained and tested.

## AI assistance

OpenAI Codex assisted with source/history inspection, documentation drafting and local verification. Previously submitted PHP retrieval work was tested and reviewed through PR #23. The project lead and team retain responsibility for reviewing the docs, validating claims and explaining their work in the course defense.

## Keeping this history accurate

Add a dated milestone tied to a real commit or test record when main changes. Preserve past results with their dates; do not present a previous test run as evidence for a later untested revision. See [branch workflow](branch-workflow.md) for synchronization and review.

