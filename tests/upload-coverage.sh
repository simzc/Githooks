#!/usr/bin/env bash
# shellcheck disable=SC2015

set -e
set -u

ROOT_DIR=$(git rev-parse --show-toplevel)
cd "$ROOT_DIR/githooks"

[ -d "$GH_COVERAGE_DIR" ] || {
    echo "! No coverage dir existing" >&2
    exit 1
}

# shellcheck disable=SC2015
gocovmerge "$GH_COVERAGE_DIR"/*.cov >"$GH_COVERAGE_DIR/all.cov" || {
    echo "! Cov merge failed." >&2
    exit 1
}
echo "Coverage created."

echo "Create HTML file."
go tool cover -html="$GH_COVERAGE_DIR/all.cov" -o "$GH_COVERAGE_DIR/all.html"

# Remove dialog tool because we cannot yet really measure the coverage accurately
sed -i -E '/^.*gabyx\/githooks\/githooks\/apps\/dialog.*$/d' "$GH_COVERAGE_DIR/all.cov"
sed -i -E '/^.*gabyx\/githooks\/githooks\/prompt\/show\.go.*$/d' "$GH_COVERAGE_DIR/all.cov"
sed -i -E '/^.*gabyx\/githooks\/githooks\/prompt\/show-gui-impl\.go.*$/d' "$GH_COVERAGE_DIR/all.cov"

echo "Calculate Stats."
gocoverstats -f "$GH_COVERAGE_DIR/all.cov" -percent

echo "Calculate Tree Map."
go-cover-treemap --color-blind -coverprofile "$GH_COVERAGE_DIR/all.cov" >"$GH_COVERAGE_DIR/all.svg"

echo "Upload Coverage."
service="travis-ci"
if [ -n "${TRAVIS:-}" ]; then
    service="travis-ci"
elif [ -n "${CIRCLECI:-}" ]; then
    service="circle-ci"
else
    echo "! Service environment not implemented for goveralls."
    exit 1
fi

scripts/build.sh && # Generate all files again such that we can upload the coverage
    goveralls --coverprofile="$GH_COVERAGE_DIR/all.cov" --service="$service" \
        --reponame githooks --repotoken="$COVERALLS_TOKEN" || {
    echo "! Goveralls failed." >&2
    exit 1
}
