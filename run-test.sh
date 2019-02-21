#!/bin/bash
set -eo pipefail

readonly TEST=${1:-${TEST}}

set -u

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
