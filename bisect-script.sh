#!/bin/bash
set -eo pipefail

#good revision, we consider current one as bad?
readonly GOOD_REVISION=${GOOD_REVISION}
readonly BAD_REVISION=${BAD_REVISION}
#url of a patch file (a diff) containing the changes required to insert
# the reproducer into EAP existing testsuite.
readonly REPRODUCER_PATCH_URL=${REPRODUCER_PATCH_URL}
#test to run from suite, either existing one or one that comes from $TEST_DIFF
readonly TEST_NAME=${TEST_NAME:-"*.*TestCase" }
set -u

readonly REPRODUCER_PATCH=${PATCH_HOME:-$(mktemp)}
curl "${REPRODUCER_PATCH_URL}" -O "${REPRODUCER_PATCH}"
if [ ! -e "${REPRODUCER_PATCH}" ]; then
  export REPRODUCER_PATCH
fi

git bisect 'start'
git bisect 'bad' "${BAD_REVISION}"
git bisect 'good' "${GOOD_REVISION}"

git bisect run ./run-test.sh