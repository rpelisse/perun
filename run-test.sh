#!/bin/bash
set -eo pipefail

cleanPatch() {
if [ -e "${REPRODUCER_PATCH}" ]; then
  echo '[PERUN]: Cleaning up after patch ...'
  patch -p1 -i "${REPRODUCER_PATCH}" -R
  patch -p1 -i "${INTEGRATION_SH_PATCH}" -R
fi
}

trap cleanPatch EXIT

readonly REPRODUCER_PATCH="${REPRODUCER_PATCH}"
readonly TEST="${TEST_NAME}"

readonly CURRENT_REVISION=$(git rev-parse HEAD)
if [[ $CORRUPT_REVISIONS == *"${CURRENT_REVISION}"* ]]; then
  echo "[PERUN]: Current revision \"${CURRENT_REVISION}\" is in corrupt list, skipping."
  #125 - special git value to indicate `bisect skip`
  exit 125
fi
set -u

if [ -e "${INTEGRATION_SH_PATCH}" ]; then
  echo "[PERUN]: Patching integration script...."
  patch -p1 -i "${INTEGRATION_SH_PATCH}"
else
  echo "[PERUN]: No integration.sh patch file provided, skipping"
  exit 1
fi

if [ -e "${REPRODUCER_PATCH}" ]; then
  echo "[PERUN]: Patching tests...."
  patch -p1 -i "${REPRODUCER_PATCH}"
else
  echo "[PERUN]: No tests patch file provided, skipping"
fi

# TODO if patch fails, we need to skip test and print a message that the test is not compatible with the revision skipped

if [ -z "${TEST}" ]; then
  echo '[PERUN]: No TEST provided.'
  exit 1
fi


echo '[PERUN]: Building ...'

export BUILD_OPTS="-DskipTests"
bash -x /opt/jboss-set-ci-scripts/harmonia-eap-build

echo '[PERUN]: Done.'

echo '[PERUN]: Running testsuite ...'
export TESTSUITE_OPTS="-Dtest=$TEST"
export MAVEN_ARGS="-X"
echo "[PERUN]: Start testsuite"
date +%Y%m%d:%H:%M:%S:%N
bash -x /opt/jboss-set-ci-scripts/harmonia-eap-build 'testsuite'
echo "[PERUN]: Stop testsuite"
date +%Y%m%d:%H:%M:%S:%N

