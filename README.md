# Project templates

Personal project starters, generated with
[cargo-generate](https://cargo-generate.github.io/cargo-generate/).

## Requirements

- Rustup with stable Rust and Clippy.
- Nightly with rustfmt: `rustup toolchain install nightly --profile minimal --component rustfmt`.
- [just](https://just.systems).
- cargo-generate 0.23 or newer: `cargo install cargo-generate --locked`.

## Generate a project

Select a template interactively:

```bash
cargo generate --git https://github.com/w3irdrobot/project-templates.git
```

Or select the Rust CLI explicitly:

```bash
cargo generate \
  --git https://github.com/w3irdrobot/project-templates.git \
  rust/cli \
  --name my-tool
```

The CLI defaults to Tokio. For noninteractive generation, choose explicitly:

```bash
cargo generate \
  --git https://github.com/w3irdrobot/project-templates.git \
  rust/cli \
  --name my-tool \
  --define async=false \
  --silent
```

Run generation from the parent directory where you want the new project.
Repositories belong under `~/projects/<remote-host>/<owner-or-namespace>/<repository>`.
For example, this repository lives at
`~/projects/github.com/w3irdrobot/project-templates`.
Preserve nested namespaces and omit the URL's `.git` suffix from directory names.
Reuse an existing matching checkout instead of cloning a duplicate.

New repositories use `master` as their default branch. cargo-generate follows
the local Git configuration when initializing a repository; if it creates a
different branch, run `git branch -m master` in the generated project before
the first push. Set the GitHub repository's default branch to `master` as well.

## Templates

### `rust/cli`

A single-crate, edition-2024 CLI with:

- Clap's derive-based argument parser.
- `anyhow` for application errors.
- `tracing` and `tracing-subscriber`, filtered through `RUST_LOG`, logging to stderr.
- Tokio with macros and a multithreaded runtime by default; `async=false` omits it.
- Stable builds and unpinned nightly formatting with grouped imports.
- A `justfile` whose default is `just --list`.
- `fmt`, `fmt-check`, `check`, `lint`, `test`, `build`, `run`, and `verify` recipes.

The starter prints a greeting so argument parsing, output, and logging can be
exercised immediately. Replace that behavior with the application's commands.
Add typed errors (`thiserror`), config loading (`config`/dotenvy), serialization
(Serde), or HTTP support (Axum) when the application needs them.

Toolchains and dependency constraints intentionally track their selected release
lines. Identical template inputs produce the same starter files for a fixed
template revision; dependency resolution and formatter output can change over
time. Commit the generated application's `Cargo.lock` after its first build.
Use cargo-generate's `--revision` or `--tag` to select a specific template release.

## Work on templates

Generate directly from the local checkout while making changes:

```bash
cargo generate \
  --path rust/cli \
  --name my-tool \
  --define async=true \
  --silent
```

Run `just verify` to generate both CLI variants in a temporary directory, check
formatting, run Clippy and tests, build release binaries, and exercise CLI
arguments and environment logging. Generated projects are removed afterward.

To add another template:

1. Give it a directory such as `rust/library`, `rust/workspace`, `bash/script`,
   or `opentofu/module` with its own `cargo-generate.toml`.
2. Add that path to the root `sub_templates` list.
3. Document its inputs and add generation/validation coverage.

Only files named in a template's `include` list undergo Liquid expansion. Other
files are copied unchanged, keeping Just syntax separate from template syntax.
