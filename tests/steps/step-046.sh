#!/usr/bin/env bash
# Test:
#   Run an install, adding the intro README files into an existing repo

TEST_DIR=$(cd "$(dirname "$0")/.." && pwd)
# shellcheck disable=SC1091
. "$TEST_DIR/general.sh"

init_step

accept_all_trust_prompts || exit 1

if is_centralized_tests; then
    echo "Using centralized install"
    exit 249
fi

mkdir -p "$GH_TEST_TMP/test046/.githooks/pre-commit" &&
    echo "echo 'Testing' > '$GH_TEST_TMP/test46.out'" >"$GH_TEST_TMP/test046/.githooks/pre-commit/test" &&
    cd "$GH_TEST_TMP/test046" ||
    exit 1

git init || exit 1

echo "y

n
y
$GH_TEST_TMP/test046
y
" | "$GH_TEST_BIN/githooks-cli" installer "${EXTRA_INSTALL_ARGS[@]}" --stdin || exit 1

check_local_install "$GH_TEST_TMP/test046"

if ! grep "github.com/gabyx/githooks" "$GH_TEST_TMP/test046/.githooks/README.md"; then
    echo "! README was not installed"
    exit 1
fi
