#!/bin/bash

install_user_apps() {
  local user_apps_dir="$1"
  if [ -f "$user_apps_dir/install.sh" ]; then
    echo "Executing user apps dir..."
    /usr/bin/env bash "$user_apps_dir/install.sh" $user_apps_dir
  fi
}

link_dotfiles() {
  local dotfile_dir="$1"
  if [ -d $dotfile_dir ]; then
    echo "Linking dotfiles to $HOME..."
    find $dotfile_dir -type f | xargs -I {} ln -s -f "{}" $HOME
  fi
}
