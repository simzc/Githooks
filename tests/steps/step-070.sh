#!/usr/bin/env bash
# Test:
#   Run the cli tool for a hook that can't be found

TEST_DIR=$(cd "$(dirname "$0")/.." && pwd)
# shellcheck disable=SC1091
. "$TEST_DIR/general.sh"

init_step

accept_all_trust_prompts || exit 1

mkdir "$GH_TEST_TMP/test070" &&
    cd "$GH_TEST_TMP/test070" &&
    git init || exit 1

if ! "$GH_TEST_BIN/githooks-cli" installer "${EXTRA_INSTALL_ARGS[@]}"; then
    echo "! Failed to execute the install script"
    exit 1
fi

# @todo maybe add a test for ""$GH_INSTALL_BIN_DIR/githooks-cli" ignore".
# Not sure yet if it makes sense. Its more work...
# Checking if any added pattern has an effect.

if "$GH_INSTALL_BIN_DIR/githooks-cli" trust hooks --path not-found; then
    echo "! Unexpected accept result"
    exit 1
fi

if "$GH_INSTALL_BIN_DIR/githooks-cli" trust hooks --pattern not-found; then
    echo "! Unexpected accept result"
    exit 1
fi
