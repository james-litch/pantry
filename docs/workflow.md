# Building features from specs

## Draft and agree the behaviour

Read [product context](product.md), then copy [the template](features/_template.md)
to `docs/features/NNN-short-name.md`. Use the next available number. Keep each
feature small enough for one reviewable change; link prerequisite specs.

Draft specs describe proposed behaviour. Resolve material product questions with
the owner, then record their approval by changing the status to `ready`.
Approval in chat is sufficient; there is no separate sign-off ceremony.
An instruction to implement a specific, settled spec also authorises implementation.

Use observable acceptance criteria, including validation and permissions when
relevant. Keep implementation details flexible unless they are actual constraints.
Small fixes and documentation edits do not need a new feature spec; update an
existing spec if its promised behaviour changes.

## Implement and verify

1. Read the selected spec and relevant code. Confirm dependencies are available.
2. Map acceptance criteria to tests or explicit manual checks. Use a failing
   regression test where it usefully demonstrates the missing behaviour or bug.
3. Implement a complete slice using Rails conventions. Make routine technical
   choices autonomously; clarify material product ambiguities before dependent work.
4. Run affected tests while iterating, then `bin/ci`. Fix failures caused by the
   change. Record pre-existing failures or unavailable checks accurately.
5. For UI changes, inspect the actual browser flow, including error and empty
   states. Record what was checked; passing browser tests alone is not visual review.
6. Review the diff against each criterion. Update the spec with concise evidence
   and change its status to `implemented` only when all required work is verified.
7. Commit the feature changes on a `codex/` branch, push to the configured remote,
   and open a draft PR using the PR template. This handoff is authorised for
   approved feature work; the owner reviews and merges. Record the PR link in the
   spec. Do not include unrelated pre-existing changes in the commit.

If the remote is missing, request the repository destination and keep the verified
changes locally. Do not create a repository or select an account on the owner's
behalf without instruction. If a required check cannot run, report the gap and
leave the spec `ready`; a draft PR may still be opened with the limitation stated.

Minitest tests live in `test/`; prose specs live in `docs/features/`. Use model
tests for business rules, integration tests for requests and permissions, and
system tests for important browser journeys. Mention criterion IDs in test names
or comments when useful; avoid duplicating every assertion at every layer.

Keep product requirements in the spec and durable technical decisions in
`docs/decisions/`. Do not copy implementation plans and chat transcripts into the
repository. Update existing documentation when behaviour changes.

## Review

Review the implementation against the spec, not just whether tests pass. Look for
missing cases, access-control mistakes, unsafe migrations, and unintended scope.
Use the PR checklist when opening a PR. If a separate review agent is requested,
give it both the spec and the diff, and ask for actionable findings.

## Working concurrently

Use one branch/worktree per feature and agree ownership of overlapping changes.
Keep dependent work sequential. Set a unique `PANTRY_DATABASE_PREFIX` in each
worktree's shell before setup, running the app, or testing; see the README.
Use distinct server ports as well. A worktree alone does not isolate PostgreSQL.

## Example prompts

Draft a spec:

> Read docs/product.md and help me specify [feature]. Ask about missing product
> decisions. Save a draft using docs/features/_template.md. Do not implement it yet.

Implement a ready spec:

> Implement docs/features/NNN-short-name.md. Follow AGENTS.md, cover the acceptance
> criteria, run bin/ci, inspect any changed UI, and record verification evidence.
> Review the diff against the spec, then commit, push, and open a draft PR.
> Report remaining gaps; leave review and merge to me.

Review an implementation:

> Review the current diff against docs/features/NNN-short-name.md. Check acceptance
> coverage, permissions, migrations, and regressions. Report actionable findings
> with file references. Do not change code.
