#!/bin/sh
DIR="$(cd "$(dirname "$0")" >/dev/null 2>&1 && pwd)"

set -e
set -u

# shellcheck disable=SC2124
buildFlags="$@"

cd "$DIR"
buildVersion=$(git describe --tags --abbrev=6 --always | sed -E "s/^v//")

export GOPATH="$DIR/.go"
export GOBIN="$DIR/bin"

go mod vendor
go generate -mod=vendor ./...

# shellcheck disable=SC2086
go install -mod=vendor \
    -ldflags="-X 'rycus86/githooks/hooks.BuildVersion=$buildVersion'" \
    -tags debug $buildFlags ./...
