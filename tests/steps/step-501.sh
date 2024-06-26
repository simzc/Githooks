#!/usr/bin/env bash
# Test:
#   Benchmark runner with no load

TEST_DIR=$(cd "$(dirname "$0")/.." && pwd)
# shellcheck disable=SC1091
. "$TEST_DIR/general.sh"

init_step

if [ -n "$GH_COVERAGE_DIR" ]; then
    echo "Benchmark not for coverage."
    exit 249
fi

accept_all_trust_prompts || exit 1

# Misuse the 3.1.0 prod build with package-manager enabled and download mocked.
git -C "$GH_TEST_REPO" reset --hard v3.1.0 >/dev/null 2>&1 || exit 1

# run the default install
"$GH_TEST_BIN/githooks-cli" installer \
    "${EXTRA_INSTALL_ARGS[@]}" \
    --clone-url "file://$GH_TEST_REPO" \
    --clone-branch "test-package-manager" || exit 1

# Test run-wrappers with pure binaries in the path.
# Put binaries into the path to find them.
export PATH="$GH_TEST_BIN:$PATH"
# Install CLI it into the default location for the test functions...
mkdir ~/.githooks/bin &&
    cp "$(which githooks-cli)" ~/.githooks/bin/ || exit 1

mkdir -p "$GH_TEST_TMP/test501" &&
    cd "$GH_TEST_TMP/test501" &&
    git init &&
    install_hooks_if_not_centralized ||
    exit 1

if ! is_centralized_tests; then
    check_local_install
else
    check_centralized_install
fi

function run_commits() {
    for i in {1..30}; do
        git commit --allow-empty -m "Test $i" 2>&1 | average
    done
}

function calc() { awk "BEGIN{print $*}"; }

function average() {
    local skip="$1"
    local count=0
    local total=0

    local input
    input=$(cat | grep "execution time:" | sed -E "s/.*'([0-9\.]+)'.*/\1/g")
    [ -n "$input" ] || {
        echo "no time extracted" >&2
        exit 1
    }

    # echo "$input"

    # Skip the first `$skip` runs, because it contains registration etc...
    [ -n "$skip" ] && input=$(echo "$input" | sed -n "1,$skip""d;p")

    while IFS= read -r val; do
        total=$(calc "$total" + "$val")
        ((count++))
    done <<<"$input"

    local time
    time=$(calc "$total" / "$count")

    echo "execution time: '$time' ms."
}

# shellcheck disable=SC2015
OUT=$(run_commits | average 3) || {
    echo "Benchmark not successful."
}

echo -e "Runtime average (no load):\n$OUT"

exit 250
