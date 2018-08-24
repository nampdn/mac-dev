#!/bin/bash

install_user_apps() {
  local user_apps_dir="$1"
  if [ -d $user_apps_dir ]; then
    echo "Executing user apps dir..."
    source "$user_apps_dir/install.sh"
  fi
}

link_dotfiles() {
  local dotfile_dir="$1"
  if [ -d $dotfile_dir ]; then
    echo "Linking dotfiles to $HOME..."
    sudo ln -s $dotfile_dir/* $HOME
  fi
}
