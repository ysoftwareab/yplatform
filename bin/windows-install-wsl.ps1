#!/usr/bin/env pwsh

# https://docs.microsoft.com/en-us/windows/wsl/install-manual
# https://github.com/electronicegg/wsl-ubuntu-powershell
# https://github.com/grmlin/node-wsl

# NOTE: run the following on Windows10 before calling this script
# Set-ExecutionPolicy RemoteSigned
# or Unblock-File windows-install-wsl.ps1

# Update to WSL 2
# To update to WSL 2, you must meet the following criteria:
# * Running Windows 10, updated to version 1903 or higher, Build 18362 or higher for x64 systems.
# * Running Windows 10, updated to version 2004 or higher, build 19041, for ARM64 systems.
# * Please note if you are on Windows 10 version 1903 or 1909 you will need to ensure that you have the proper backport, instructions can be found here.
# * Check your Windows version by selecting the Windows logo key + R, type winver, select OK. (Or enter the ver command in Windows Command Prompt). Please update to the latest Windows version if your build is lower than 18361. Get Windows Update Assistant.

#Requires -RunAsAdministrator

$TempDir = [System.IO.Path]::GetTempPath()
cd $TempDir

if((Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux).State -eq "Disabled"){
    Write-Output "[DO  ] Enabling Microsoft-Windows-Subsystem-Linux..."
    Enable-WindowsOptionalFeature -Online -All -FeatureName Microsoft-Windows-Subsystem-Linux
    Write-Output "[DONE]"
}
Write-Output "[INFO] Microsoft-Windows-Subsystem-Linux is enabled."

if((Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform).State -eq "Disabled"){
    Write-Output "[DO  ] Enabling VirtualMachinePlatform required by WSL v2..."
    Enable-WindowsOptionalFeature -Online -All -FeatureName VirtualMachinePlatform
    Write-Output "[DONE]"
}
Write-Output "[INFO] VirtualMachinePlatform is enabled."

wsl --set-default-version 2 || {
    Write-Output "[WARN] Failed to set WSL to default to v2. Trying to fix."

    $WslUpdateUrl = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
    Write-Output "[DO  ] Downloading WSL update from $WslUpdateUrl..."
    Invoke-WebRequest -OutFile wsl_update_x64.msi -UseBasicParsing -Uri $WslUpdateUrl
    Write-Output "[DONE]"

    Write-Output "[DO  ] Installing WSL v2 update..."
    msiexec.exe /i wsl_update_x64.msi /QN /L*V wsl_update_x64.install.1.log REBOOT=R
    Write-Output "[DONE]"

    wsl --set-default-version 2 || {
        Write-Output "[WARN] Failed to set WSL to default to v2. Trying to fix."

        # see https://github.com/microsoft/WSL/issues/5651
        Write-Output "[DO  ] Uninstalling WSL v2 update..."
        msiexec.exe /x wsl_update_x64.msi /QN /L*V wsl_update_x64.uninstall.log REBOOT=R
        Write-Output "[DONE]"

        Write-Output "[DO  ] Installing WSL v2 update..."
        msiexec.exe /i wsl_update_x64.msi /QN /L*V wsl_update_x64.install.2.log REBOOT=R
        Write-Output "[DONE]"

        wsl --set-default-version 2 || {
            Write-Output "[ERR] Failed to set WSL to default to v2."
            exit 1
        }
    }
}
Write-Output "[INFO] Set WSL to default to v2."
