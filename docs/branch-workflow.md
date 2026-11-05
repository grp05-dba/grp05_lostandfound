# Documentation branch workflow

The documentation branch is `docs/project-documentation`. Keep documentation-only edits in `docs/`; the project lead reviews and decides when this branch is merged into `main`.

## Check the current branch

```powershell
git status
git branch --show-current
```

Confirm the working tree is clean or that you understand and have preserved any unfinished changes. Do not commit `.env`, provider credentials, database dumps, uploaded personal data, local runtime files or unrelated application changes.

## First checkout

```powershell
git clone https://github.com/grp05-dba/grp05_lostandfound.git
cd grp05_lostandfound
git fetch origin
git switch --track origin/docs/project-documentation
```

If the local branch already exists, use `git switch docs/project-documentation`.

## Synchronize with main before documenting new behavior

Start with a clean working tree. Commit completed documentation changes or save unfinished work separately. Then:

```powershell
git switch docs/project-documentation
git fetch origin
git merge --ff-only origin/docs/project-documentation
git merge origin/main
```

This brings current application code into the documentation branch so the docs can be checked against the same source. It does not merge documentation into main. Inspect merge results before editing. Resolve documentation conflicts carefully; ask the project lead about product/schema decisions. Do not force-push or reset away another contributor's work.

## Update, validate and push documentation

```powershell
git diff -- docs
git add docs
git diff --cached --check
git diff --cached --stat
git commit -m "docs: update project documentation"
git push -u origin docs/project-documentation
```

Review the staged file list before committing. Keep changes focused on the documentation. If the branch includes a merge from main, application files may appear in that merge commit; do not independently modify them as part of a documentation task.

## Review and handoff

When the documentation set is ready, open a pull request from `docs/project-documentation` into `main`. Include the source revision reviewed, pages changed and checks actually performed. The project lead handles final review and merge.

## Terms

- **Fetch** downloads remote references without changing the working files.
- **Commit** records a set of changes in repository history.
- **Push** publishes local commits to the remote branch.
- **Merge main into docs** updates the documentation branch with current application source.
- **Merge docs into main** is a separate review/approval step for the project lead.
