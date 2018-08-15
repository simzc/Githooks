#!/bin/sh
# Test:
#   Run an install, skipping the intro README files

mkdir -p /tmp/test045/001 && cd /tmp/test045/001 && git init || exit 1
mkdir -p /tmp/test045/002 && cd /tmp/test045/002 && git init || exit 1

cd /tmp/test045 || exit 1

echo "n
y
/tmp/test045
s
" | sh /var/lib/githooks/install.sh || exit 1

if ! grep "github.com/rycus86/githooks" /tmp/test045/001/.git/hooks/pre-commit; then
    echo "! Hooks were not installed into 001"
    exit 1
fi

if grep "github.com/rycus86/githooks" /tmp/test045/001/.githooks/README.md; then
    echo "! README was unexpectedly installed into 001"
    exit 1
fi

if ! grep "github.com/rycus86/githooks" /tmp/test045/002/.git/hooks/pre-commit; then
    echo "! Hooks were not installed into 002"
    exit 1
fi

if grep "github.com/rycus86/githooks" /tmp/test045/002/.githooks/README.md; then
    echo "! README was unexpectedly installed into 002"
    exit 1
fi
