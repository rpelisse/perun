#!/bin/bash
set -eo pipefail

#good revision, we consider current one as bad?
REVISION=""
#url of diff file containig testsuite diff from EAP root. This has to be addition only diff, since revision jumping might affect testsuite.
TEST_DIFF=""
#test to run from suite, either existing one or one that comes from $TEST_DIFF
TEST="*.Test"

if [ ! -z $TEST_DIFF ]; then
    wget $TEST_DIFF -O test.diff
	if [ $? -ne 0 ]; then
		echo "GIT-BISECT: Failed to retrieve test diff."
		return 1
	else
		patch -p 1 -i test.diff
		if [ $? -ne 0 ]; then
			echo "GIT-BISECT: Failed to patch repository with supplied diff."
			return 1
		else
			#TODO: validate compilation?
		fi
	fi

fi

git bisect start
git bisect bad
git bisect good $REVISION

BLAME_REVISION=""

while [ -z $BLAME_REVISION ]
do
	#BUILD
	#TODO: XXX is this good?
	export TESTSUITE_OPTS="-DskipTests"
	/opt/jboss-set-ci-scripts/harmonia-eap-build
	if [ $? -ne 0 ]; then
		echo "GIT-BISECT: Failed to build project."
		#NOTE: this can happen if commits are half assed.
		return 1
	fi

	#TEST
	#bash -x ./integration-tests.sh -DallTests -fae -Dtest=$TEST
	#TODO: XXX is this good?
	export TESTSUITE_OPTS="-Dtest=$TEST"
	/opt/jboss-set-ci-scripts/harmonia-eap-build 'testsuite'
	BISECT_RESULT=""
	if [ $? -ne 0 ]; then
		#Outcome is good
		BISECT_RESULT=`git bisect good`
	else
		#Outcome is bad
		BISECT_RESULT=`git bisect bad`
	fi
	#Check if we are done
	#IF DONE BLAME_REVISION=BISECT_RESULT.stripSearch()
	if [[ $BISECT_RESULT == *"is the first bad commit"* ]]; then
  		BLAME_REVISION=$BISECT_RESULT
	fi
done

echo "GIT-BISECT: Finished bisect with result \"$BLAME_REVISION\"."
