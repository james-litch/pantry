# Working on Pantry

## Context

- Rails 8.1, PostgreSQL, Hotwire/import maps, Tailwind, and Minitest.
- Use `README.md` for setup and commands, `docs/product.md` for product intent,
  and `docs/workflow.md` when drafting or implementing a feature.
- Feature contracts live in `docs/features/`; read the selected spec and its
  dependencies. Consult `docs/decisions/` when a relevant technical decision exists.
- Read what the task needs; do not load every spec or document for every edit.

## Feature work

- Start new features from an agreed spec (`ready`) or explicit implementation
  instructions. Draft specs are proposals, not permission to invent requirements.
- Clarify material product ambiguities before dependent work. Make routine
  technical choices independently and continue all unblocked work.
- Follow Rails conventions and existing patterns; keep changes focused. Use the
  existing stack unless the task calls for a change. Avoid speculative abstractions.
- Use migrations for database changes and include resulting schema changes.
  Enforce important data invariants at the database level where appropriate.
- Cover observable acceptance criteria, relevant validation, permissions, and
  failure cases. Never weaken requirements or tests to hide a failing implementation.
- Update the spec with actual verification evidence and any agreed behaviour changes.
  Mark `implemented` only once all required criteria and checks are satisfied.
- Small fixes and documentation changes need no new spec. Record significant,
  lasting technical choices in `docs/decisions/`, not routine implementation steps.

## Styling and interactivity

- Use Tailwind CSS v4 and its CSS-first configuration conventions. Prefer utility
  classes in templates and follow the installed v4 version's best practices.
- Define all custom theme tokens as CSS variables in
  `app/assets/tailwind/application.css`. Use top-level `@theme` for tokens that
  generate Tailwind utilities; use `:root` for variables that do not need utilities.
  Reuse tokens through utility classes or `var(--token-name)` in custom CSS.
  See the [Tailwind theme documentation](https://tailwindcss.com/docs/theme).
- Do not use `@apply`. Do not edit the generated `app/assets/builds/tailwind.css`.
- Use Turbo for navigation, form submissions, and server-rendered updates, with
  Frames or Streams where appropriate. Use Stimulus controllers for client-side
  interactions such as nested form rows and focus management. Keep controllers
  compatible with Turbo navigation and use the existing import-map setup.

## Verification and handoff

- Setup: `bin/setup --skip-server`. Development: `bin/dev`.
- Run affected Minitest tests during implementation; use `bin/ci` for the complete
  handoff check. It includes style, audits, Rails tests, test seeds, and system tests.
- Local tests use disposable test data. Run them and fix change-related failures
  without repeatedly asking permission, subject to tool execution permissions.
- Inspect changed user flows in the browser, including empty/error states. Report
  unavailable checks and pre-existing failures honestly; do not claim they passed.
- Finish with changed behaviour, spec/acceptance coverage, verification results,
  and remaining risks or gaps. Approved feature work includes authorisation to
  commit, push a `codex/` feature branch, and open a draft PR for owner review.
- Use the configured repository remote. If none exists, report the missing
  destination and request it; do not create a remote repository without instruction.
- Do not merge, publicly release, or deploy without user authorisation. Do not
  access production data or commit credentials, keys, or local environment files.
- Concurrent work needs separate worktrees, database prefixes, and server ports;
  see the README. Coordinate overlapping changes before editing shared files.
