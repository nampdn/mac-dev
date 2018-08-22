#!/bin/bash

fancy_echo() {
  # shellcheck disable=SC2039
  local fmt="$1"; shift

  # shellcheck disable=SC2059
  printf "\n$fmt\n" "$@"
}

append_to_file() {
  # shellcheck disable=SC2039
  local file="$1"
  # shellcheck disable=SC2039
  local text="$2"

  if [ "$file" = "$HOME/.zshrc" ]; then
    if [ -w "$HOME/.zshrc.local" ]; then
      file="$HOME/.zshrc.local"
    else
      file="$HOME/.zshrc"
    fi
  elif [ "$file" = "$HOME/.bash_profile" ]; then
    file="$HOME/.bash_profile"
  fi

  if ! grep -qs "^$text$" "$file"; then
    printf "\n%s\n" "$text" >> "$file"
  fi
}

brew_is_installed() {
  brew list -1 | grep -Fqx "$1"
}

tap_is_installed() {
  brew tap -1 | grep -Fqx "$1"
}

gem_install_or_update() {
  if gem list "$1" | grep "^$1 ("; then
    fancy_echo "Updating %s ..." "$1"
    gem update "$@"
  else
    fancy_echo "Installing %s ..." "$1"
    gem install "$@"
  fi
}

app_is_installed() {
  # shellcheck disable=SC2039
  local app_name
  app_name=$(echo "$1" | cut -d'-' -f1)
  find /Applications -iname "$app_name*" -maxdepth 1 | egrep '.*' > /dev/null
}

latest_installed_ruby() {
  find "$HOME/.rubies" -maxdepth 1 -name 'ruby-*' | tail -n1 | egrep -o '\d+\.\d+\.\d+'
}
