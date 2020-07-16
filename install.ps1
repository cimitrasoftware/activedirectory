#!/usr/bin/env pwsh
# Cimitra Active Directory Integration Installation Script
# Author: Tay Kratzer tay@cimitra.com

$CIMITRA_DOWNLOAD = 'https://github.com/cimitrasoftware/activedirectory/archive/master.zip'
$INSTALLATION_DIRECTORY = 'C:\cimitra\scripts\ad'
$CIMITRA_DOWNLOAD_OUT_FILE = 'cimitra_ad.zip'
$EXTRACTED_DIRECTORY = 'C:\cimitra\scripts\ad\activedirectory-master'
$SCRIPT_TITLE = 'Cimitra Active Directory Integration Module'

Write-Output ""
Write-Output "Begin Installing $SCRIPT_TITLE"
Write-Output ""

if ($args[0]) { 
$INSTALLATION_DIRECTORY = $args[0]
}

New-Item -ItemType Directory -Force -Path $INSTALLATION_DIRECTORY

$theResult = $?

if (!$theResult){
Write-Output "Error: Could Not Create Installation Directory: $INSTALLATION_DIRECTORY"
exit 1
}

Write-Output ""
Write-Output "The PowerShell Scripts Will Be Installed To: $INSTALLATION_DIRECTORY"
Write-Output ""

Write-Output ""
Write-Output "Downloading File: $CIMITRA_DOWNLOAD"
Write-Output ""

Invoke-WebRequest $CIMITRA_DOWNLOAD -OutFile $CIMITRA_DOWNLOAD_OUT_FILE -UseBasicParsing

$theResult = $?

if (!$theResult){
Write-Output "Error: Could Not Download The File: $CIMITRA_DOWNLOAD"
exit 1
}

Write-Output ""
Write-Output "Extracting File: $CIMITRA_DOWNLOAD"
Write-Output ""

Expand-Archive .\$CIMITRA_DOWNLOAD_OUT_FILE -Destination $INSTALLATION_DIRECTORY -Force

$theResult = $?

if (!$theResult){
Write-Output "Error: Could Not Extract File: $CIMITRA_DOWNLOAD_OUT_FILE"
exit 1
}

Remove-Item -Path .\$CIMITRA_DOWNLOAD_OUT_FILE

Move-Item -Path $EXTRACTED_DIRECTORY\*.ps1  -Destination $INSTALLATION_DIRECTORY -Force

Remove-Item -Path $EXTRACTED_DIRECTORY -Force

Set-Location -Path $INSTALLATION_DIRECTORY

# Grant PowerShell rights to run the scripts located in the installation directory
Unblock-File *


# If a settings.cfg file does not exist initialize one

if (!(Test-Path -Path $INSTALLATION_DIRECTORY\settings.cfg -PathType leaf)){


if((Test-Path $INSTALLATION_DIRECTORY\config_reader.ps1)){

$CONFIG_IO="$INSTALLATION_DIRECTORY\config_reader.ps1"

. $CONFIG_IO

WriteToConfigFile "$INSTALLATION_DIRECTORY\settings.cfg" "AD_COMPUTER_CONTEXT" "OU=COMPUTERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com"
WriteToConfigFile "$INSTALLATION_DIRECTORY\settings.cfg" "AD_USER_CONTEXT" "OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com"

}

}

Write-Output ""
Write-Output "Make sure to configure: $INSTALLATION_DIRECTORY\settings.cfg"
Write-Output ""

Write-Output ""
Write-Output "Finished Installing $SCRIPT_TITLE"
Write-Output ""

