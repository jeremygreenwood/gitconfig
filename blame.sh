#!/bin/bash
# Note: An unsuccessful attempt was made to convert to single line git alias function using the following command:
#   cat blame.sh | grep . | sed 's/ \+/ /' | awk 'NR>3' ORS='; ' | sed -e 's/\"/\\"/g'

COLOR_CYAN="\e[0;36m"
COLOR_NC="\e[0m"

FILE_REGEX="$1"
START="$2"
if [ $# -gt 2 ]; then
    END="$3"
else
    END="$START"
fi

for FILE in $( find . -name "${FILE_REGEX}" -printf "%P\n" )
do
    BASH_RSLT="$( git blame "${FILE}" -L ${START},${END} 2> /dev/null )"
    if [ -n "${BASH_RSLT}" ]; then
        echo -e "${COLOR_CYAN}${FILE}${COLOR_NC}"
        echo "${BASH_RSLT}"
    fi
done