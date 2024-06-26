#!/usr/bin/env bash
# Test:
#   Cli tool: warn on not running hooks

TEST_DIR=$(cd "$(dirname "$0")/.." && pwd)
# shellcheck disable=SC1091
. "$TEST_DIR/general.sh"

init_step

accept_all_trust_prompts || exit 1

"$GH_TEST_BIN/githooks-cli" installer "${EXTRA_INSTALL_ARGS[@]}" || exit 1

mkdir -p "$GH_TEST_TMP/test143/.githooks/pre-commit" &&
    echo 'echo "Hello"' >"$GH_TEST_TMP/test143/.githooks/pre-commit/first" &&
    echo 'echo "Hello"' >"$GH_TEST_TMP/test143/.githooks/pre-commit/second" &&
    touch "$GH_TEST_TMP/test143/.githooks/trust-all" &&
    cd "$GH_TEST_TMP/test143" &&
    git init &&
    git config --local githooks.trustAll true ||
    exit 1

if ! is_centralized_tests; then
    if ! "$GH_INSTALL_BIN_DIR/githooks-cli" list 2>&1 |
        grep -q "but Githooks seems not installed"; then
        echo "! Warning should appear since we did not install."
        exit 1
    fi

    # Make wrong install
    git config core.hooksPath "/bla"
    if ! "$GH_INSTALL_BIN_DIR/githooks-cli" list 2>&1 |
        grep -C 10 "Local Git config 'core.hooksPath'" |
        grep -q 'will not run'; then
        echo "! Expected to have a warning displayed" >&2
        "$GH_INSTALL_BIN_DIR/githooks-cli" list
        exit 3
    fi

    "$GH_INSTALL_BIN_DIR/githooks-cli" install || exit 1

    if "$GH_INSTALL_BIN_DIR/githooks-cli" list 2>&1 | grep -qE "(will|might) not run"; then
        echo "! Warning should not appear since we installed."
        "$GH_INSTALL_BIN_DIR/githooks-cli" list
        exit 1
    fi
else
    if "$GH_INSTALL_BIN_DIR/githooks-cli" list 2>&1 | grep -qE "(will|might) not run"; then
        echo "! Warning should not appear since we installed."
        "$GH_INSTALL_BIN_DIR/githooks-cli" list
        exit 1
    fi

    git config --global core.hooksPath "/bla"
    if ! "$GH_INSTALL_BIN_DIR/githooks-cli" list 2>&1 |
        grep -i -C 10 "Global Git config 'core.hooksPath' is set to" |
        grep -qi "Hooks configured for Githooks might not run"; then
        echo "! Warning should appear since we did not install."
        "$GH_INSTALL_BIN_DIR/githooks-cli" list
        exit 1
    fi

    git config --unset --global core.hooksPath
    if ! "$GH_INSTALL_BIN_DIR/githooks-cli" list 2>&1 |
        grep -q 'Githooks are configured but Githooks seems not installed.'; then
        echo "! Expected to have a warning displayed when no core.hooksPath" >&2
        git hook list
        exit 3
    fi
fi
