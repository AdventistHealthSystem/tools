#!/bin/bash

DIRS="/$HOME/Repositories/"

for DIR in $(find $DIRS* -maxdepth 0 -type d );
do
    cd $DIR
    BRANCH="$(git name-rev --name-only HEAD)"
    echo "====================================================================="
    echo "$DIR [$BRANCH]"

    git fetch origin
    git pull origin $BRANCH
    git remote prune origin
    git prune
    git gc --aggressive
    git fsck --full
done
