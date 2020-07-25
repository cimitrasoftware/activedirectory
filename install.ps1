# Cimitra Active Directory Integration Installation Script
# Author: Tay Kratzer tay@cimitra.com

$CIMITRA_DOWNLOAD = 'https://github.com/cimitrasoftware/activedirectory/archive/master.zip'
$INSTALLATION_DIRECTORY = 'C:\cimitra\scripts\ad'
$CIMITRA_DOWNLOAD_OUT_FILE = 'cimitra_ad.zip'

$SCRIPT_TITLE = 'Cimitra Active Directory Integration Module'

write-output ""
write-output "START: INSTALLING - Cimitra Active Directory Integration Module"
write-output "---------------------------------------------------------------"
Write-Output ""

if ($args[0]) { 
$INSTALLATION_DIRECTORY = $args[0]
}

$EXTRACTED_DIRECTORY = "$INSTALLATION_DIRECTORY\activedirectory-master"

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

Write-Output ""
Write-Host "Configuring Windows to Allow PowerShell Scripts to Run" -ForegroundColor blue -BackgroundColor white
Write-Output ""
Write-Output ""
Write-Host "NOTE: Use 'A' For 'Yes to All'" -ForegroundColor blue -BackgroundColor white
Write-Output ""
Unblock-File *
Set-ExecutionPolicy Unrestricted 2>&1 | out-null
Set-ExecutionPolicy Bypass 2>&1 | out-null
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process 2>&1 | out-null
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser 2>&1 | out-null
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine 2>&1 | out-null



# If a settings.cfg file does not exist initialize one

if (!(Test-Path -Path $INSTALLATION_DIRECTORY\settings.cfg -PathType leaf)){


if((Test-Path $INSTALLATION_DIRECTORY\config_reader.ps1)){

$CONFIG_IO="$INSTALLATION_DIRECTORY\config_reader.ps1"

. $CONFIG_IO

WriteToConfigFile "$INSTALLATION_DIRECTORY\settings.cfg" "AD_COMPUTER_CONTEXT" "OU=COMPUTERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com"
WriteToConfigFile "$INSTALLATION_DIRECTORY\settings.cfg" "AD_USER_CONTEXT" "OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com"
WriteToConfigFile "$INSTALLATION_DIRECTORY\settings.cfg" "AD_SCRIPT_SLEEP_TIME" "5"

}

}

Write-Output ""
Write-Host "Make sure to run the Setup Script 'setup.ps1' " -ForegroundColor blue -BackgroundColor white
Write-Output ""

write-output ""
write-output "----------------------------------------------------------------"
write-output "FINISH: INSTALLING - Cimitra Active Directory Integration Module"
Write-Output ""

.("$INSTALLATION_DIRECTORY\setup.ps1")