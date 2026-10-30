# Documentation branch workflow

The project lead requested a dedicated branch for documentation. This checkout uses `docs/project-documentation`, based on the current main branch. The documentation maintainer works there; the lead decides when to merge it into main.

## Check your location before editing

```powershell
git status
git branch --show-current
```

Confirm you are on docs/project-documentation and understand any uncommitted files. Keep new project documentation under docs/. Do not commit .env, credentials, database dumps, local runtime files or unrelated application edits.

## First checkout on another machine

```powershell
git clone https://github.com/grp05-dba/grp05_lostandfound.git
cd grp05_lostandfound
git fetch origin
git switch --track origin/docs/project-documentation
```

The branch has already been created for this workflow; do not recreate it on top of an old checkout. If a local branch already exists, use `git switch docs/project-documentation`.

## Bring main into the documentation branch

Start with a clean working tree: commit completed documentation edits first, or preserve unfinished work separately. Then:

```powershell
git switch docs/project-documentation
git fetch origin
git merge --ff-only origin/docs/project-documentation
git merge origin/main
```

The first merge gets any remotely published updates to this same branch without creating an accidental divergent merge. The second integrates main into the documentation branch. This does not merge the documentation branch into main.

After the merge, inspect changed controllers, services, repositories, entities, integration files, schema and main's recent commits. Update affected docs and their reviewed revision/date. Resolve documentation conflicts by preserving the current application behavior; if a merge conflict requires a product/schema decision, ask the lead. To cancel an unresolved merge, use `git merge --abort`.

Do not force-push or reset away teammates' work to resolve a conflict.

## Commit and push documentation

```powershell
git diff -- docs
git add docs
git diff --cached --check
git diff --cached --stat
git commit -m "docs: update API and database references"
git push -u origin docs/project-documentation
```

Check the staged file list before committing: it should contain the intended docs changes. Incoming main changes may include application files as part of main's merge; do not independently edit those files in this documentation task.

## Review and handoff

Open a draft pull request from docs/project-documentation into main when there is a concrete set of pages to review. Describe the source revision, documentation scope and actual validation. The lead handles final review, approval and merging when the docs are ready.

Keep this branch available while the lead wants it maintained. Do not delete it just because an older feature branch was merged. Repeat the main-into-docs synchronization before the next documentation update.

## What to learn from this workflow

- A branch is a separate line of work in the same repository.
- A commit records a reviewed set of changes locally.
- A push publishes those commits to the corresponding remote branch.
- Fetch reads remote updates; it does not overwrite the working tree.
- Merging origin/main while on the documentation branch brings app changes into that branch.
- Merging the documentation branch into main is the lead's separate action.
