# Bootstrap your Windows Subsystem for Linux (WSL) system

WSL is a feature of Windows 10 introduced in the Anniversary Update in 2016 and improved since.
It allows you to install different Linux distros
to run under Windows without the need for a full virtual machine.

See https://en.wikipedia.org/wiki/Windows_Subsystem_for_Linux for more info.


## Installation of WSL

* Upgrade to Windows 1903 which adds support for accessing your WSL file system via file shares on `\\wsl$\`
* Enable WSL and install the Linux distro of your choice (Ubuntu 18.04 tested).
  See https://docs.microsoft.com/en-us/windows/wsl/install-win10 for more info.

From here on, continue the [bootstrapping](README.md) procedure as normal.


## WSL for Visual Studio Code (vscode)

`vscode` has extensions that allows you to run the editor in Windows and connect to your WSL installation:

* Download and install `vscode` for Windows
* Install [the "Remote Development" extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack)
* Install [the "Remote - WSL" extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl)

To start a WSL version of `vscode`, just type `code .` in your project folder from a bash terminal.
The terminal in the editor will be a bash-terminal instead of a powershell terminal.


## Random notes

If you are having permission issues, or can't set any permissions at all, you might need to run
`wsl sudo cp priv/wsl.conf /etc/wsl.conf` (or similar, mind the uid=1000 and gid=1000).
See https://gist.github.com/shakahl/8b6c969768b3a54506c0fc4905d729a0 .
