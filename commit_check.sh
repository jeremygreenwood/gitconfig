# iop_commit_check.sh
#
# TODO setup a scheduler to run this and send mail. See https://blog.e-zest.com/tutorial-setting-up-cron-job-task-scheduler-in-windows

# CONSTANTS
GIT_REPO_DIR='repo_clone'
DEV_BRANCH='master'
DIRECTORY_TO_CHECK='test_dir'
USER='username'

SUBJECT='TEST EMAIL'

function pause(){
    read -s -n 1 -p "Press any key to continue . . ."
    echo ""
}

cd "$GIT_REPO_DIR"


git checkout development_branch



# Get previous tip of dev sha (assumes the current SHA is where the script was last run from)
GIT_SHA_PREV=$(git log -1 --format=format:"%H")

# Checkout tip of dev
git pull origin $DEV_BRANCH

# Get current tip of dev sha
GIT_SHA_CUR=$(git log -1 --format=format:"%H")


# Check for new changes to directory where code may have been borked again
echo "Previous GIT SHA: $GIT_SHA_PREV"
echo "Current GIT SHA: $GIT_SHA_CUR"

# Check if previous git SHA is the same as current
if [[ "$GIT_SHA_PREV" == "$GIT_SHA_CUR" ]]; then
	# there are no new commits and nothing to do (so exit)
    echo "No new commits to repo, quitting"
	pause
	exit
fi

# Get a list of commits between previous and current GIT SHAs
sha_list=$(git rev-list --ancestry-path $GIT_SHA_PREV..$GIT_SHA_CUR)

#echo "SHA list:"
#echo "$sha_list"

#for sha in "$sha_list"; do

ored_sha_string=""
first_sha=1
for sha in $(git rev-list --ancestry-path $GIT_SHA_PREV..$GIT_SHA_CUR); do
	sha=${sha:0:7}
	#echo "SHA:"
    #echo $sha
	if [[ $first_sha == 1 ]]; then
	    ored_sha_string="^${sha}"
		first_sha=0
	else
	    ored_sha_string="${ored_sha_string}\|^${sha}"
	fi
done


#echo "ored_sha_string:"
#echo "$ored_sha_string"



# Get changes associated with the directory
cd src/$DIRECTORY_TO_CHECK

# TODO save the output 
git_blame_result="$(git ls-files -z | xargs -0n1 git blame -w | grep $USER | grep -i 'need\|fix\|todo\|redo\|update' | grep "$ored_sha_string")"

echo "$git_blame_result"

#- git parsing commented out code by <user> in directory:
#	$ git ls-files -z | xargs -0n1 git blame -w | grep $USER | grep -E '\) [[:space:]]*//'
#- git parsing todos/fix/etc comments by <user> in directory:
#	$ git ls-files -z | xargs -0n1 git blame -w | grep $USER | grep -i 'need\|fix\|todo\|redo\|update'


pause
exit		

EMAIL_TEXT="Previous GIT SHA: $GIT_SHA_PREV"
EMAIL_TEXT+=$'<br>'
EMAIL_TEXT+="Current GIT SHA: $GIT_SHA_CUR"

echo "msg: $EMAIL_TEXT"

python C:/Users/greenwoodj/Workspace/Programming/Git/git_parser/send_email.py "$EMAIL_TEXT" "$SUBJECT" "jeremymgreenwood@gmail.com"

pause
exit