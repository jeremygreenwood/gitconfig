#!/bin/bash
#
# todo_blame.sh
#
# Searches code for todo's and determines person most suitable for addressing issue (as todo may have been put 
# there by someone unfamiliar with the code.
#
# NOTE there is no functionality to check individual files or directories non-recursively
#

VERBOSE=false

if [ -z ${GCC_HOME} ]; then
    echo "Error: GCC_HOME does not exist.  This script must be called from a makefile that includes Rules.make."
    exit 1
fi

# Number of lines above and below line with "TODO" or "todo" to use for determining who should address in code,
# which is determined using git blame
LINES_NEAR=10

# Temporary file
TMP_FILE=~/.todo.tmp


verbose_echo()
    {
    if [ $VERBOSE == true ]; then
        echo $@
    fi
    }


# Takes following parameters:
# 1: file path
# 2: line number
email_get()
    {   
    FILE_PATH=$1
    LINE_NUM=$2

    # Calculate start and end lines, and bounds check
    FILE_NUM_LINES=`cat $FILE_PATH | wc -l`    

    LINE_START=$(( $LINE_NUM - $LINES_NEAR ))
    LINE_START=$(( $LINE_START < 0 ? 0 : $LINE_START ))

    LINE_END=$(( $LINE_NUM + $LINES_NEAR ))
    LINE_END=$(( $LINE_END > $FILE_NUM_LINES ? $FILE_NUM_LINES : $LINE_END ))

    echo `git blame -p $FILE_PATH -L $LINE_START,$LINE_END | grep ^author-mail | sort | uniq -c | sort -rn | head -n 1 | awk '{ print $NF; }' | sed 's/[<>]//g'`
    }

# Recursively finds todos in files (matching regex) in current directory
# Takes following parameters:
# 1: file regex
todo_get()
    {
    local FIL_REGEX=$1

    grep -nrIi todo --include="$FIL_REGEX" *
    }

# takes one parameter:
# 1: the directory to process (recursively)
dir_proc()
    {
    local DIR=$1
    local FIL_REGEX=$2

    if [ ! -d "$DIR" ]; then
        echo "Error: $DIR is not a directory"
        exit 1
    fi

    cd "$DIR"

    todo_get "$FIL_REGEX" | while read LINE
    do
        verbose_echo "LINE: $LINE"

        FILE_PATH=`echo $LINE | sed 's/:.*$//'`
        verbose_echo "file: $FILE_PATH"

        LINE_NUM=`echo $LINE | sed "s,$FILE_PATH:,," | sed 's/:.*$//'`
        verbose_echo "line number: $LINE_NUM"

        EMAIL_ADDR=`email_get "$FILE_PATH" "$LINE_NUM"`

        echo -e "$EMAIL_ADDR\t$FILE_PATH:$LINE_NUM" >> $TMP_FILE
    done
    }


# Clear the temporary file
echo '' > $TMP_FILE


# Get todo's in application code
dir_proc ${GCC_HOME}/application '*'


# Get todo's in kernel module code
dir_proc ${GCC_HOME}/extra-drivers/gcc-bridge '*'
dir_proc ${GCC_HOME}/extra-drivers/gcc-log '*'


# Get todo's in scripts
dir_proc ${GCC_HOME}/tools '*'
dir_proc ${GCC_HOME}/rootfs/post-bitbake '*'


# Sort the results in the temp file and display as output, "ignoring not committed yet" email and todo_blame.sh file
sort $TMP_FILE | grep -v "^not.committed.yet\|todo_blame.sh" | column -t

# Cleanup
rm $TMP_FILE
