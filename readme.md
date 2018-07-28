## Setting up the Zen Workspace system on a Windows 10 host

Zen Workspace is an attempt to make developing on Windows as painless as possible. You setup a VirtualBox VM via the guide below and then use an install script to setup your linux image (Ubuntu Server 18.04 currently).

The install script will setup your complete workspace environment. Your base workspace folder must be an empty folder somewhere on your host Windows machine, e.g. ```C:\workspace``` or ```C:\Users\<YourName>\workspace``` - although the folder doesn't need to be called workspace just recommended.

### Requirements

To get going with setting up your own Zen Workspace, please carry on reading on what you need to do before you get going.

1. If you have Docker installed, completely remove it.
1. If you have Hyper-V enabled, this will need to be disabled. (@TODO add guide)
1. Make sure you have VirtualBox installed.
1. Download this image. (@todo add link to ubuntu-server-mini)
1. While technically not required, to save you have to use passwords to access the linux server, you should create a SSH key/pair. (@TODO add guide)
1. Have a github.com account. (you will need to add an ssh key to your github account)
1. If you have not already - install PuTTY, PuTTYgen and Pageant. (for an SSH client, I recommend using WinSSHterm - but you can use whatever you prefer)
1. Make sure you have your favourite code editor installed and for way less hair pulling down the line, make sure you code editors save line endings in UNIX/MAC format which is ```\n``` and not the Windows ```\r\n```.
1. You will also need git installed (preferably command line version).
1. [OPTIONAL] This may be a little insecure, however, for easy and more automated management of your Windows hosts file, I suggest giving modify access to your ```C:\Windows\System32\drivers\etc\hosts``` which you will later share onto your linux server.

The following tools are not required on Windows, but may make your development experience more enjoyable as you can run these from windows just as you would from linux.

 - php (the same version you use on your ubuntu server)
 - composer
 - node/npm/yarn

### Installation
Once you have met the above requirements, please do a fresh restart and then continue below.

#### Virtual Box
The first thing you will need to do is setup a VirtualBox VM. In the VirtualBox Manager, make sure no other VM's are running.

#### Setting up a new VM
 - Create a new VM
 - Click "expert mode"
 - Name it something based on use and os eg. WORKSPACE-UBUNTU18-SERVER
 - Type: Linux
 - Version: Ubuntu (64-bit)
 - Memory Size: > 1024MB (I would suggest giving the server between 2048 - 4096MB depending on what you can spare from your system)\
 - Hard disk: Create a virtual disk now
 - Click Create

#### Create Virtual Hard Disk
 - File location: use the default or select your own location (whichever drive this is on is where the space required for the VM is going to come from, although I suggest this space be on a SSD drive for better performance)
 - File size: > 10GB (from personal experience 10GB is the absolute minimum that should be attempted, if you have the space I would suggest a minimum of around 20-40GB)
 - Hard disk file type: VDI
 - Storage on physical location: either fixed size or dynamically allocated that only allocates the space to the VM when it is required (although it does not get smaller by itself)
