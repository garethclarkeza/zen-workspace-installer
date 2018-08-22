# Install node and npm via nvm - https://github.com/creationix/nvm
function install_node_setup {
    set -e

    # Define versions
    local INSTALL_NODE_VER=${NODE_VERSION}
    local INSTALL_NVM_VER=${NVM_VERSION}

    # You can pass argument to this script --version 8
    if [ "$1" = '--version' ]; then
        echo -e "${GREEN}[INSTALLING]${WHITE}\tUsing specified node version - $2${NC}"
        INSTALL_NODE_VER=$2
    fi

    echo -e "${GREEN}[INSTALLING]${WHITE}\tInstalling node version manager version $INSTALL_NVM_VER${NC}"
    # Removed if already installed
    rm -rf ~/.nvm
    # Unset exported variable
    export NVM_DIR=

    # Install nvm
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v${INSTALL_NVM_VER}/install.sh | bash
    # Make nvm command available to terminal
    source ~/.nvm/nvm.sh

    echo -e "${GREEN}[INSTALLING]${WHITE}\tInstalling node js version $INSTALL_NODE_VER${NC}"
    nvm install ${INSTALL_NODE_VER}

    echo -e "${GREEN}[INSTALLING]${WHITE}\tMake this version system default${NC}"
    nvm alias default ${INSTALL_NODE_VER}
    nvm use default

    echo -e "${GREEN}[INSTALLING]${WHITE}\tUpdate npm to latest version, if this stuck then terminate (CTRL+C) the execution${NC}"
    npm install -g npm

    echo -e "${GREEN}[INSTALLING]${WHITE}\tInstalling Yarn package manager${NC}"
    rm -rf ~/.yarn
    curl -o- -L https://yarnpkg.com/install.sh | bash

    # Yarn configurations
    export PATH="$HOME/.yarn/bin:$PATH"
    yarn config set prefix ~/.yarn -g
    yarn global add @vue/cli

    echo -e "${GREEN}[INSTALLING]${WHITE}\tChecking for versions"
    echo -e "${GREEN}[INSTALLING]${WHITE}\tNVM ${INSTALL_NVM_VER} installed"
    echo -e "${GREEN}[INSTALLING]${WHITE}\tNodeJS $(node --version) installed"
    echo -e "${GREEN}[INSTALLING]${WHITE}\tNPM $(npm --version) installed"
    echo -e "${GREEN}[INSTALLING]${WHITE}\tYarn $(yarn --version) installed${NC}"
}
