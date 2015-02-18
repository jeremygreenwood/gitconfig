#!/bin/bash
# Usage: blame.sh <filename> [start] [end]
# Notes: it is suggested to create a symbolic link in user home directory pointing to this file

COLOR_CYAN="\e[0;36m"
COLOR_NC="\e[0m"
WHOLE_FILE=false

FILE_REGEX="$1"

if [ $# -gt 1 ]; then
    START="$2"
else
    WHOLE_FILE=true
fi

if [ $# -gt 2 ]; then
    END="$3"
else
    END="$START"
fi

for FILE in $( find . -name "${FILE_REGEX}" -printf "%P\n" )
do
    if [ ${WHOLE_FILE} == true ]; then
        FILE_LEN=$( wc -l < "${FILE}" | tr -d '[[:space:]]' )
        START=1
        END=${FILE_LEN}
    fi
	
    BASH_RSLT="$( git blame "${FILE}" -L ${START},${END} 2> /dev/null )"
	
    if [ -n "${BASH_RSLT}" ]; then
        echo -e "${COLOR_CYAN}${FILE}${COLOR_NC}"
        echo "${BASH_RSLT}"
    fi
done