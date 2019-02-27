#!/bin/bash
set -eo pipefail

usage() {
  echo "$(basename "${0}")"
}

readonly GITHUB_REPO="${GITHUB_REPO:-'git@github.com:jbossas/jboss-eap7.git'}"
readonly GITHUB_BRANCH="${GITHUB_BRANCH:-'7.2.x-proposed'}"
readonly BISECT_WORKSPACE="${BISECT_WORKSPACE:-$(mktemp -d)}"

deleteBisectWorkspac() {
  rm -rf "${BISECT_WORKSPACE}"
}
trap finish EXIT


#git clone "${GITHUB_REPO}"  --single-branch --branch "${GITHUB_BRANCH}" "${BISECT_WORKSPACE}"
git clone "${GITHUB_REPO}"  --branch "${GITHUB_BRANCH}" "${BISECT_WORKSPACE}"
cd "${BISECT_WORKSPACE}"

#good revision, we consider current one as bad?
readonly GOOD_REVISION="${GOOD_REVISION}"
readonly BAD_REVISION="${BAD_REVISION}"
#url of a patch file (a diff) containing the changes required to insert
# the reproducer into EAP existing testsuite.
readonly REPRODUCER_PATCH_URL="${REPRODUCER_PATCH_URL}"
#test to run from suite, either existing one or one that comes from $TEST_DIFF
readonly TEST_NAME="${TEST_NAME:-"*.*TestCase"}"
set -u

readonly REPRODUCER_PATCH=${PATCH_HOME:-$(mktemp)}
curl "${REPRODUCER_PATCH_URL}" -o "${REPRODUCER_PATCH}"
if [ -e "${REPRODUCER_PATCH}" ]; then
  export REPRODUCER_PATCH
else
	echo "No reproducer patch"
	#return 1
fi

git bisect 'start'
git bisect 'bad' "${BAD_REVISION}"
git bisect 'good' "${GOOD_REVISION}"

git bisect run ${WORKSPACE}/run-test.sh
