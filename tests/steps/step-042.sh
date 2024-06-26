#!/usr/bin/env bash
# Test:
#   Run an install and try the update
# shellcheck disable=SC1091

TEST_DIR=$(cd "$(dirname "$0")/.." && pwd)
# shellcheck disable=SC1091
. "$TEST_DIR/general.sh"

init_step

accept_all_trust_prompts || exit 1

LAST_UPDATE=$(get_update_check_timestamp)
if [ -n "$LAST_UPDATE" ]; then
    echo "! Update already marked as run"
    exit 1
fi

if ! "$GH_TEST_BIN/githooks-cli" installer "${EXTRA_INSTALL_ARGS[@]}"; then
    echo "! Installation failed"
    exit 1
fi

mkdir -p "$GH_TEST_TMP/start/dir" &&
    cd "$GH_TEST_TMP/start/dir" &&
    git init && install_hooks_if_not_centralized || exit 1

ARE_UPDATES_CHECKS_ENABLED=$(git config --global --get githooks.updateCheckEnabled)
if [ "$ARE_UPDATES_CHECKS_ENABLED" != "true" ]; then
    echo "! Update checks were expected to be enabled"
    exit 1
fi

LAST_UPDATE=$(get_update_check_timestamp)
if [ -n "$LAST_UPDATE" ]; then
    echo "! Update already marked as run"
    exit 1
fi

# Reset to trigger update
if ! git -C "$GH_TEST_REPO" reset --hard v9.9.1 >/dev/null; then
    echo "! Could not reset server to trigger update."
    exit 1
fi

reset_update_check_timestamp

OUTPUT=$(
    "$GH_INSTALL_BIN_DIR/githooks-runner" "$(pwd)"/.git/hooks/post-commit 2>&1
)

if ! echo "$OUTPUT" | grep -q "There is a new Githooks update available"; then
    echo "! Expected update-check output not found"
    echo "$OUTPUT"
    exit 1
fi

OUTPUT=$("$GH_INSTALL_BIN_DIR/githooks-cli" update 2>&1)

if ! echo "$OUTPUT" | grep -q "All done! Enjoy!"; then
    echo "! Expected installation output not found"
    echo "$OUTPUT"
    exit 1
fi

LAST_UPDATE=$(get_update_check_timestamp)
if [ -z "$LAST_UPDATE" ]; then
    echo "! Update did not run"
    exit 1
fi

CURRENT_TIME=$(date +%s)
ELAPSED_TIME=$((CURRENT_TIME - LAST_UPDATE))

if [ $ELAPSED_TIME -eq 0 ]; then
    echo "! Update did not execute properly"
    exit 1
fi
