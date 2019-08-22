#!/bin/sh
# Test:
#   Run an install, and let it set up a new template directory

if echo "$EXTRA_INSTALL_ARGS" | grep -q "use-core-hookspath"; then
    echo "Using core.hooksPath"
    exit 249
fi

# delete the built-in git template folder
rm -rf /usr/share/git-core/templates || exit 1

# run the install, and let it search for the templates
echo 'n
y
' | sh /var/lib/githooks/install.sh || exit 1

mkdir -p /tmp/test7 && cd /tmp/test7 || exit 1
git init || exit 1

# verify that the hooks are installed and are working
if ! grep 'github.com/rycus86/githooks' /tmp/test7/.git/hooks/pre-commit; then
    echo "! Githooks were not installed into a new repo"
    exit 1
fi
