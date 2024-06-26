#!/usr/bin/env bash
# Test:
#   Direct runner execution: test pre-commit hooks

TEST_DIR=$(cd "$(dirname "$0")/.." && pwd)
# shellcheck disable=SC1091
. "$TEST_DIR/general.sh"

init_step

accept_all_trust_prompts || exit 1

mkdir -p "$GH_TEST_TMP/test11" &&
    cd "$GH_TEST_TMP/test11" &&
    git init || exit 1

OUT=$("$GH_TEST_REPO/githooks/build/embedded/run-wrapper.sh" 2>&1)

if ! echo "$OUT" | grep -qi "Either 'githooks-runner' must be in your path"; then
    echo "! Expected wrapper template to fail" >&2
    echo "$OUT"
    exit 1
fi

mkdir -p .githooks/pre-commit &&
    echo "echo 'Direct execution' > '$GH_TEST_TMP/test011.out'" >.githooks/pre-commit/test &&
    "$GH_TEST_BIN/githooks-runner" "$(pwd)"/.git/hooks/pre-commit ||
    exit 1

grep -q 'Direct execution' "$GH_TEST_TMP/test011.out"
