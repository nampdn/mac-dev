#!/bin/bash

WORKDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
DEVFOR_ROOT="$HOME/.devfor"
DEVFOR_USER="$DEVFOR_ROOT/user_config"
DEVFOR_REPO="$DEVFOR_ROOT/.repo"
DEVFOR_USER_SSH="$DEVFOR_USER/ssh"

# Load mac scripts
. "$WORKDIR/mac.sh"
install_cmd_line_tools

# Load util scripts
. "$WORKDIR/utils.sh"

# shellcheck disable=SC2154
trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

set -e

if [ ! -d "$HOME/.bin/" ]; then
    mkdir "$HOME/.bin"
fi

# Load shell script
. "$WORKDIR/shell.sh"
set_default_shell

# Load ruby script
. "$WORKDIR/ruby.sh"

# Append script to shell_file
append_to_file "$shell_file" "alias devfor-script='bash <(curl -s https://raw.githubusercontent.com/nampdn/devfor/master/mac)'"
append_to_file "$shell_file" 'export PATH="$HOME/.bin:$PATH"'

# Load brew script
. "$WORKDIR/ruby.sh"

# shellcheck disable=SC2016
append_to_file "$shell_file" 'eval "$(hub alias -s)"'

# Load git script
. "$WORKDIR/git.sh"
fancy_echo 'Checking on Git configuration...'
git_config "$DEVFOR_USER_SSH/config"

# Sync latest configuration from remote repo
if [ ! -f $DEVFOR_REPO ]; then
    printf "Input git remote repo to restore configuration: "
    read REPO
else
    REPO=$(cat $DEVFOR_REPO)
    fancy_echo "Load saved configuration from: $REPO"
fi
sync_user_repo $REPO

# Load ssh linking/generation
fancy_echo 'Checking on SSH key linking...'
. "$WORKDIR/ssh.sh" # Import ssh file to call its function
make_ssh_key $DEVFOR_USER_SSH

# Load nodejs script
. "$WORKDIR/nodejs.sh"

# Load brew script
. "$WORKDIR/brew.sh"
install_homebrew
install_nvm
check_brew
override_user_brewfile
install_brewfile

# Load font script
. "$WORKDIR/font.sh"
copy_fonts "$DEVFOR_USER/fonts"

fancy_echo 'Checking on Python installation...'

if ! brew_is_installed "python3"; then
  brew bundle --file=- <<EOF
  brew 'pyenv'
  brew 'pyenv-virtualenv'
  brew 'pyenv-virtualenvwrapper'
EOF
    # shellcheck disable=SC2016
    append_to_file "$shell_file" 'if which pyenv > /dev/null; then eval "$(pyenv init -)"; fi'
    # shellcheck disable=SC2016
    append_to_file "$shell_file" 'if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi'
    
    # pyenv currently doesn't have a convenience version to use, e.g., "latest",
    # so we check for the latest version against Homebrew instead.
    latest_python_3="$(brew info python3 | egrep -o "3\.\d+\.\d+" | head -1)"
    
    if ! pyenv versions | ag "$latest_python_3" > /dev/null; then
        pyenv install "$latest_python_3"
        pyenv global "$latest_python_3"
        pyenv rehash
    fi
else
  brew bundle --file=- <<EOF
  brew 'python3'
EOF
fi

if ! brew_is_installed "pyenv-virtualenvwrapper"; then
    if ! pip3 list | ag "virtualenvwrapper" > /dev/null; then
        fancy_echo 'Installing virtualenvwrapper...'
        pip3 install virtualenvwrapper
        append_to_file "$shell_file" 'export VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python3'
        append_to_file "$shell_file" 'export VIRTUALENVWRAPPER_VIRTUALENV=/usr/local/bin/virtualenv'
        append_to_file "$shell_file" 'source /usr/local/bin/virtualenvwrapper.sh'
    fi
fi

fancy_echo '...Finished Python installation checks.'


fancy_echo 'Checking on Ruby installation...'

append_to_file "$HOME/.gemrc" 'gem: --no-document'

if command -v rbenv >/dev/null || command -v rvm >/dev/null; then
    fancy_echo 'We recommend chruby and ruby-install over RVM or rbenv'
else
    if ! brew_is_installed "chruby"; then
        fancy_echo 'Installing chruby, ruby-install, and the latest Ruby...'
        
    brew bundle --file=- <<EOF
    brew 'chruby'
    brew 'ruby-install'
EOF
        
        append_to_file "$shell_file" 'source /usr/local/share/chruby/chruby.sh'
        append_to_file "$shell_file" 'source /usr/local/share/chruby/auto.sh'
        
        ruby-install ruby
        
        append_to_file "$shell_file" "chruby ruby-$(latest_installed_ruby)"
        
        switch_to_latest_ruby
    else
    brew bundle --file=- <<EOF
    brew 'chruby'
    brew 'ruby-install'
EOF
        fancy_echo 'Checking if a newer version of Ruby is available...'
        switch_to_latest_ruby
        
        ruby-install --latest > /dev/null
        latest_stable_ruby="$(cat < "$HOME/.cache/ruby-install/ruby/stable.txt" | tail -n1)"
        
        if ! [ "$latest_stable_ruby" = "$(latest_installed_ruby)" ]; then
            fancy_echo "Installing latest stable Ruby version: $latest_stable_ruby"
            ruby-install ruby
        else
            fancy_echo 'You have the latest version of Ruby'
        fi
    fi
fi

fancy_echo 'Updating Rubygems...'
gem update --system

gem_install_or_update 'bundler'

fancy_echo "Configuring Bundler ..."
number_of_cores=$(sysctl -n hw.ncpu)
bundle config --global jobs $((number_of_cores - 1))

fancy_echo '...Finished Ruby installation checks.'

if app_is_installed 'GitKraken'; then
    fancy_echo "It looks like you've already configured your GitKraken SSH keys."
    fancy_echo "If not, you can do it by signing in to the GitKraken app on your Mac."
    elif [ ! -f "$HOME/.ssh/id_rsa.pub" ]; then
    open ~/Applications/GitKraken.app
fi

if [ -f "$HOME/.devfor.local" ]; then
    # shellcheck source=/dev/null
    . "$HOME/.devfor.local"
fi

# Load user apps.
. "$WORKDIR/app.sh"
install_user_apps "$DEVFOR_USER/apps"
link_dotfiles "$DEVFOR_USER/dotfiles"

fancy_echo 'All done!'
