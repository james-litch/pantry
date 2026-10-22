# 001 — Create, list, and view recipes

Status: draft
Dependencies: Existing Rails scaffold and verification workflow

## Outcome

The owner can save a recipe with a title, description, ingredient sections, and
preparation steps, keeping the information needed to prepare it together.

## Scope

- Create and persist a recipe.
- List saved recipes and view an individual recipe.
- Require a title; allow an optional description.
- Support multiple ingredient sections, each containing multiple ingredient entries.
- Require at least one named ingredient section, with at least one ingredient in
  every section, and at least one preparation step.
- Enter ingredients using separate name, quantity, and unit fields.
- Support an ordered sequence of recipe steps.
- Confirm the saved result after successful creation.

## Non-goals

- User accounts, sign-in, and multi-user permissions.
- Editing or deleting saved recipes.
- Pantry inventory and tracking what ingredients are available.
- Shared ingredient catalogue, prepopulated ingredients, and user-specific
  catalogue ingredients.

## Behaviour

The homepage lists saved recipes by newest first, with links to recipe details
and a clearly labelled action to create a recipe. When there are no recipes, show
an empty state with the creation action. Pagination and search are outside this slice.

The owner opens a recipe creation form and enters a title, optional description,
named ingredient sections with their ingredients, and preparation steps. Each
ingredient has separate name, quantity, and unit inputs. The form supports adding
and removing unsaved sections, ingredient entries, and steps without losing other
entered content. Save persists the entire recipe together and opens its detail
page. The detail page displays title, description if supplied, named ingredient
sections, ingredient amounts, and numbered steps, with navigation back to the list.
A nonexistent recipe URL returns a not-found response.

The required title, section names, ingredient names, and step text reject empty or
whitespace-only values. A section cannot be empty, and a recipe cannot have no
sections or no steps. Invalid submitted rows produce errors rather than silently
disappearing. Removing unsaved rows is an explicit form action.

Proposed amount conventions for review: quantity is optional to support ingredients
such as "salt, to taste". When supplied, it must be a positive decimal number;
fractions are entered as decimals (e.g. 0.5). Unit is optional free text (e.g. g,
ml, tbsp); unitless counts are allowed. No unit catalogue, conversion, or scaling
is included. Blank quantities remain absent rather than becoming zero.

Preserve the submitted order of ingredient sections, entries within each section,
and preparation steps. Reopening saved data must retain those relationships and
orders. Explicit drag-and-drop reordering is not required for this first slice.

On validation failure, explain the errors and preserve the submitted values and
structure so the owner can correct them. Do not leave a partially saved recipe.
Treat recipe content as plain text and render it safely.

Use labelled inputs and keyboard-operable controls. Ensure the form and saved
result can be used at narrow mobile and desktop widths. No visual design has been
specified; use the existing Rails/Hotwire/Tailwind stack and conventional forms.

This is a single-owner feature for local/private access, with no per-user record
ownership yet. Do not describe the absence of sign-in as an access-control feature.

## Acceptance criteria

- AC1: Given the creation form, when the owner submits a valid recipe, then the
  recipe and all its sections, ingredients, and steps are saved and the saved
  result is shown.
- AC2: Given a recipe with two sections, each with multiple ingredients, when it
  is saved and loaded again, then ingredients remain in their original sections
  and the section, ingredient, and step order is preserved.
- AC3: Given an unfinished form, when the owner adds or removes an unsaved section,
  ingredient, or step, then other entered content is retained and the saved result
  includes exactly the submitted structure.
- AC4: Given input that violates an agreed validation rule, when Save is selected,
  then the form shows relevant errors, retains entered values, and saves no partial
  recipe. Missing/blank title, section name, ingredient name, or step text; empty
  sections; no sections; and no steps are invalid. A blank description is valid.
- AC5: Given recipe text containing HTML-like content, when the saved recipe is
  displayed, then it is treated as text rather than executable markup.
- AC6: Given the creation flow on desktop or mobile, when the owner navigates with
  a keyboard, then fields have labels, controls are usable, and errors are readable.
- AC7: Given no saved recipes, when the owner opens the homepage, then an empty
  state and creation action are shown. After saving recipes, the list shows them
  newest first and each links to its own detail page.
- AC8: Given a saved recipe, when its detail page is opened directly or refreshed,
  then all saved content is shown. A nonexistent recipe returns HTTP 404.
- AC9 (proposed amount conventions): Given separate ingredient fields, when a
  quantity is supplied, then a positive decimal such as 0.5 is saved without
  rounding to an integer; zero, negative, and nonnumeric values fail validation.
  Missing quantity or unit is allowed, and absent amounts produce no stray zero
  or placeholder text in the recipe display.

## Data and constraints

- Persist recipe title and description, ingredient section membership, ingredient
  entries, and recipe steps.
- Preserve ordered parent/child relationships with database referential integrity.
- Creation is atomic: failure in any section, ingredient, or step saves none of the
  submitted recipe.
- Store ingredient name, quantity, and unit separately. Use decimal storage for
  quantities rather than floating point. Follow the proposed amount conventions
  above if approved; do not invent catalogue ingredient references.
- Recipe titles and ingredient names need not be unique. A recipe may repeat an
  ingredient across or within sections.
- Do not add placeholder users, inventory records, or catalogue entries for future
  features. Account migration and ingredient-catalogue linking need separate specs.

## Verification

- AC1–AC2: Integration/model tests for persistence, relationships, and ordering;
  a system test for creating and viewing a multi-section recipe.
- AC3: System test for adding/removing nested form inputs without losing content.
- AC4: Tests for the agreed required fields and atomic failure; a system test for
  correcting invalid input while retaining the rest of the form.
- AC5: Request or system test confirming recipe content is escaped on display.
- AC6: Browser inspection at mobile and desktop widths, including keyboard input,
  focus, labels, and validation errors; record evidence during implementation.
- AC7–AC8: Integration tests for list order, empty state, detail content, and 404;
  extend the creation system test to navigate from the list to the saved recipe.
- AC9: Model/integration tests for optional amounts, positive decimal persistence,
  and rejected invalid quantities; check display of unitless and absent amounts.
- Run `bin/ci` before handoff. These are planned checks, not completed verification.

## Open questions

Review the proposed amount conventions: optional positive decimal quantity and
optional free-text unit, with no fractions parser or conversions. The owner has
confirmed separate ingredient fields, required recipe structure, and create/list/
view scope. Interaction details and amount conventions are proposals until the
owner approves this draft or requests its implementation.

## Implementation evidence

Not implemented. The project foundation has boot and browser smoke tests, which
do not verify this feature. Record actual coverage and results here when built.
