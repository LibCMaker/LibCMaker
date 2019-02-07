#!/bin/bash
## brief: trigger a downstream travis build
## see: travis API documentation

# variables
USER=$1
REPO=$2
TRAVIS_ACCESS_TOKEN=$3
BRANCH=$4
MESSAGE=$5

# login to travis and get token
travis login --com --skip-completion-check --github-token $TRAVIS_ACCESS_TOKEN
travis whoami --com --skip-completion-check
TOKEN=$(travis token --com --skip-completion-check)
IFS=' ' read -r -a array <<< "$TOKEN"
TOKEN=${array[${#array[@]}-1]}

# inspired from plume-lib, check arguments and add message
if [ $# -eq 5 ] ; then
    MESSAGE=",\"message\": \"$5\""
elif [ -n "$TRAVIS_REPO_SLUG" ] ; then
#    MESSAGE=",\"message\": \"Triggered from upstream build of $TRAVIS_REPO_SLUG by commit "`git rev-parse --short HEAD`"\""
    MESSAGE=",\"message\": \"Commit "`git rev-parse --short HEAD`" from $TRAVIS_REPO_SLUG triggered this build.\""
fi

# for debugging
echo "USER=$USER"
echo "REPO=$REPO"
#echo "TOKEN: ${array[${#array[@]}-1]}"
echo "BRANCH=$BRANCH"
echo "MESSAGE=$MESSAGE"

# curl POST request content body
BODY="{
  \"request\": {
  \"branch\":\"$BRANCH\"
  $MESSAGE
}}"

# Make a POST request with curl (note %2F).
# The %2F in the request URL is required so that the owner and repository name
# in the repository slug are interpreted as a single URL segment.
curl -s -X POST \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -H "Travis-API-Version: 3" \
  -H "Authorization: token ${TOKEN}" \
  -d "$BODY" \
  https://api.travis-ci.com/repo/${USER}%2F${REPO}/requests \
  | tee /tmp/travis-request-output.$$.txt

if grep -q '"@type": "error"' /tmp/travis-request-output.$$.txt; then
   cat /tmp/travis-request-output.$$.txt
   exit 1
elif grep -q 'access denied' /tmp/travis-request-output.$$.txt; then
   cat /tmp/travis-request-output.$$.txt
   exit 1
fi
