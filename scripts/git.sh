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
