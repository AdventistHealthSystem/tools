#!/bin/bash

# Iterates through given folders
repo-cleaner-iterate() {
    RESET="\033[0m"
    for DIR in "$@";
    do
        cd "$DIR/../"
        BRANCH="$(git name-rev --name-only HEAD)"
        echo -e "${RESET}====================================================================="
        echo "$DIR [$BRANCH]"
        repo-cleaner-update
    done
}

# Updates all of the git stuff in a folder
repo-cleaner-update() {
    RED="\033[01;31m"

    git fetch origin
    git pull origin $BRANCH
    echo -e "\n${RED}git remote prune origin"
    git prune
    git gc --aggressive
    git fsck --full
}

repo-cleaner-iterate $(find $HOME -name .git -type d)