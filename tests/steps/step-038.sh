#!/usr/bin/env bash
# Test:
#   Remember the start directory for searching existing repos

TEST_DIR=$(cd "$(dirname "$0")/.." && pwd)
# shellcheck disable=SC1091
. "$TEST_DIR/general.sh"

init_step

accept_all_trust_prompts || exit 1

if is_centralized_tests; then
    echo "Using centralized install"
    exit 249
fi

mkdir -p "$GH_TEST_TMP/start/dir" || exit 1

echo "y

n
y
$GH_TEST_TMP/start
" | "$GH_TEST_BIN/githooks-cli" installer "${EXTRA_INSTALL_ARGS[@]}" --stdin || exit 1

if [ "$(git config --global --get githooks.previousSearchDir)" != "$GH_TEST_TMP/start" ]; then
    echo "! The search start directory is not recorded"
    exit 1
fi

"$GH_TEST_BIN/githooks-cli" installer "${EXTRA_INSTALL_ARGS[@]}" || exit 1

cd "$GH_TEST_TMP/start/dir" &&
    git init &&
    install_hooks_if_not_centralized || exit 1

check_local_install "$GH_TEST_TMP/start/dir"
