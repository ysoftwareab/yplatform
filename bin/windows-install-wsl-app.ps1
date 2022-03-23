#!/usr/bin/env pwsh

# https://docs.microsoft.com/en-us/windows/wsl/install-manual
# https://github.com/electronicegg/wsl-ubuntu-powershell
# https://github.com/grmlin/node-wsl

# NOTE: run the following on Windows10 before calling this script
# Set-ExecutionPolicy RemoteSigned
# or Unblock-File windows-install-wsl.ps1

$DistroIdArg = args[0]

$Distros = @(
    @{
        id="Ubuntu-20.04",
        url="https://aka.ms/wslubuntu2004",
        installer="ubuntu2004.exe"
    },

    @{
        id="Ubuntu-18.04",
        url="https://aka.ms/wsl-ubuntu-1804",
        installer="ubuntu1804.exe"
    },

    @{
        id="Debian",
        url="https://aka.ms/wsl-debian-gnulinux",
        installer="debian.exe"
    },

    @{
        id="kali-linux",
        url="https://aka.ms/wsl-kali-linux-new",
        installer="kali.exe"
    },

    @{
        id="openSUSE-Leap-42",
        url="https://aka.ms/wsl-opensuse-42",
        installer="opensuse-42.exe"
    }
)

$Distro = $Distros | Where-Object { id = $DistroIdArg }

Invoke-WebRequest -OutFile ($Distro.id).appx -UseBasicParsing -Uri ($Distro.url)
Add-AppxPackage ./($Distro.id).appx

($Distro.installer) install --root
