#!/bin/bash

git_config() {
    local user_git_config_file="$1"
    if [ ! -f $user_git_config_file ]; then
        echo "Your git config script at $user_git_config_file does not exist, please config Git manually!"
        printf "Enter Git user.name: "
        read username
        printf "Enter Git user.email: "
        read email
        git config --global user.name $username
        git config --global user.email $email
    else
        /usr/bin/env bash "$user_git_config_file"
        echo "Loaded Git config from $user_git_config_file"
    fi
    echo "Apply git config success!"
    git config --list
}

sync_user_repo() {
    local repo="$1"
    if [ "$repo" = "" ]; then
        fancy_echo "Skip repo configuration!"
    else
        if [ ! -d "$DEVFOR_USER" ]; then
            fancy_echo "Cloning your configuration repo to: $DEVFOR_REPO"
            git clone $repo $DEVFOR_USER
        else
            fancy_echo "Updating your configuration repo to: $DEVFOR_REPO"
            pushd $DEVFOR_USER
            git checkout .
            git pull origin master
            popd
        fi
        echo "$repo" > "$DEVFOR_REPO"
    fi
}

git_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}
