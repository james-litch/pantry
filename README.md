# Pantry

A recipe app, initially for personal use, developed through small, versioned
feature specs. Recipes have a title, description, ingredient sections, and steps.
Start with [product context](docs/product.md) and [the feature workflow](docs/workflow.md).
Agents should follow [AGENTS.md](AGENTS.md).

Repository: [james-litch/pantry](https://github.com/james-litch/pantry).

## Local setup

Prerequisites:

- Ruby from `.ruby-version` (currently 4.0.6), with Bundler.
- PostgreSQL running locally, with a role matching your operating-system user that
  can create databases. The default connection uses a local Unix socket.
- PostgreSQL client libraries for the `pg` gem; libvips for image processing.
- Google Chrome for headless Selenium system tests. Selenium Manager may download
  a matching driver on the first run, so that run can require network access.

Install the pinned gems and prepare the development/test databases:

```sh
bin/setup --skip-server
```

Start Rails and the Tailwind watcher:

```sh
bin/dev
```

Open <http://localhost:3000> to browse recipes or create your first one. `/up` is
the application health endpoint. `bin/dev` installs Foreman if it is missing.

By default, local databases are `pantry_development` and `pantry_test`.
If your PostgreSQL installation needs explicit connection settings, set `PGHOST`,
`PGPORT`, `PGUSER`, and `PGPASSWORD` as needed in your shell. Do not commit secrets.
Rails does not automatically load `.env` files in this project.

`config/master.key` is ignored by Git. Obtain the development key through a secure
channel only if a feature needs encrypted credentials; do not use production
credentials for development or tests. No external service credentials are needed
for the recipe feature or health checks.

## Verification

Run the complete local check before handing off an implementation:

```sh
bin/ci
```

This prepares the local environment, runs RuboCop, dependency/security audits,
Rails tests, a test-database seed check, and headless Chrome system tests.
Audits require network access. The seed check clears and reloads the **test**
database. Development and test databases must be separate and disposable where
appropriate; never point these commands at production.

During development, run the relevant checks directly:

```sh
bin/rails test
bin/rails test:system
bin/rails test test/integration/health_test.rb
bin/rubocop
```

System-test failure screenshots are saved in `tmp/screenshots`; GitHub Actions
uploads them on failure. CI runs the same test, style, security, and seed checks.
Tests cover recipe creation, validation, persistence, listing, details, and nested
form interactions, alongside application boot and browser connectivity. See the
feature spec for acceptance coverage and visual verification evidence.

If PostgreSQL connection fails, check that the service is running (`pg_isready`)
and that your role exists. In sandboxed agent sessions, database sockets, browser
processes, and audit downloads may require execution approval.

## Multiple worktrees

Give each concurrent checkout its own database prefix and server port. For example,
in that checkout's shell:

```sh
export PANTRY_DATABASE_PREFIX=pantry_feature_003
export PORT=3003
bin/setup --skip-server
bin/dev
```

Keep that prefix set for tests and `bin/ci` too. It creates
`pantry_feature_003_development` and `pantry_feature_003_test`. Use a short prefix
made of lowercase letters, numbers, and underscores. `DATABASE_URL`, when set,
can override the selected database; unset it for this prefix-based local workflow.
Production database names are unaffected.

## Feature development

1. Agree product intent in `docs/product.md`.
2. Copy `docs/features/_template.md` into a numbered feature spec.
3. Resolve questions with the owner and mark the agreed spec `ready`.
4. Implement, test, inspect changed UI, and record evidence in the spec.
5. Open a draft PR; the owner reviews against the acceptance criteria and merges.

The first spec is [create, list, and view recipes](docs/features/001-create-recipes.md).
It is implemented and verified. Recipes support ordered ingredient sections,
optional positive decimal quantities and free-text units, and preparation steps.
Saving invalid input retains the form and explains what needs correcting.

See [docs/workflow.md](docs/workflow.md) for details and reusable prompts.
Store significant technical decisions in [docs/decisions/](docs/decisions/README.md).

## Stack and deployment

Rails 8.1 (exact dependencies in `Gemfile.lock`), PostgreSQL, Hotwire with import
maps, Tailwind CSS, and Minitest with Capybara/Selenium. The scaffold also includes
Solid Queue/Cache/Cable and Kamal. A deployment target and production configuration
have not yet been established; deployment is outside the feature implementation
workflow until explicitly requested.
