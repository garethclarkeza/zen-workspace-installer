#!/usr/bin/env bash

function update_status {
    if [[ ! -f ${STATUS_FILE} ]]
    then
        touch ${STATUS_FILE}
    fi

    echo $1 > ${STATUS_FILE}
}

if [[ $1 = 'continue' ]]
then
    echo
    read -p "${RED}Do you want to continue with your installation of Zen Workspace?${WHITE} [Y/n]${NC} " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Nn]$ ]]
    then
        echo
        echo "${RED}Exiting installation process, to restart go to the installation folder and run ./install.sh or re-login.${NC}"
        echo
        exit 0
    fi
fi

if [[ ! -f ~/.bash_profile ]]
then
    echo -e "${BLUE}[PRECHECK]${WHITE}\t\tInstalling default .bash_profile.${NC}"
    cp ${INSTALL_FOLDER}/.bash_profile ~/
fi

# @todo check requirements (git, vim, repo access, branches, etc)
echo -e "${BLUE}[PRECHECK]${WHITE}\t\tChecking for previous installation state...${NC}"

if [[ ! -f ${STATUS_FILE} || $(cat ${STATUS_FILE}) = '' ]]
then
    echo -e "${BLUE}[PRECHECK]${WHITE}\t\tNo previous installations were detected, starting new installation${NC}"
    update_status 'init'
fi

if [[ $(cat ${STATUS_FILE}) =~ 'init' ]]
then
    # Confirm before proceeding with deployment
    echo
    echo "${GREEN}Would you like to install a new version of Zen Workspace?${NC}"
    echo 'Please make sure that the VBoxLinuxAdditions.iso is loaded and the 2 required shares have been setup (see readme).'
    echo
    read -p "${RED}This should only be done once.${WHITE} [Y/n]${NC} " -n 1 -r

    if [[ $REPLY =~ ^[Nn]$ ]]
    then
        echo
        echo "${WHITE}Exiting installation process.${NC}"
        echo
        exit 0
    fi

    update_status 'env'
else
    echo -e "${BLUE}[PRECHECK]${WHITE}\t\tPrevious installation has been detected, continuing installation...${NC}"
fi

# MAKE SURE THE ENV FILE IS INITIALIZED
if [[ $(cat ${STATUS_FILE}) =~ 'env' ]]
then
    if [[ ! -f '~/.zen' ]]
    then
        echo -e "${BLUE}[PRECHECK]${WHITE}\t\tInstaller .zen file not found! Creating one from the default.${NC}"
        cp ${INSTALL_FOLDER}/env-example ${WORKSPACE_ENV_FILE}
        read -p "${CYAN}[CONFIG]${WHITE}${TAB_SPACES}${TAB_SPACES}Press any key to continue and edit your .zen file to fit your requirements...${NC}"
        vim ${WORKSPACE_ENV_FILE}
        ENV_LOADED=true
    fi

    if [[ ! ${ENV_LOADED} ]]
    then
        echo -e "${RED}[ERROR]${WHITE}\t\t\tInstaller .zen file was never loaded, please create an .zen file in your home folder of the installer."
        echo "You can copy from the example file in the installer folder env-example. Exiting installation...${NC}"
        echo
        exit 1
    fi

    update_status 'netplan'

    # BEGIN INSTALLATION
    echo
    echo "${GREEN}Your system is ready to begin installation of your ${WHITE}Zen Workspace${GREEN}!${NC}"
    echo
fi
