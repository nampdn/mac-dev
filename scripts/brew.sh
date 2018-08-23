#!/bin/bash

# Install Homebrew on fresh new machine.
install_homebrew() {
  if ! command -v brew >/dev/null; then
    fancy_echo "Installing Homebrew ..."
      curl -fsS \
        'https://raw.githubusercontent.com/Homebrew/install/master/install' | ruby

      # shellcheck disable=SC2016
      append_to_file "$shell_file" 'export PATH="/usr/local/bin:$PATH"'
  else
    fancy_echo "Homebrew already installed. Skipping ..."
  fi
}

# Check whether an app is installed in Brew.
brew_is_installed() {
  brew list -1 | grep -Fqx "$1"
}

# Check whether a tap is tapped in Brew.
tap_is_installed() {
  brew tap -1 | grep -Fqx "$1"
}

# Check for Brew installation.
check_brew() {
  if brew_is_installed 'brew-cask'; then
    brew uninstall --force 'brew-cask'
  fi

  if tap_is_installed 'caskroom/versions'; then
    brew untap caskroom/versions
  fi

  fancy_echo "Updating Homebrew..."
  brew update

  fancy_echo "Verifying the Homebrew installation..."
  if brew doctor; then
    fancy_echo "Your Homebrew installation is good to go."
  else
    fancy_echo "Your Homebrew installation reported some errors or warnings."
    echo "If the warnings are related to Python, you can ignore them."
    echo "Otherwise, review the Homebrew messages to see if any action is needed."
  fi
}

# Override user config Brewfile from user repo instead of default Brewfile.
override_user_brewfile() {
  local repo="$1"
  local user_brewfile="$DEVFOR_USER/apps/Brewfile"
  if [ ! -f $user_brewfile ]; then
      fancy_echo "Using default Brewfile"
  else
      rm -rf "$DEVFOR_ROOT/Brewfile"
      sudo ln -s $user_brewfile "$DEVFOR_ROOT/Brewfile"
      fancy_echo "Symlinked $user_brewfile to $DEVFOR_ROOT/Brewfile"
  fi
}


install_brewfile() {
  fancy_echo "Installing formulas and casks from the Brewfile ..."
  if brew bundle --file="$DEVFOR_ROOT/Brewfile"; then
    fancy_echo "All formulas and casks were installed successfully."
  else
    fancy_echo "Some formulas or casks failed to install."
    echo "This is usually due to one of the Mac apps being already installed,"
    echo "in which case, you can ignore these errors."
  fi
}
