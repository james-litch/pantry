# 001 — Create, list, and view recipes

Status: implemented
Dependencies: Existing Rails scaffold and verification workflow

The owner approved this spec and requested implementation. Verification evidence
is recorded below.

Draft PR: [#5 — Add recipe creation, listing, and details](https://github.com/james-litch/pantry/pull/5).

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

Quantity is optional to support ingredients such as salt and pepper without a
specified amount. When supplied, it must be a positive decimal number;
fractions are entered as decimals (e.g. 0.5). Unit is optional free text (e.g. g,
ml, tbsp); unitless counts are allowed. No unit catalogue, conversion, or scaling
is included. Blank quantities remain absent rather than becoming zero.

Preserve the submitted order of ingredient sections, entries within each section,
and preparation steps. Reopening saved data must retain those relationships and
orders. Explicit drag-and-drop reordering is not required for this first slice.

On validation failure, explain the errors and preserve the submitted values and
structure so the owner can correct them. Do not leave a partially saved recipe.
Treat recipe content as plain text and render it safely.

Retained input includes invalid quantity text, optional fields, and every submitted
section, ingredient, and step in its submitted order. Errors must identify the
affected field and row so repeated ingredient or step inputs can be distinguished.
Correcting a failed submission must not require rebuilding the recipe.

Use labelled inputs and keyboard-operable controls. Ensure the form and saved
result can be used at narrow mobile and desktop widths. No visual design has been
specified; use the existing Rails/Hotwire/Tailwind stack and conventional forms.
Follow the styling and interactivity guidance in `AGENTS.md`: Tailwind v4,
CSS-variable theme tokens in `app/assets/tailwind/application.css`, no `@apply`,
and Turbo/Stimulus for interactivity.

This is a single-owner feature for local/private access, with no per-user record
ownership yet. Do not describe the absence of sign-in as an access-control feature.

### Form interactions

- Open a new form with one blank ingredient section containing one ingredient row,
  and one blank preparation step. These are editable inputs, not saved records.
- Add new sections and steps at the end; add ingredients at the end of their
  containing section. A new section starts with one blank ingredient row.
- Removing a section also removes its unsaved ingredient rows. Removing a row
  retains the relative order of the remaining rows.
- Allow removal of the last section, ingredient, or step. Saving that incomplete
  structure produces the required-structure errors described above, with an add
  action available to correct it.
- After adding, focus the first input in the new row or section. After removing,
  move focus to a remaining control in the same group, or its add action, so
  keyboard users can continue editing.

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
  Errors identify the affected field and row, including when a later section or
  step is invalid. Correcting the errors and saving persists the complete recipe.
- AC5: Given recipe text containing HTML-like content, when the saved recipe is
  displayed, then it is treated as text rather than executable markup.
- AC6: Given the creation flow on desktop or mobile, when the owner navigates with
  a keyboard, then fields have labels, controls are usable, and errors are readable.
- AC7: Given no saved recipes, when the owner opens the homepage, then an empty
  state and creation action are shown. After saving recipes, the list shows them
  newest first and each links to its own detail page.
- AC8: Given a saved recipe, when its detail page is opened directly or refreshed,
  then all saved content is shown. A nonexistent recipe returns HTTP 404.
- AC9: Given separate ingredient fields, when a
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
  quantities rather than floating point. Follow the agreed amount conventions
  above; do not invent catalogue ingredient references.
- Recipe titles and ingredient names need not be unique. A recipe may repeat an
  ingredient across or within sections.
- Do not add placeholder users, inventory records, or catalogue entries for future
  features. Account migration and ingredient-catalogue linking need separate specs.

## Verification

- AC1–AC2: Integration/model tests for persistence, relationships, and ordering;
  a system test for creating and viewing a multi-section recipe.
- AC3: System test for initial rows and adding/removing nested form inputs without
  losing content. Cover append order, removal of a section with ingredients, and
  removal of the last row followed by validation and correction.
- AC4: Tests for the agreed required fields and atomic failure; a system test for
  correcting invalid input while retaining the rest of the form. Include an
  invalid ingredient in a later section and an invalid later step; verify no
  recipe, section, ingredient, or step records remain from either failed save.
  Verify invalid quantity text is retained, not replaced with zero or blank.
- AC5: Request or system test confirming recipe content is escaped on display.
  Cover title, description, section name, ingredient name, free-text unit, and
  step text, including script-like input.
- AC6: Browser inspection at mobile and desktop widths, including keyboard input,
  focus after adding/removing rows, labels, and validation errors; record evidence
  during implementation.
  Inspect the empty list, populated list, creation form, failed submission, and
  saved detail page. Check long content and multiple rows at both widths.
- AC7–AC8: Integration tests for list order, empty state, detail content, and 404;
  extend the creation system test to navigate from the list to the saved recipe.
- AC9: Model/integration tests for optional amounts, positive decimal persistence,
  and rejected invalid quantities; check display of unitless and absent amounts.
  Cover `0.5` with `tbsp`, `2` without a unit, no quantity with `to taste`, and
  salt and pepper entries with neither quantity nor unit. Reject `0`,
  `-1`, `abc`, and `1/2`; ensure failure retains the original amount inputs.
- Run `bin/ci` before handoff. Completed verification is recorded below.

## Open questions

None.

## Implementation evidence

Verified locally on 2026-10-22:

- AC1–AC2: `test/models/recipe_test.rb` and `test/integration/recipes_test.rb`
  cover atomic nested creation, section membership, persisted positions, and
  decimal/absent quantities. The creation system test saves two sections with
  multiple ingredients, then navigates from the list and refreshes the detail.
- AC3–AC4: `test/system/recipes_test.rb` covers initial rows, appending and
  removing every row type, removing a section with ingredients, focus placement,
  removal of the last rows, validation, and correction. Model tests assert that
  invalid later ingredients or steps leave all four record counts unchanged.
  Request and system tests retain optional fields and invalid quantity text.
- AC5: Request tests verify escaped title, description, section name, ingredient
  name, unit, and instruction, including script-like content on detail/list pages.
- AC6: Visually inspected empty/populated lists, new/invalid forms, and saved
  details at 390px mobile and 1400px desktop widths, including long content and
  multiple rows. Labels, readable errors, and lack of horizontal overflow are
  also checked by system tests. Manually used Enter to add/remove ingredients,
  checked focus movement, and corrected and saved a failed form in the browser.
- AC7–AC8: Request tests cover empty state, newest-first links, direct/repeated
  detail requests, and HTTP 404 for a missing recipe.
- AC9: Tests cover `0.5 tbsp`, unitless `2`, `to taste` without a quantity, and
  salt/pepper with neither amount field. `0`, `-1`, `abc`, `1/2`, non-finite values,
  and mixed number/text input are rejected without losing the original text.
- Database checks cover required text, positive finite quantities, nonnegative
  positions, unique positions within each parent, and foreign keys. Minimum child
  counts are enforced by model validation when saving the nested recipe.
- `bin/ci`: passed setup, RuboCop (38 files), gem/import-map audits, Brakeman
  (zero warnings), Rails tests (12 tests, 180 assertions), test seeds, and Chrome
  system tests (5 tests, 102 assertions). No failures, errors, or skips.
- Full-page screenshots can be regenerated with
  `VISUAL_REVIEW=1 bin/rails test test/system/recipes_test.rb --include=/AC6_responsive/`.
  This check also passed (1 test, 50 assertions); images are stored locally in
  `tmp/screenshots/recipes-*.png` and are not committed.

No known acceptance gaps remain. The feature remains scoped to local/private
access, with no accounts or saved-recipe editing/deletion. The migration adds
four tables and must run when setting up an existing checkout.
