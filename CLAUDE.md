# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`ajax-datatables-rails` is a Rails gem that implements the server-side processing protocol
of the jQuery DataTables plugin (https://datatables.net/manual/server-side). A host app
subclasses `AjaxDatatablesRails::ActiveRecord`, declares its columns, and the gem turns the
DataTables request params into a filtered / searched / sorted / paginated ActiveRecord query
and renders the JSON payload DataTables expects.

## Commands

Tests run against a real database selected by the `DB_ADAPTER` env var (default `postgresql`,
which requires a running Postgres). `sqlite3` is the only zero-setup local adapter:

```sh
DB_ADAPTER=sqlite3 bin/rspec                       # full suite, no external DB needed
DB_ADAPTER=sqlite3 bin/rspec spec/ajax_datatables_rails/base_spec.rb        # one file
DB_ADAPTER=sqlite3 bin/rspec spec/ajax_datatables_rails/base_spec.rb:42     # one example (by line)
bin/rubocop                                        # lint (must pass in CI)
```

Test against a specific Rails/adapter combo via the Appraisal gemfiles in `gemfiles/`:

```sh
BUNDLE_GEMFILE=gemfiles/rails_8.0_with_sqlite3.gemfile DB_ADAPTER=sqlite3 bin/rspec
bundle exec appraisal install                      # regenerate gemfiles/ after editing Appraisals
```

Postgres/MySQL locally need a `ajax_datatables_rails` database and the credentials hard-coded in
`spec/dummy/config/database.yml` (postgres/postgres, root/root). Oracle setup lives in `ci/`.

## Architecture

The request flows through four cooperating layers. Understanding the split between them is the
key to working here.

**`Base` (`lib/ajax-datatables-rails/base.rb`)** — the class users subclass. It owns the
orchestration (`retrieve_records` = fetch → filter → sort → paginate) and the JSON envelope
(`as_json` → `recordsTotal` / `recordsFiltered` / `data` / `draw`). It defines three abstract
methods the user MUST implement (`view_columns`, `get_raw_records`, `data`) and leaves the ORM
verbs (`filter_records`, `sort_records`, `paginate_records`) abstract too.

**`ORM::ActiveRecord` (`lib/ajax-datatables-rails/orm/active_record.rb`)** — mixed into
`AjaxDatatablesRails::ActiveRecord`, it supplies the ActiveRecord implementations of the ORM
verbs and the Arel condition-building (`build_conditions`, global search vs. per-column search).
This is the only ORM currently implemented; the `ORM` module namespace exists so other backends
could be added.

**`Datatable::Datatable` (`lib/ajax-datatables-rails/datatable/datatable.rb`)** — a wrapper
around the raw DataTables request params. It parses `order` / `search` / `columns` /
`start` / `length` into `SimpleOrder`, `SimpleSearch`, and `Column` objects and answers
questions like `orderable?`, `searchable?`, `paginate?`, `per_page`, `offset`. `Base` delegates
all param interpretation to it via `@datatable`.

**`Datatable::Column` (`lib/ajax-datatables-rails/datatable/column.rb`)** — one per view column.
Resolves the `source:` string (`"Model.field"` or a custom field name) to an Arel table/field,
validates the incoming search condition against `VALID_SEARCH_CONDITIONS`, and (via the mixed-in
`Search`, `Order`, `DateFilter` modules) produces the Arel `search_query` / `sort_query` nodes.
Per-adapter SQL type-casting (`CAST(... AS VARCHAR/CHAR/TEXT/...)`) is decided here from
`datatable.db_adapter`.

### Cross-cutting details that bite

- **Adapter awareness is pervasive.** `db_adapter` (auto-detected from the app's AR config in
  `Base.default_db_adapter`, overridable via the `db_adapter` class_attribute) drives both the
  type-cast in `Column` and the `NULLS LAST` SQL dialect in `SimpleOrder`. Any change touching SQL
  generation must be checked across sqlite / postgres / mysql / oracle — that is what the CI matrix
  exists for. Adding an adapter means extending the maps in `Column` and `SimpleOrder`.
- **Two counts, two queries.** `recordsTotal` counts unfiltered records; `recordsFiltered` counts
  after filtering. `numeric_count` collapses a grouped-count Hash to its size (grouped datatables).
- **Output is HTML-escaped.** `sanitize_data` runs `ERB::Util.html_escape` over every cell before
  serialization — handles both array-of-arrays and array-of-hashes `data` shapes.
- **Zeitwerk loading.** `lib/ajax-datatables-rails.rb` sets up a Zeitwerk loader with two custom
  inflections (`orm` → `ORM`, `ajax-datatables-rails` → `AjaxDatatablesRails`) and ignores
  `generators/`. New files must match Zeitwerk's path→constant expectation or loading breaks.

## Tests

Specs boot a real Rails app via Combustion (`spec/dummy/`, a single `users` table). Example
datatable subclasses used across specs live in `spec/support/datatables/` — add new fixtures
there rather than defining classes inline. On CI (`GITHUB_ACTIONS` set) examples auto-retry twice
via rspec-rebound to absorb DB flakiness; locally they do not.

## Conventions

- RuboCop is authoritative (config in `.rubocop.yml`): 150-char lines, table-aligned hashes,
  trailing commas on multiline literals, and the many `Layout/EmptyLines*` cops disabled — the
  codebase deliberately keeps blank lines inside class/module bodies.
- `required_ruby_version >= 3.1`, `rails >= 7.1`. Keep changes green across the full Ruby × Rails ×
  adapter CI matrix, not just one combination.
