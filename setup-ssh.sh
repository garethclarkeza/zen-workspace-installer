#!/usr/bin/env bash

echo
echo 'Setting up SSH key'
cd ~
# @todo allow for importing custom backup ssh files
mkdir ~/.ssh
chmod 700 ~/.ssh
ssh-keygen -t rsa

# COPY OVER FREQUENTLY USED TRUSTED HOSTS
cat ${INSTALL_FOLDER}/known_hosts >> ~/.ssh/known_hosts

echo
echo "${RED}In order to setup the system more easily, please add your ssh public key to github.com, bitbucket.org and gitlab:${NC}"
echo
sudo apt-get -y install xclip
cat ~/.ssh/id_rsa.pub | xclip
echo "${WHITE}"
cat ~/.ssh/id_rsa.pub

echo
echo "${GREEN}Your public key has been copied to your clipboard!${NC}"
echo
echo 'Make sure you have loaded your private key into pageant and that it is running, copy the openssh public key that you got when generating your key and paste it into the editor that opens.'
echo
echo 'Press any key to continue to edit the authorized hosts file.'
echo
read -p  'continue: '

# @todo copy public key over to any approved hosts (tbd)
vim ~/.ssh/authorized_keys

echo
echo 'Adding your user to sudoers file so you no longer have to type your password when you sudo :)'
echo

echo -e "${USER}\tALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers > /dev/null

echo
echo 'SSH has been successfully setup, here are you credentials to add to your Windows SSH client to '
echo 'connect to this server, you should start your VM in headless mode and only connect via your SSH client.'
echo "${YELLOW}"
echo 'x-----------------------------------------------------------------------------------x'
echo -e "  IP Address:\t${WHITE}$(hostname  -I | cut -f1 -d' ')${YELLOW}"
echo -e "  Username:\t${WHITE}${USER}${YELLOW}"
echo -e "  Password:\t${WHITE}***** (use your putty private key that you previously used above or your password if you really want)${YELLOW}"
echo -e "  Port:\t\t${WHITE}22${YELLOW}"
echo 'x-----------------------------------------------------------------------------------x'
echo "${NC}"
