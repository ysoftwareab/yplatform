# WSL - Windows subsystem for linux

WSL is a feature of Windows 10 introduced in the Anniversary Update in 2016 and improved since. It allows you to install 
different linux distros to run under windows without the need for a full virtual machine. 

https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux


## Installation of WSL

* Upgrade to windows 1903 (adds support for accessing your WSL file system via file shares on \\wsl$\
* Enable WSL and install the linux distro of your choice (Ubuntu 18.04 tested). https://docs.microsoft.com/en-us/windows/wsl/install-win10
* Install npm: sudo apt-get install npm
* Update npm: sudo npm -g install npm
* Install Angular: sudo npm install -g @angular/cli
* Prereqs for nvm: apt-get install build-essential libssl-dev
* Install nvm (node version manager): https://github.com/nvm-sh/nvm
* Install a suitable version of node: nvm install 12

## Installation of VS code
VS code has extensions that allows you to run the editor in windows and connect to your WSL installation:

* Download and install VS code for windows
* Install VSCode extension "remote development": https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack
* Install VSCode extension "Remote WSL": https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl

To start a WSL version of VS code, just type "code ." in your project folder from a bash terminal. The terminal in the editor will be a bash-terminal instead of a powershell terminal.

## Bootstrapping

Now it is time to get the firecloud stuff installed inside WSL: [bootstrap](bootstrap.md)

## Conclusion

From here things should work as you expect them. If you run "ng serve" from your bash 
terminal in WSL, it will start a development server that can be accessed from Chrome 
running on your windows machine http://localhost:4200

Good luck!
