#!/usr/bin/env bash
# Test:
#   Run install.sh script.
# shellcheck disable=SC2015

set -u

TEST_DIR=$(cd "$(dirname "$0")/.." && pwd)
# shellcheck disable=SC1091

. "$TEST_DIR/general.sh"

init_step

if [ -n "${GH_COVERAGE_DIR:-}" ]; then
    echo "Test cannot run for coverage."
    exit 249
fi

# Install with current script the version 2.10.0 on the `main` branch.
"$GH_SCRIPTS/install.sh" --version 2.10.0 || {
    echo "Could not download install.sh from 'main' and install."
    exit 1
}

# Enable this once pre-release is out on main.
# # Update to version 3 and greater, which should fail due to guard.
# OUT=$("$GH_INSTALL_BIN_DIR/cli" update --use-pre-release --yes)
# # shellcheck disable=SC2181
# if [ $? -eq 0 ] || ! echo "$OUT" | grep -iE "Too much changed. Please uninstall this version"; then
#     echo "Install should fail because update from v2 to v3 is guarded."
#     exit 1
# fi

# Uninstall right away again.
"$GH_INSTALL_BIN_DIR"/cli uninstaller || exit 1
