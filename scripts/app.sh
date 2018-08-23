#!/bin/bash

install_user_apps() {
  local user_apps_dir="$1"
  if [ -d $user_apps_dir ]; then
    echo "Executing user apps dir..."
    source "$user_apps_dir/install.sh"
  fi
}
