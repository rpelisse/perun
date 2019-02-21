#!/bin/bash
set -eo pipefail

readonly REPRODUCER_PATCH=${REPRODUCER_PATCH}
readonly TEST=${TEST}}

set -u

patch -p1 ${REPRODUCER_PATCH}
# TODO if patch fails, we need to skip test and print a message that the test is not compatible with the revision skipped

if [ -z "${TEST}" ]; then
  echo 'No TEST provided.'
  echo 1
fi

echo -n 'Building ...'

export TESTSUITE_OPTS="-DskipTests"
/opt/jboss-set-ci-scripts/harmonia-eap-build
# because of -e, the following block is no longer required:
#if [ $? -ne 0 ]; then
#		echo "GIT-BISECT: Failed to build project."
#		#NOTE: this can happen if commits are half assed.
#		return 1
#	fi
echo 'Done.'

echo -n 'Running testsuite ...'
export TESTSUITE_OPTS="-Dtest=$TEST"
/opt/jboss-set-ci-scripts/harmonia-eap-build 'testsuite'

# TODO: Reverse the patch to ensure git is not perturb by new files or modify file in the repository
