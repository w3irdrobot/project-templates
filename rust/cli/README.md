# {{project-name}}

A Rust CLI with Clap, `anyhow`, and environment-filtered `tracing`.
{% if async %}
Tokio provides the async runtime.
{% endif %}

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

`just` lists the available recipes. `verify` runs formatting checks, compilation
checks, Clippy, and tests. `build` produces a release binary under `target/release/`.
CLI output goes to stdout; logs go to stderr. Set `RUST_LOG` to configure logging
(default: `info`).

Builds use stable Rust. Formatting uses the unpinned `nightly` toolchain for
import grouping. To update it explicitly:

```bash
rustup update nightly
```

Commit `Cargo.lock` after the first build to record dependency resolution.
