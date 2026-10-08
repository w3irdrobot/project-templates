#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git -C "$(dirname "${BASH_SOURCE[0]}")" rev-parse --show-toplevel)"
scratch="$(mktemp -d "${TMPDIR:-/tmp}/project-templates.XXXXXXXX")"
trap 'rm -rf "$scratch"' EXIT

# Share build artifacts between variants without sharing their source trees.
export CARGO_TARGET_DIR="${CARGO_TARGET_DIR:-$scratch/target}"

for template in cli workspace; do
    for async in true false; do
        name="$template-$async"
        project="$scratch/$name"

        cargo generate \
            --path "$repo_root/rust/$template" \
            --name "$name" \
            --destination "$scratch" \
            --define "async=$async" \
            --silent \
            --vcs none \
            --no-workspace

        just --justfile "$project/justfile"
        just --justfile "$project/justfile" verify
        just --justfile "$project/justfile" build

        # Exercise the Just argument boundary, Clap, stdout, and environment logging.
        output="$(just --justfile "$project/justfile" run 'developer friend')"
        [[ "$output" == 'Hello, developer friend!' ]]
        just --justfile "$project/justfile" run --help > "$scratch/$name-help.txt"
        just --justfile "$project/justfile" run --version > "$scratch/$name-version.txt"
        [[ "$(< "$scratch/$name-help.txt")" == *'Usage:'* ]]
        [[ "$(< "$scratch/$name-version.txt")" == "$name 0.1.0" ]]
        RUST_LOG=debug just --justfile "$project/justfile" run \
            > "$scratch/$name-output.txt" 2> "$scratch/$name-log.txt"
        [[ "$(< "$scratch/$name-output.txt")" == 'Hello, world!' ]]
        [[ "$(< "$scratch/$name-log.txt")" == *'parsed CLI arguments'* ]]

        dependencies="$(cargo tree --manifest-path "$project/Cargo.toml" --workspace --depth 1 --prefix none)"
        if [[ "$async" == true ]]; then
            [[ "$dependencies" == *'tokio v'* ]]
        else
            [[ "$dependencies" != *'tokio v'* ]]
        fi

        if [[ "$template" == workspace ]]; then
            [[ -f "$project/crates/app/Cargo.toml" ]]
            [[ -f "$project/crates/core/Cargo.toml" ]]
            [[ "$dependencies" == *"$name-core v0.1.0"* ]]

            # The reusable core has no application/runtime dependencies.
            core_dependencies="$(cargo tree --manifest-path "$project/Cargo.toml" --package "$name-core" --prefix none)"
            [[ "$core_dependencies" == *'thiserror v'* ]]
            [[ "$core_dependencies" != *'anyhow v'* ]]
            [[ "$core_dependencies" != *'clap v'* ]]
            [[ "$core_dependencies" != *'tokio v'* ]]

            # Ensure typed library failures surface through the application boundary.
            if just --justfile "$project/justfile" run '   ' \
                > "$scratch/$name-error-output.txt" 2> "$scratch/$name-error.txt"; then
                printf '%s\n' "Expected $name to reject a blank name" >&2
                exit 1
            fi
            [[ ! -s "$scratch/$name-error-output.txt" ]]
            [[ "$(< "$scratch/$name-error.txt")" == *'could not create greeting'* ]]
            [[ "$(< "$scratch/$name-error.txt")" == *'name must not be empty'* ]]
        fi
    done
done
