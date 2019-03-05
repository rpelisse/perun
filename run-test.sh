#!/bin/bash
set -eo pipefail

cleanPatch() {
if [ -e "${REPRODUCER_PATCH}" ]; then
  echo -n '[PERUN]: Cleaning up after patch ...'
  patch -p1 -i "${REPRODUCER_PATCH}" -R
fi
}

trap cleanPatch EXIT

readonly REPRODUCER_PATCH="${REPRODUCER_PATCH}"
readonly TEST="${TEST_NAME}"

set -u
if [ -e "${REPRODUCER_PATCH}" ]; then
  echo -n "[PERUN]: Patching ...."
  patch -p1 -i "${REPRODUCER_PATCH}"
else
  echo -n "[PERUN]: No patch file provided, skipping"
fi

# TODO if patch fails, we need to skip test and print a message that the test is not compatible with the revision skipped

if [ -z "${TEST}" ]; then
  echo -n '[PERUN]: No TEST provided.'
  return 1
fi


echo -n '[PERUN]: Building ...'

export BUILD_OPTS="-DskipTests"
bash -x /opt/jboss-set-ci-scripts/harmonia-eap-build

echo -n '[PERUN]: Done.'

echo -n '[PERUN]: Running testsuite ...'
export TESTSUITE_OPTS="-Dtest=$TEST"
export MAVEN_OPTS="-X"
echo "[PERUN]: Start testsuite"
date +%Y%m%d:%H:%M:%S:%N
bash -x /opt/jboss-set-ci-scripts/harmonia-eap-build 'testsuite'
echo -n "[PERUN]: Stop testsuite"
date +%Y%m%d:%H:%M:%S:%N

