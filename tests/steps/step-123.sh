#!/usr/bin/env bash
# Test:
#   Direct runner execution: test a shared repo with checked in compiled hooks

TEST_DIR=$(cd "$(dirname "$0")/.." && pwd)
# shellcheck disable=SC1091
. "$TEST_DIR/general.sh"

init_step

"$GH_TEST_BIN/githooks-cli" installer "${EXTRA_INSTALL_ARGS[@]}" || exit 1
accept_all_trust_prompts || exit 1

function cleanup() {
    true
}

trap cleanup EXIT

# Make our pre-compiled shared hook repo.
mkdir -p "$GH_TEST_TMP/shared" &&
    cd "$GH_TEST_TMP/shared" &&
    git init || exit 3

# Make folders.
mkdir -p "githooks/pre-commit" "dist" || exit 4

# Git LFS (if available)
if ! command -v git-lfs; then
    git lfs track "*.exe"
fi

# Make runner script.
mkdir -p .githooks &&
    cat <<"EOF" >"githooks/pre-commit/custom.yaml" || exit 5
cmd: "dist/custom-${env:GITHOOKS_OS}-${env:GITHOOKS_ARCH}.exe"
version: 1
EOF

# Make the hook source file.
cat <<"EOF" >"custom.go" || exit 5
package main

import (
    "fmt"
    "runtime"
)

func main() {
    fmt.Printf("%s\n%s\n%s", runtime.GOOS, runtime.GOARCH, "Hello from compiled hook")
}
EOF

# Detect the os/arch.
OUT=$(go run custom.go) || exit 6
OS=$(echo "$OUT" | head -1 | tail -1) || exit 7
ARCH=$(echo "$OUT" | head -2 | tail -1) || exit 8

env GOOS="$OS" GOARCH="$ARCH" \
    go build -o "dist/custom-$OS-$ARCH.exe" custom.go || exit 9
git add . &&
    git commit -a -m "built hooks" || exit 10

# Make normal repo.
mkdir -p "$GH_TEST_TMP/test123" &&
    cd "$GH_TEST_TMP/test123" &&
    git init || exit 11

# Add the shared repo
"$GH_INSTALL_BIN_DIR/githooks-cli" shared add --local "file://$GH_TEST_TMP/shared" || exit 12
"$GH_INSTALL_BIN_DIR/githooks-cli" shared update || exit 13

# Execute pre-commit by the runner
OUT=$("$GH_TEST_BIN/githooks-runner" "$(pwd)"/.git/hooks/pre-commit 2>&1)
# shellcheck disable=SC2181,SC2016
if [ "$?" -ne 0 ] ||
    ! echo "$OUT" | grep "Hello from compiled hook"; then
    echo "! Expected compiled to be executed."
    echo "$OUT"
    exit 14
fi
