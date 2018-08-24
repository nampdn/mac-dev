
#!/bin/bash

create_zshrc_and_set_it_as_shell_file() {
    if [ ! -f "$HOME/.zshrc" ]; then
        touch "$HOME/.zshrc"
    fi
    
    shell_file="$HOME/.zshrc"
}

create_bash_profile_and_set_it_as_shell_file() {
    if [ ! -f "$HOME/.bash_profile" ]; then
        touch "$HOME/.bash_profile"
    fi
    
    shell_file="$HOME/.bash_profile"
}

set_default_shell() {
    case "$SHELL" in
        */zsh) :
            create_zshrc_and_set_it_as_shell_file
        ;;
        *)
            create_bash_profile_and_set_it_as_shell_file
            if [ -z "$CI" ]; then
                bold=$(tput bold)
                normal=$(tput sgr0)
                echo "Want to switch your shell from the default ${bold}bash${normal} to ${bold}zsh${normal}?"
                echo "Both work fine for development, and ${bold}zsh${normal} has some extra "
                echo "features for customization and tab completion."
                echo "If you aren't sure or don't care, we recommend ${bold}zsh${normal}."
                echo "Note that you can always switch back to ${bold}bash${normal} if you change your mind."
                echo "Please see the README for instructions."
                echo -n "Press ${bold}y${normal} to switch to zsh, ${bold}n${normal} to keep bash: "
                read -r -n 1 response
                if [ "$response" = "y" ]; then
                    fancy_echo "=== Getting ready to change your shell to zsh. Please enter your password to continue. ==="
                    echo "=== Note that there won't be visual feedback when you type your password. Type it slowly and press return. ==="
                    echo "=== Press control-c to cancel ==="
                    create_zshrc_and_set_it_as_shell_file
                    ZSH_PATH=$(which zsh)
                    if ! grep -q $ZSH_PATH '/etc/shells'; then
                        echo $ZSH_PATH | sudo tee -a /etc/shells
                    fi
                    chsh -s $(which zsh)
                else
                    fancy_echo "Shell will not be changed."
                fi
            else
                fancy_echo "CI System detected, will not change shells"
            fi
        ;;
    esac
}
