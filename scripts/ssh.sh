#!/bin/bash

SSH_DIR="$HOME/.ssh"
DEFAULT_SSH_KEY="$SSH_DIR/id_rsa"
GENERATED_SSH_KEY="$SSH_DIR/id_rsa_devfor"

# Eval ssh agent and add ssh-key.
add_ssh_key() {
    local SSH_KEY_NAME="$1"
    eval "$(ssh-agent -s)"
    ssh-add "$SSH_KEY_NAME" && echo "SSH key added: $SSH_KEY_NAME"
}

# Generate new ssh key.
generate_ssh_key() {
    local generated_key="$1"
    printf "Enter your Git email: "
    read email
    ssh-keygen -t rsa -b 4096 -C "$email" -N "" -f $generated_key
    printf "Here is your public ssh-key: "
    cat "$generated_key.pub"
}

# Symlink existing ssh folder.
symlink_ssh_dir() {
    local ssh_in_repo="$1"
    local ssh_to_link="$ssh_in_repo/id_rsa"*
    sudo ln -s $ssh_to_link $SSH_DIR
    chmod 600 "$ssh_in_repo/id_rsa"* # Need to making it read only by owner, required by ssh agent.
    echo "SSH key successfully symlinked from $devfor_user to $SSH_DIR"
}

# Main function to make sure ssh key works.
make_ssh_key() {
    local devfor_user="$1"

    if [ ! -d $SSH_DIR ]; then
        mkdirp -p $SSH_DIR
    fi

    if [ -d $devfor_user ]; then
        symlink_ssh_dir $devfor_user
        add_ssh_key $DEFAULT_SSH_KEY
    else
        read -p "Not found \"ssh\" directory in user_config repo, do you want to generate one? (Y/n) :" -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]
            generate_ssh_key $GENERATED_SSH_KEY
            add_ssh_key $GENERATED_SSH_KEY
            echo $(cat "$GENERATED_SSH_KEY.pub") | pbcopy
            echo
            echo "The public key has been copied to clipboard, let paste it on your remote!"
        then
            [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
        fi
    fi
}

# Uncomment the line below to debug.
# make_ssh_key $1