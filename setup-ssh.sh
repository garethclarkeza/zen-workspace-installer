#!/usr/bin/env bash

echo -e "${GREEN}[INSTALLING]${WHITE}\tSetting up SSH key${NC}"
cd ~
# @todo allow for importing custom backup ssh files

mkdir ~/.ssh > /dev/null
chmod -R 700 ~/.ssh > /dev/null
ssh-keygen -t rsa -f ~/.ssh/id_rsa -q -P ""

# COPY OVER FREQUENTLY USED TRUSTED HOSTS
cat ${INSTALL_FOLDER}/known_hosts >> ~/.ssh/known_hosts

# THIS WILL FORCE A PASSWORD REQUEST FOR SUDO, AFTER THIS THE SUDOERS FILE CAN BE UPDATED SO PASSWORD IS NO LONGER REQUIRED WHEN USING SUDO
sudo apt-get -y install xclip > /dev/null

# CHECK TO SEE IF A NO PASSWORD RECORD EXISTS FOR THE CURRENT USER BEFORE ADDING IT
HAS_SUDOERS_NOPASSWD=false

sudo cat /etc/sudoers | while read line
do
    if [[ "${line}" =~ "ALL=(ALL) NOPASSWD: ALL" && "${line}" =~ "${USER}" ]]
    then
        HAS_SUDOERS_NOPASSWD=true
    fi
done

if [[ ${HAS_SUDOERS_NOPASSWD} ]]
then
    echo -e "${GREEN}[SKIPPING]${WHITE}\tA record for your user already exists in the sudoers files.${NC}"
else
    echo -e "${GREEN}[INSTALLING]${WHITE}\tAdding your user to sudoers file so you no longer have to type your password when you sudo :)${NC}"
    echo -e "${USER}\tALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers > /dev/null
fi

cat ~/.ssh/id_rsa.pub | xclipx -o

echo
echo "${GREEN}Your public key has been copied to your clipboard!${NC}"
echo "${YELLOW}In order to setup the system more easily, please add your ssh public key to github.com, bitbucket.org and gitlab:${NC}"
echo
echo "${YELLOW}'x--------------------------------------------------------------------------------------------------------------------------------------x'${WHITE}"
echo
echo '  Make sure you have loaded your private key into pageant and that it is running, copy the OpenSSH public key that you got when generating your '
echo '  key and paste it into the editor that opens.'
echo
echo "${YELLOW}'x--------------------------------------------------------------------------------------------------------------------------------------x'x${NC}"
echo
read -p  'Press any key to continue to edit the authorized hosts file.'
echo

# @todo copy public key over to any approved hosts (tbd)
vim ~/.ssh/authorized_keys

echo
echo "${GREEN}SSH has been successfully setup, here are you credentials to add to your Windows SSH client to connect to this server, you should start your VM in headless mode and only connect via your SSH client.${NC}"
echo "${YELLOW}"
echo 'x--------------------------------------------------------------------------------------------------------------------------------------x'
echo
echo -e "  IP Address:\t${WHITE}$(hostname  -I | cut -f1 -d' ')${YELLOW}"
echo -e "  Username:\t${WHITE}${USER}${YELLOW}"
echo -e "  Password:\t${WHITE}***** (use your putty private key that you previously used above or your password if you really want)${YELLOW}"
echo -e "  Port:\t\t${WHITE}22${YELLOW}"
echo
echo 'x--------------------------------------------------------------------------------------------------------------------------------------x'
echo "${NC}"
read -p  'Continue? '
echo

sudo systemctl restart ssh > /dev/null
