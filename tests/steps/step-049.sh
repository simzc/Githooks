#!/usr/bin/env bash
# Test:
#   Do not reenable automatic update checks in non-interactive mode

TEST_DIR=$(cd "$(dirname "$0")/.." && pwd)
# shellcheck disable=SC1091
. "$TEST_DIR/general.sh"

init_step

accept_all_trust_prompts || exit 1

git config --global githooks.updateCheckEnabled false || exit 1
"$GH_TEST_BIN/githooks-cli" installer "${EXTRA_INSTALL_ARGS[@]}" --non-interactive || exit 1

if [ "$(git config --global --get githooks.updateCheckEnabled)" != "false" ]; then
    echo "! Automatic update checks were unexpectedly enabled"
    exit 1
fi
