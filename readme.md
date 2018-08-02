## Setting up the Zen Workspace system on a Windows 10 host

Zen Workspace (geared towards php and node stacks) is an attempt to make developing on Windows as painless as possible. You setup a VirtualBox VM via the guide below and then use an install script to setup your linux image (Ubuntu Server 18.04 currently).

The install script will setup your complete workspace environment. Your base workspace folder must be an empty folder somewhere on your host Windows machine, e.g. ```C:\workspace``` or ```C:\Users\<YourName>\workspace``` - although the folder doesn't need to be called workspace just recommended.

The other main component of the Zen Workspace is the use of Docker and Docker Compose managed via Laradock. You can run multiple projects at the same time via virtual hosts configuration, as well as easily switching in and out services and new versions.

### Requirements

To get going with setting up your own Zen Workspace, please carry on reading on what you need to do before you get going.

1. If you have Docker installed, completely remove it.
1. If you have Hyper-V enabled, this will need to be disabled.
    1. Hit the Windows Key and type “windows features”
    1. Hit the Windows Key + W combo to bring up the Windows Settings panel of the Start Screen.
    1. Click on Turn Windows features on or off.
    1. When the Turn Windows features on or off dialog appears, look for Hyper-V and deselect it.
    1. Click OK.
    1. Restart your computer when prompted.
1. Make sure you have VirtualBox installed.
1. Download this image: http://archive.ubuntu.com/ubuntu/dists/bionic-updates/main/installer-amd64/current/images/netboot/mini.iso
1. While technically not required, to save you have to use passwords to access the linux server, you should create a SSH key/pair. (@TODO add guide)
1. Have a github.com account. (you will need to add an ssh key to your github account)
1. If you have not already - install PuTTY, PuTTYgen and Pageant. (for an SSH client, I recommend using WinSSHterm - but you can use whatever you prefer)
1. Make sure you have your favourite code editor installed and for way less hair pulling down the line, make sure you code editors save line endings in UNIX/MAC format which is ```\n``` and not the Windows ```\r\n```.
1. You will also need git installed.
1. Make sure you have created your workspace folder in the location you want it, like C:\workspace, D:\web, ~\www etc (remember that this folder is where your IDE will point to and should be in an easy to access safe location).
1. [OPTIONAL] This may be a little insecure, however, for easy and more automated management of your Windows hosts file, I suggest giving modify access to your ```C:\Windows\System32\drivers\etc\hosts``` which you will later share onto your linux server.

The following tools are not required on Windows, but may make your development experience more enjoyable as you can run these from windows just as you would from linux.

 - php (the same version you use on your ubuntu server)
 - composer
 - node/npm/yarn

### Installation
Once you have met the above requirements, please do a fresh restart and then continue below.

#### Virtual Box
The first thing you will need to do is setup a VirtualBox VM. In the VirtualBox Manager, make sure no other VM's are running.

##### Setting up a new VM
 - Create a new VM
 - Click "expert mode"
 - Name it something based on use and os eg. WORKSPACE-UBUNTU18-SERVER
 - Type: Linux
 - Version: Ubuntu (64-bit)
 - Memory Size: > 1024MB (I would suggest giving the server between 2048 - 4096MB depending on what you can spare from your system)\
 - Hard disk: Create a virtual disk now
 - Click Create

##### Create Virtual Hard Disk
 - File location: use the default or select your own location (whichever drive this is on is where the space required for the VM is going to come from, although I suggest this space be on a SSD drive for better performance)
 - File size: > 25GB (from personal experience 25GB is the absolute minimum that should be attempted - especially when dealing with large databases, if you have the space I would suggest a minimum of around >60GB)
 - Hard disk file type: VDI
 - Storage on physical location: either fixed size or dynamically allocated that only allocates the space to the VM when it is required (although it does not get smaller by itself)

#### Server, Zen Workspace and Docker
 - Login to your linux server VM
 - Zen Workspace is installed via an install script, to get start, on your Linux Server, go to your home folder ```cd ~``` and then ```git clone git@github.com:garethclarkeza/zen-workspace-installer.git```
 - ```cd ~/zen-workspace-installer```
 - ```chmod 775 ./install.sh```
 - ```./install.sh```
 - Follow the prompts, the process will stop when you need to shutdown the VM to add the shared folders that link your Windows workspace with your Linux workspace.
 - Add the following 2 share to your VirtualBox VM settings.
    1 ```C:\<workspace> -> workspace``` (auto-mount, make permanent)
    1 ```C:\Windows\System32\drivers\etc -> win_hosts``` (auto-mount, make permanent)
 - Once this is complete, restart the server in headless mode as you will now only ever access the server via an SSH client, like PuTTY or WinSSHclient.
 - When the server has rebooted, login again via ssh client go back into the installer folder ```cd zen-workspace-installer```
 - ```./install.sh```
 - This will then allow the process to continue where you left off on your installation.
 - Follow the output and prompts
 - Well done! :P Your Linux Server with docker support and development environment server is now running

### What Now?
Coming soon, readme will soon be updated in the zen-workspace readme file.


