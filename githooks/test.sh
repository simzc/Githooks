#!/bin/bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
REPO_DIR=$(git rev-parse --show-toplevel)

set -e

function die() {
    echo "!! " "$@" >&2
    exit 1
}

tmp=$(mktemp -d)

useOld="$1"

git init "$tmp" || die "Could not make git init"
cd "$tmp" &&
    rm -rf .git/hooks/* &&
    cp "$REPO_DIR/base-template-wrapper.sh" .git/hooks/pre-commit &&
    chmod +x .git/hooks/pre-commit &&
    echo -e "#!/bin/bash\n echo 'hello from old hook'" >.git/hooks/pre-commit.replaced.githook &&
    chmod +x .git/hooks/pre-commit.replaced.githook &&
    mkdir .githooks && touch .githooks/trust-all &&
    mkdir -p .githooks/pre-commit &&
    echo  -e "#!/bin/bash\n echo 'hello from repo hook1'" >.githooks/pre-commit/monkey &&
    chmod +x .githooks/pre-commit/monkey &&
    echo  -e "#!/bin/bash\n echo 'hello from repo hook2'" >.githooks/pre-commit/gaga &&
    chmod +x .githooks/pre-commit/gaga

tree .git/hooks
tree .githooks

if [ "$useOld" != "--old" ]; then
    git config --local githooks.runner "$DIR/bin/runner"
fi

git commit --allow-empty -m "Test commit"