#!/bin/bash
# Usage: numbered_branch.sh
# Notes: it is suggested to create a symbolic link in user home directory pointing to this file


if [ $# -gt 0 ]; then
    OPTION="$1"
else
    OPTION=""
fi

REMOVE_OPT='false'

if [ "$OPTION" == '-r' ]; then
	REMOVE_OPT='true'
fi

NUM=1
DONE='false'
while [ $DONE == 'false' ]; do
	BRANCH_NAME="$( git gcb )_$NUM"
	git rev-parse --verify $BRANCH_NAME > /dev/null 2>&1
	BRANCH_EXISTS=$?
	
	if [ $BRANCH_EXISTS -ne 0 ]; then
		if [ $REMOVE_OPT == 'false' ]; then
			git branch $BRANCH_NAME
			if [ $? -eq 0 ]; then
				echo "Created local branch $BRANCH_NAME"
			else
				echo "Failed to create local branch $BRANCH_NAME"
			fi
		fi
		DONE='true'
	else
		if [ $REMOVE_OPT == 'true' ]; then
			git branch -d $BRANCH_NAME
		fi
	fi
	
	if [ $NUM -eq 100 ]; then
		echo "Warning: found 100 numbered branches"
	fi
	
	NUM=$((NUM + 1))
done