#!/usr/bin/env bash

# MAKE SURE YOU NEED RELOADING THIS FILE
if [[ ${WORKSPACE_UTILS_LOADED} = true ]]
then
    return
fi

# Make the ENV variables for this app available
source <(sed -E -n 's/[^#]+/export &/ p' ${WORKSPACE_ENV_FILE})

# GLOBAL INSTALLATION VARIABLES
export WORKSPACE_UTILS_LOADED=true
#export HOST_IP_ADDRESS=${SSH_CLIENT%% *}
#export LOCAL_IP_ADDRESS=$(hostname -I | cut -f1 -d' ')

# FUNCTIONS

# Check to make sure that laradock is installed otherwise exit the script with an error
function die_if_laradock_is_not_installed {
    if [[ ! -f ${WORKSPACE_APP_FOLDER}/services/laradock/.env || ! -f ${WORKSPACE_APP_FOLDER}/services/laradock/docker-compose.yml ]]
    then
        echo -e "${RED}[ERROR]${WHITE}\t\tThere was an error fetching the laradock from (${LARADOCK_REPO}:${LARADOCK_BRANCH}).${NC}"
        echo
        exit 4
    fi
}

# Check to make sure that workspace is installed otherwise exit the script with an error
function die_if_workspace_is_not_installed {
    if [[ ! -f ${WORKSPACE_APP_FOLDER}/readme.md || ! -d ${WORKSPACE_WWW_FOLDER}${WELCOME_PAGE_PATH} ]]
    then
        # todo - Add automated testing for git repo and make sure the folder
        echo -e "${RED}[ERROR]${WHITE}\t\tThere was an error fetching the workspace from the github repo. "
        echo -e "${RED}[ERROR]${WHITE}\t\tPlease check for errors and make sure that your SSH key has been added to ${WORKSPACE_REPO} (if required) and that the workspace folder ${WORKSPACE_ROOT_FOLDER} is empty and retry.${NC}"
        echo
        exit 3
    fi
}

function install_workspace_scripts {
    for BASH_SCRIPT in $(ls ${BASH_SCRIPTS_SOURCE_ROOT});
    do
        SOURCE_SCRIPT=${BASH_SCRIPT}
        # Strip longest match of */ from start
        BASH_SCRIPT="${BASH_SCRIPT##*/}"
        # Strip shortest match of . plus at least one non-dot char from end
        BASH_SCRIPT="${BASH_SCRIPT%.[^.]*}"

        echo -e "${GREEN}[INSTALLING]${WHITE}\tCopying script: ${SOURCE_SCRIPT} to ${BASH_SCRIPTS_ROOT}${BASH_SCRIPT}${NC}"

        if [ -f "${BASH_SCRIPTS_ROOT}${BASH_SCRIPT}" ]
        then
            echo -e "${GREEN}[INSTALLING]${WHITE}\tExisting file '${BASH_SCRIPT}' already found in ${BASH_SCRIPTS_ROOT}${NC}"
            continue
        fi

        sudo ln -s ${SOURCE_SCRIPT} "${BASH_SCRIPTS_ROOT}${BASH_SCRIPT}"
        sudo chmod ${BASH_SCRIPTS_DEFAULT_PERMISSIONS} "${BASH_SCRIPTS_ROOT}${BASH_SCRIPT}"

        echo -e "${GREEN}[INSTALLING]${WHITE}\tCompleted adding ${BASH_SCRIPTS_ROOT}${BASH_SCRIPT} and permissions were set to ${BASH_SCRIPTS_DEFAULT_PERMISSIONS}${NC}"
    done
}
