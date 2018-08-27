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

# Load brew script
. "$WORKDIR/brew.sh"
install_homebrew
check_brew
override_user_brewfile
install_brewfile

# Load nodejs script
. "$WORKDIR/nodejs.sh"
install_nvm

# Load font script
. "$WORKDIR/font.sh"
copy_fonts "$DEVFOR_USER/fonts"

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
