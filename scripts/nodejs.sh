#!/bin/bash

setup_nvm() {
    fancy_echo 'Checking on Node.js installation...'
    
    if ! brew_is_installed "node"; then
        if command -v n > /dev/null; then
            fancy_echo "We recommend using \`nvm\` and not \`n\`."
            fancy_echo "See https://pages.18f.gov/frontend/#install-npm"
            elif ! command -v nvm > /dev/null; then
            fancy_echo 'Installing nvm and lts Node.js and npm...'
            curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.0/install.sh | bash
            export NVM_DIR="$HOME/.nvm"
            # shellcheck source=/dev/null
            [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
            nvm install node --lts
        else
            fancy_echo 'version manager detected.  Skipping...'
        fi
    else
        brew bundle --file=- <<EOF
            brew 'node'
EOF
    fi
    
    fancy_echo '...Finished Node.js installation checks.'
}