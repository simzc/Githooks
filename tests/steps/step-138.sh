#!/usr/bin/env bash
# Test:
#   Run CLI exec command.
set -e
set -u

TEST_DIR=$(cd "$(dirname "$0")/.." && pwd)
# shellcheck disable=SC1091
. "$TEST_DIR/general.sh"

init_step

if ! is_docker_available; then
    echo "docker is not available"
    exit 249
fi

"$GH_TEST_BIN/githooks-cli" installer "${EXTRA_INSTALL_ARGS[@]}" || exit 1

accept_all_trust_prompts || exit 1
assert_no_test_images

git config --global githooks.testingTreatFileProtocolAsRemote "true"

mkdir -p "$GH_TEST_TMP/shared/hooks-138-a.git" &&
    cd "$GH_TEST_TMP/shared/hooks-138-a.git" &&
    git init &&
    mkdir githooks &&
    cp -rf "$TEST_DIR/steps/images/image-1/.images.yaml" ./githooks/.images.yaml &&
    cp -rf "$TEST_DIR/steps/images/image-1/docker" ./docker &&
    cp -rf "$TEST_DIR/steps/images/image-1/githooks/scripts" githooks/scripts &&
    echo "sharedhooks" >"githooks/.namespace" &&
    git add . &&
    git commit -m 'Initial commit' ||
    exit 1

# Setup local repository
mkdir -p "$GH_TEST_TMP/test138" &&
    cd "$GH_TEST_TMP/test138" &&
    git init &&
    mkdir -p .githooks &&
    echo -e "urls:\n  - file://$GH_TEST_TMP/shared/hooks-138-a.git" >.githooks/.shared.yaml &&
    cp -rf "$TEST_DIR/steps/images/image-1/.envs.yaml" .githooks/.envs.yaml &&
    GITHOOKS_DISABLE=1 git add . &&
    GITHOOKS_DISABLE=1 git commit -m 'Initial commit' ||
    exit 1

# Enable containerized hooks.
export GITHOOKS_CONTAINERIZED_HOOKS_ENABLED=true

"$GH_TEST_BIN/githooks-cli" shared update

# Creating volumes for the mounting, because
# `docker in docker` uses directories on host volume,
# which we dont have.
store_into_container_volumes "$HOME/.githooks/shared"
show_all_container_volumes 3
set_githooks_container_volume_envs "."

# Test the containerized run.
OUT=$("$GH_TEST_BIN/githooks-cli" exec ns:sharedhooks/scripts/test-success.yaml "arg1" "arg2" 2>&1) ||
    {
        echo "Execution failed. [exit code: $?]:"
        echo "$OUT"
        exit 1
    }

if ! echo "$OUT" | grep -iq "executing test script 'arg1' 'arg2' banana"; then
    echo "! Expected output not found."
    echo "$OUT"
    exit 1
fi

# Test the normal run as well.
OUT=$("$GH_TEST_BIN/githooks-cli" exec ns:sharedhooks/scripts/test-success.sh "arg1" "arg2" 2>&1) ||
    {
        echo "Execution failed. [exit code: $?]:"
        echo "$OUT"
        exit 1
    }

if ! echo "$OUT" | grep -iq "executing test script 'arg1' 'arg2' banana"; then
    echo "! Expected output not found."
    echo "$OUT"
    exit 1
fi

set +e
OUT=$("$GH_TEST_BIN/githooks-cli" exec ns:sharedhooks/scripts/test-fail.yaml 2>&1)
EXIT_CODE="$?"
set -e

# Coverage cannot report correct exit codes, without wrapping it to a file.
if [ -z "${GH_COVERAGE_DIR:-}" ] &&
    [ "$EXIT_CODE" != "123" ]; then
    echo "! Test script should have reported 123 [exit code: $EXIT_CODE]"
    exit 1
fi

if ! echo "$OUT" | grep -iq "executing test script"; then
    echo "! Expected output not found."
    echo "$OUT"
    exit 1
fi

delete_container_volumes
delete_all_test_images
