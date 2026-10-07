#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
scratch="$(mktemp -d "${TMPDIR:-/tmp}/project-templates.XXXXXXXX")"
trap 'rm -rf "$scratch"' EXIT

# Share build artifacts between variants without sharing their source trees.
export CARGO_TARGET_DIR="${CARGO_TARGET_DIR:-$scratch/target}"

for async in true false; do
    name="cli-$async"
    project="$scratch/$name"

    cargo generate \
        --path "$repo_root/rust/cli" \
        --name "$name" \
        --destination "$scratch" \
        --define "async=$async" \
        --silent \
        --vcs none \
        --no-workspace

    just --justfile "$project/justfile" verify
    just --justfile "$project/justfile" build

    # Exercise the Just argument boundary, Clap, stdout, and environment logging.
    output="$(just --justfile "$project/justfile" run 'developer friend')"
    [[ "$output" == 'Hello, developer friend!' ]]
    just --justfile "$project/justfile" run --help > "$scratch/$name-help.txt"
    just --justfile "$project/justfile" run --version > "$scratch/$name-version.txt"
    RUST_LOG=debug just --justfile "$project/justfile" run \
        > "$scratch/$name-output.txt" 2> "$scratch/$name-log.txt"
    [[ "$(< "$scratch/$name-output.txt")" == 'Hello, world!' ]]
    [[ "$(< "$scratch/$name-log.txt")" == *'parsed CLI arguments'* ]]

    dependencies="$(cargo tree --manifest-path "$project/Cargo.toml" --depth 1 --prefix none)"
    if [[ "$async" == true ]]; then
        [[ "$dependencies" == *'tokio v'* ]]
    else
        [[ "$dependencies" != *'tokio v'* ]]
    fi
done
