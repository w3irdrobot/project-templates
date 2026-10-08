# {{project-name}}

A Rust workspace with a CLI application and a reusable core library.
{% if async %}
Tokio provides the application's async runtime.
{% endif %}

## Layout

- `crates/app` (package `{{project-name}}`): application wiring in `main.rs`, argument parsing
  in `cli.rs`, `anyhow` errors, and environment-filtered `tracing`.
- `crates/core` (package `{{project-name}}-core`): reusable behavior in `greeting.rs`, typed
  `thiserror` errors, and exports in `lib.rs`.

The application depends on the core library; the library does not depend on the
application. Rename or split the core crate by responsibility as the project
grows. Shared versions, edition, and dependency definitions live in the root
workspace manifest. Both crates use edition 2024 with workspace resolver 3.
The application starts with `publish = false`; review crate metadata before
publishing the core library.

The starter greets a name, rejecting empty or whitespace-only names. Replace
this example with the application's behavior.

## Development

Install [just](https://just.systems). Rustup installs the stable toolchain
specified in `rust-toolchain.toml` when needed. Install nightly for formatting:

```bash
rustup toolchain install nightly --profile minimal --component rustfmt
just
just run
just run "developer friend"
RUST_LOG=debug just run
just verify
just build
```

`just` lists available recipes. `verify` checks formatting, compilation, Clippy,
and tests across the workspace. `build` builds every crate in release mode; the
application binary is `target/release/{{project-name}}`. `run` selects the
application package explicitly and forwards arguments.

CLI output goes to stdout; logs go to stderr. Set `RUST_LOG` to configure logging
(default: `info`). The core library's unit test checks blank-name validation.
Put future cross-module integration tests in the relevant crate's `tests/`
directory. Add real-component tests when the application's needs justify them.

Builds use stable Rust. Formatting uses unpinned nightly for import grouping.
Run `rustup update nightly` when you want to update the formatter. Commit the
root `Cargo.lock` after the first build to record workspace dependency resolution.
