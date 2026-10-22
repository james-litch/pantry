# Pantry product brief

Status: initial product direction confirmed; first feature implemented

## Purpose and users

Pantry is a recipe app. Its initial user is the owner, who wants to create recipes
with a title, description, ingredient sections containing multiple ingredients,
and recipe steps. Individual user accounts are planned for a later release.

Personal use is the initial audience, not an authentication mechanism. The first
version assumes a local or otherwise privately accessible instance. Public access
and its authentication requirements need a separate decision before deployment.

## Initial scope

- Create, list, and view recipes. Editing/deletion are outside the first feature.
- Require a title and allow an optional description.
- Group recipe ingredients into sections, each able to contain many ingredients.
- Require at least one named section with ingredients and at least one recipe step.
- Enter ingredients using separate name, quantity, and unit fields.
- Allow optional positive decimal quantities and optional free-text units, as
  defined with the interaction details in the first spec.

## Terminology

- Recipe: a preparation with a title, description, ingredient sections, and steps.
- Ingredient section: a group of ingredients within a recipe.
- Recipe ingredient: an ingredient entry used in a particular recipe section.
- Recipe step: one instruction in the preparation sequence.
- Ingredient catalogue (future): reusable ingredient definitions, such as potatoes.
- Pantry inventory (future): the ingredients a user currently has available.

Recipe ingredient entries, catalogue ingredients, and pantry inventory have
different purposes. Do not treat creating a recipe as adding something to inventory.

## Future direction — outside the first feature

- Individual user accounts.
- Viewing which ingredients a user has in their pantry.
- A prepopulated ingredient catalogue available to all users, such as potatoes.
- The ability to add user-specific ingredients.

Keep this direction in mind when naming concepts, but do not build accounts,
inventory, catalogue seeding, or user-specific ingredient ownership speculatively.
Their permissions, relationships, and migration of existing data need future specs.

## Delivery preferences

Develop features from small, versioned specs. Once a feature spec is approved,
agents may implement, test, commit, push a feature branch, and open a draft PR.
The owner reviews and merges. Agents should not merge or deploy autonomously.
The existing stack is Rails, PostgreSQL, Hotwire, Tailwind, and Minitest.

## Feature specs

The first feature is [create, list, and view recipes](features/001-create-recipes.md),
implemented and verified. See [the workflow](workflow.md) for drafting, implementation, and
verification, and use [the template](features/_template.md) for later features.
