#!/bin/bash
set -eo pipefail

readonly REPRODUCER_PATCH=${REPRODUCER_PATCH}
readonly TEST=${TEST_NAME}}

set -u

patch -p1 -i ${REPRODUCER_PATCH}
# TODO if patch fails, we need to skip test and print a message that the test is not compatible with the revision skipped

if [ -z "${TEST}" ]; then
  echo 'No TEST provided.'
  echo 1
fi

echo -n 'Building ...'

export TESTSUITE_OPTS="-DskipTests"
/opt/jboss-set-ci-scripts/harmonia-eap-build

echo 'Done.'

echo -n 'Running testsuite ...'
export TESTSUITE_OPTS="-Dtest=$TEST"
/opt/jboss-set-ci-scripts/harmonia-eap-build 'testsuite'

echo -n 'Cleaning up after patch ...'
patch -p1 -i ${REPRODUCER_PATCH} -R