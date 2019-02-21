#!/bin/bash
set -eo pipefail

#good revision, we consider current one as bad?
readonly GOOD_REVISION=${1}
readonly BAD_REVISION=${2}
#url of diff file containig testsuite diff from EAP root. This has to be addition only diff, since revision jumping might affect testsuite.
readonly TEST_DIFF=${2}
#test to run from suite, either existing one or one that comes from $TEST_DIFF
readonly TEST=${TEST:-"*.Test" }
readonly DIFF_FILE=${4:-'test.diff'}

if [ -n "${TEST_DIFF}" ]; then
    wget "${TEST_DIFF}" -O "${DIFF_FILE}"
	if [ $? -ne 0 ]; then
		echo "GIT-BISECT: Failed to retrieve test diff."
		return 1
	else
		patch -p 1 -i "${DIFF_FILE}"
		if [ $? -ne 0 ]; then
			echo "GIT-BISECT: Failed to patch repository with supplied diff."
			return 1
		else
			#TODO: validate compilation?
		fi
	fi

fi

git bisect 'start'
git bisect 'bad' "${BAD_REVISION}"
git bisect 'good' "${GOOD_REVISION}"

git bisect run  ./run-test.sh
