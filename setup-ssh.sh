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
echo "Copy the following to the bottom of the file that is about to open: "
echo
echo "${USER} ALL=(ALL) NOPASSWD: ALL"
echo
echo 'Hit any key to continue after copying the above line'
echo
read -p 'continue: '

#sudo echo "${USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# @todo do this automatically
sudo visudo

echo
echo 'SSH has been successfully setup, please exit and login with the following credentials:'
echo
echo 'x-----------------------------------------------------------------------------------x'
echo -e "  IP Address:\t$(hostname  -I | cut -f1 -d' ')"
echo -e "  Username:\t${USER}"
echo -e '  Password:\t***** (use your putty private key that you previously used above or your password if you really want)'
echo -e '  Port:\t\t22'
echo 'x-----------------------------------------------------------------------------------x'
echo

