#!/bin/bash
set -eo pipefail

readonly REPRODUCER_PATCH="${REPRODUCER_PATCH}"
readonly TEST="${TEST_NAME}}"

set -u
if [ -e "${REPRODUCER_PATCH}" ]; then
	echo "Patching ...."
	patch -p1 -i "${REPRODUCER_PATCH}"
else
	echo "No patch file provided, skipping"
fi

# TODO if patch fails, we need to skip test and print a message that the test is not compatible with the revision skipped

if [ -z "${TEST}" ]; then
  echo 'No TEST provided.'
  return 1
fi


echo -n 'Building ...'

export TESTSUITE_OPTS="-DskipTests"
/opt/jboss-set-ci-scripts/harmonia-eap-build

echo 'Done.'

echo -n 'Running testsuite ...'
export TESTSUITE_OPTS="-Dtest=$TEST"
export MAVEN_OPTS="-X"
/opt/jboss-set-ci-scripts/harmonia-eap-build 'testsuite'

if [ -e "${REPRODUCER_PATCH}" ]; then
	echo -n 'Cleaning up after patch ...'
patch -p1 -i "${REPRODUCER_PATCH}" -R
fi
