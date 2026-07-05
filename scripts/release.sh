#!/usr/bin/env bash
#
# Release pictor to crates.io.
#
# GitHub Release + crates.io publish happen in CI (.github/workflows/release.yml)
# when the tag is pushed. Run this script locally to bump versions, commit, tag,
# and push — or publish locally if CARGO_REGISTRY_TOKEN is set.
#
# Usage: ./scripts/release.sh <version>
# Prerequisites: on main, clean tree, CHANGELOG.md section for version

set -euo pipefail

VERSION="${1:?Usage: $0 <version>}"
CRATES=(
    pictor-core
    pictor-kernels
    pictor-tokenizer
    pictor-model
    pictor-rag
    pictor-runtime
    pictor-eval
    pictor-serve
    pictor-image
    pictor
)

if [[ "$(git rev-parse --abbrev-ref HEAD)" != "main" ]]; then
    echo "ERROR: Must be on main branch"
    exit 1
fi

if [[ -n "$(git status --porcelain)" ]]; then
    echo "ERROR: Working tree is not clean"
    exit 1
fi

if git rev-parse "v$VERSION" >/dev/null 2>&1; then
    echo "ERROR: Tag v$VERSION already exists"
    exit 1
fi

if ! awk -v ver="$VERSION" \
        '$0 ~ "^## \\[" ver "\\] - " { found=1 } found && /[^[:space:]]/ && !/^## / { ok=1 }
         END { exit !ok }' CHANGELOG.md; then
    echo "ERROR: No '## [$VERSION] - ...' section with content found in CHANGELOG.md"
    exit 1
fi

# Bump workspace root version
perl -i -pe "s/^version = \"[^\"]+\"/version = \"$VERSION\"/" Cargo.toml

# Bump crate package versions (first version = line only)
for crate in "${CRATES[@]}"; do
    perl -i -pe "if (!\$bumped && s/^version = \"[^\"]+\"/version = \"$VERSION\"/) { \$bumped = 1 }" "crates/$crate/Cargo.toml"
done

COMPAT="${VERSION%.*}"
export COMPAT
while IFS= read -r -d '' f; do
    perl -i -pe '
        s/(pictor(?:-[a-z-]+)?)\s*=\s*"\K0\.\d+(?:\.\d+)?(?=")/$ENV{COMPAT}/g;
        s/(pictor(?:-[a-z-]+)?)\s*=\s*\{\s*version\s*=\s*"\K0\.\d+(?:\.\d+)?(?=")/$ENV{COMPAT}/g;
    ' "$f"
done < <(find crates -type f \( -name README.md -o -path '*/src/lib.rs' \) -print0)
echo "==> docs: dependency examples -> \"${COMPAT}\""

git add -A
git commit -m "chore: release $VERSION"
git tag "v$VERSION"

git push origin main
git push origin "v$VERSION"
echo "==> tag pushed — CI will create GitHub Release and publish crates"

if [[ -n "${CARGO_REGISTRY_TOKEN:-}" ]] || [[ -n "${SKIP_LOCAL_PUBLISH:-}" ]]; then
    if [[ -n "${SKIP_LOCAL_PUBLISH:-}" ]]; then
        echo "==> SKIP_LOCAL_PUBLISH set — skipping local cargo publish"
        exit 0
    fi
    for crate in "${CRATES[@]}"; do
        cargo publish -p "$crate"
    done
    echo "Released pictor v$VERSION to crates.io"
else
    echo "==> No CARGO_REGISTRY_TOKEN — crates.io publish delegated to CI"
fi