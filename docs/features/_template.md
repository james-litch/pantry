# NNN — Feature title

Status: draft
Dependencies: None, or links to prerequisite feature specs

## Outcome

Who needs this, what can they do afterwards, and why does it matter?

## Scope

- Included behaviour.

## Non-goals

- Explicitly excluded behaviour.

## Behaviour

Describe the user journey, entry points, success result, validation, permissions,
and empty/error states. Include concrete examples where interpretation matters.
For UI work, describe content, interactions, keyboard use, and responsive behaviour.
Link a design reference if one exists.

## Acceptance criteria

- AC1: Given [starting state], when [action], then [observable outcome].
- AC2: Given [invalid input or failure], when [action], then [observable outcome].
- AC3: Given [unauthorised actor, if applicable], when [action], then [observable outcome].

## Data and constraints

Describe persistence, ownership, uniqueness, deletion, and migration requirements
where relevant. State constraints without prescribing unnecessary implementation.
Write "None" for sections that do not apply.

## Verification

- AC1: [automated test at the appropriate layer, or justified manual check].
- AC2: [automated test or manual check].
- AC3: [automated test or manual check].
- UI review: [screens/states to inspect, if applicable].

## Open questions

- Decisions needed before this spec can become ready. Write "None" when resolved.

## Implementation evidence

Complete during implementation: actual test paths, manual checks and outcomes,
verification commands/results, and known limitations. Link the PR if one exists.
Do not mark implemented while required criteria or checks remain unresolved.
