#!/usr/bin/env bash
# Test:
#   Test template area is set up properly (regular)

TEST_DIR=$(cd "$(dirname "$0")/.." && pwd)
# shellcheck disable=SC1091
. "$TEST_DIR/general.sh"

init_step

accept_all_trust_prompts || exit 1

if is_centralized_tests; then
    echo "Using centralized install"
    exit 249
fi

mkdir -p "$GH_TEST_TMP/test113/.githooks/pre-commit" &&
    echo "echo 'Testing 113' > '$GH_TEST_TMP/test113.out'" >"$GH_TEST_TMP/test113/.githooks/pre-commit/test-hook" &&
    cd "$GH_TEST_TMP/test113" &&
    git init || exit 1

if grep -r 'github.com/gabyx/githooks' "$GH_TEST_TMP/test113/.git"; then
    echo "! Hooks were installed ahead of time"
    exit 2
fi

mkdir -p ~/.githooks/templates

# run the install, and select installing hooks into existing repos
echo "n
y
$GH_TEST_TMP/test113
" | "$GH_TEST_BIN/githooks-cli" installer "${EXTRA_INSTALL_ARGS[@]}" --stdin --hooks-dir ~/.githooks/templates/hooks || exit 3

# check if hooks are inside the template folder.
if ! "$GH_INSTALL_BIN_DIR/githooks-cli" list | grep -q "test-hook"; then
    echo "! Hooks were not installed successfully"
    exit 4
fi

git add . && git commit -m 'Test commit' || exit 5

if ! grep 'Testing 113' "$GH_TEST_TMP/test113.out"; then
    echo "! Expected hook did not run"
    exit 6
fi
