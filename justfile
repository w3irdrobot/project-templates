set shell := ["bash", "-cu"]
set positional-arguments

_default:
    just --list

# Generate and verify every supported template variant.
verify:
    @bash scripts/verify.sh
