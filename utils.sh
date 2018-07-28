#!/usr/bin/env bash

# MAKE SURE YOU NEED RELOADING THIS FILE
if [[ ${WORKSPACE_UTILS_LOADED} = true ]]
then
    return
fi

# Make the ENV variables for this app available
while read var; do
  export "${var}"
done <.env

# GLOBAL INSTALLATION VARIABLES
export WORKSPACE_UTILS_LOADED=true
export HOST_IP_ADDRESS=${SSH_CLIENT%% *}
export LOCAL_IP_ADDRESS=$(hostname  -I | cut -f1 -d' ')

#COLOURS
export RED=`tput setaf 1`
export GREEN=`tput setaf 2`
export YELLOW=`tput setaf 3`
export BLUE=`tput setaf 4`
export PURPLE=`tput setaf 5`
export CYAN=`tput setaf 6`
export WHITE=`tput setaf 7`
export BLACK=`tput setaf 8`
export NC=`tput sgr0` # reset colour

# FUNCTIONS
function install_workspace_scripts {
    for BASH_SCRIPT in $(ls ${BASH_SCRIPTS_SOURCE_ROOT});
    do
        SOURCE_SCRIPT=${BASH_SCRIPT}
        BASH_SCRIPT="${BASH_SCRIPT##*/}"      # Strip longest match of */ from start
        BASH_SCRIPT="${BASH_SCRIPT%.[^.]*}"   # Strip shortest match of . plus at least one non-dot char from end

        echo -e "Copying script: ${SOURCE_SCRIPT} to ${BASH_SCRIPTS_ROOT}${BASH_SCRIPT}"
        echo

        if [ -f "${BASH_SCRIPTS_ROOT}${BASH_SCRIPT}" ]
        then
            echo -e "Existing file '${BASH_SCRIPT}' already found in ${BASH_SCRIPTS_ROOT}"
            echo
            continue
        fi

        sudo cp ${SOURCE_SCRIPT} "${BASH_SCRIPTS_ROOT}${BASH_SCRIPT}"
        sudo chmod ${BASH_SCRIPTS_DEFAULT_PERMISSIONS} "${BASH_SCRIPTS_ROOT}${BASH_SCRIPT}"

        echo -e "Completed adding ${BASH_SCRIPTS_ROOT}${BASH_SCRIPT} and permissions were set to ${BASH_SCRIPTS_DEFAULT_PERMISSIONS}"
        echo
    done
}
