#!/usr/bin/env zsh

# Default function
repo-cleaner() {
    starting=$(pwd) #store the current directory, so we can come back to it
    if [ -n "$REPOSITORY_DIR" ];
    then
        echo "REPOSITORY_DIR value is set";
        repo-cleaner-iterate $(find  $REPOSITORY_DIR -maxdepth 1 -type d)
    else
        echo "REPOSITORY_DIR value is NOT set";
        echo "Finding repositories. This might take  a minute ..."
        repo-cleaner-iterate $(find $HOME -name .git -type d)
    fi
    cd $starting # go back to the starting point
}


# Iterates through given folders
repo-cleaner-iterate() {
    echo "iterating"
    reset="\033[0m"
    for folder in "$@";
    do
        folder=$(echo $folder | sed 's/\.git\///g')
        cd $folder
        branch="$(git name-rev --name-only HEAD)"
        echo -e "${reset}====================================================================="
        echo "$(pwd) [$branch]"
        repo-cleaner-update
    done
}

repo-cleaner-is-repo() {
    echo "checking"
    result="$(git status)"

    echo $result;

    if [[ -n $result ]];
    then
        echo "is a repo";
        return 0;
    else
        echo "is NOT a repo";
        return 1;
    fi
}

# Updates all of the git stuff in a folder
repo-cleaner-update() {
    echo "updating"
    if repo-cleaner-is-repo $(pwd);
    then
        red="\033[01;31m"
        green="\033[0;32m"
        echo -e "$red"
        repo-cleaner-handle-remotes
        echo -e "$green"
        git prune
        git gc --aggressive
        git fsck --full
    fi
}

# Perform the fetching, pruning, and pulling of remotes
repo-cleaner-handle-remotes() {
    branch="$(git name-rev --name-only HEAD)"
    remotes=$(git remote)

    # Big assumption here, but I'm going with it for now
    git pull origin $branch
    for remote in $remotes
    do
        git fetch $remote
        git remote prune $remote
    done

}

repo-cleaner