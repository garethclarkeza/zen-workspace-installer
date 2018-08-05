#!/usr/bin/env bash

# Install node and npm via nvm - https://github.com/creationix/nvm
function installNodeSetup {
    set -e

    # Define versions
    local INSTALL_NODE_VER=${NODE_VERSION}
    local INSTALL_NVM_VER=${NVM_VERSION}

    # You can pass argument to this script --version 8
    if [ "$1" = '--version' ]; then
        echo "==> Using specified node version - $2"
        INSTALL_NODE_VER=$2
    fi

    echo "==> Make sure bash profile exists and writable"
    touch ~/.bash_profile

    echo "==> Installing node version manager version $INSTALL_NVM_VER"
    # Removed if already installed
    rm -rf ~/.nvm
    # Unset exported variable
    export NVM_DIR=

    # Install nvm
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v${INSTALL_NVM_VER}/install.sh | bash
    # Make nvm command available to terminal
    source ~/.nvm/nvm.sh

    echo "==> Installing node js version $INSTALL_NODE_VER"
    nvm install ${INSTALL_NODE_VER}

    echo "==> Make this version system default"
    nvm alias default ${INSTALL_NODE_VER}
    nvm use default

    #echo -e "==> Update npm to latest version, if this stuck then terminate (CTRL+C) the execution"
    #npm install -g npm

    echo "==> Installing Yarn package manager"
    rm -rf ~/.yarn
    curl -o- -L https://yarnpkg.com/install.sh | bash
    # Yarn configurations
    export PATH="$HOME/.yarn/bin:$PATH"
    yarn config set prefix ~/.yarn -g

    echo "==> Checking for versions"
    nvm --version
    node --version
    npm --version
    yarn --version
}

installNodeSetup

