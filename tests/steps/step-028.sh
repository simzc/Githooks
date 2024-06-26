#!/usr/bin/env bash
# Test:
#   Direct runner execution: accept changes to hooks

TEST_DIR=$(cd "$(dirname "$0")/.." && pwd)
# shellcheck disable=SC1091
. "$TEST_DIR/general.sh"

init_step

useSymlink="false"
[ "$1" = "--use-symbolic-link" ] && useSymlink="true"

mkdir -p "$GH_TEST_TMP/test28" &&
    cd "$GH_TEST_TMP/test28" &&
    git init || exit 1

if [ "$useSymlink" = "true" ]; then
    ln -s "$GH_TEST_TMP/checksums" ".git/.githooks.checksums"
fi

mkdir -p .githooks &&
    mkdir -p .githooks/pre-commit &&
    echo "echo 'First execution' >> '$GH_TEST_TMP/test028.out'" >.githooks/pre-commit/test &&
    ACCEPT_CHANGES=A "$GH_TEST_BIN/githooks-runner" "$(pwd)"/.git/hooks/pre-commit

if ! grep -q "First execution" "$GH_TEST_TMP/test028.out"; then
    echo "! Expected to execute the hook the first time"
    exit 1
fi

NUMBER_OF_CHECKSUMS=$(grep -r "pre-commit" .git/.githooks.checksums | wc -l)
if [ "$NUMBER_OF_CHECKSUMS" != "1" ]; then
    echo "! Expected to have one checksum entry"
    exit 1
fi

echo "echo 'Second execution' >> '$GH_TEST_TMP/test028.out'" >.githooks/pre-commit/test &&
    ACCEPT_CHANGES=Y "$GH_TEST_BIN/githooks-runner" "$(pwd)"/.git/hooks/pre-commit

if ! grep -q "Second execution" "$GH_TEST_TMP/test028.out"; then
    echo "! Expected to execute the hook the second time"
    exit 1
fi

NUMBER_OF_CHECKSUMS=$(grep -r "pre-commit" .git/.githooks.checksums | wc -l)
if [ "$NUMBER_OF_CHECKSUMS" != "2" ]; then
    echo "! Expected to have two checksum entries"
    exit 1
fi
