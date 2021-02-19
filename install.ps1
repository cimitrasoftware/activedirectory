# IGNORE THIS ERROR! IGNORE THIS ERROR! JUST A POWERSHELL THING THAT HAPPENS ON THE FIRST LINE OF A POWERSHELL SCRIPT 

# Cimitra Active Directory Integration Module Install Script
# Author: Tay Kratzer tay@cimitra.com

$CIMITRA_DOWNLOAD = "https://github.com/cimitrasoftware/activedirectory/archive/master.zip"
$global:INSTALLATION_DIRECTORY = "C:\cimitra\scripts\ad"
$CIMITRA_DOWNLOAD_OUT_FILE = "cimitra_ad.zip"

$global:runSetup = $true


function CHECK_ADMIN_LEVEL{

if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
[Security.Principal.WindowsBuiltInRole] "Administrator")) {
Write-Output ""
Write-Warning "Insufficient permissions to run this script. Open the PowerShell console as an administrator and run this script again."
Write-Output ""
exit 1
}

}

CHECK_ADMIN_LEVEL


function CONFIRM_AGENT_SERVICE_REGISTRY{

# Get Agent CONFIG File Path - Using string extraction

$IMAGE_PATH=New-TemporaryFile

$IMAGE_PATH = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\Cimitra' -Name ImagePath).ImagePath;

$AGENT_CONFIG_ONE = $IMAGE_PATH | Select-String -Pattern '(?ms)-tsspconfig "(.*?)"' -AllMatches | foreach { $_.Matches | foreach {$_.Groups[0].Value}}

$AGENT_CONFIG_TWO = $AGENT_CONFIG_ONE | Select-String -Pattern '(?ms)"(.*?)"' -AllMatches | foreach { $_.Matches | foreach {$_.Groups[0].Value}}

$CIMITRA_AGENT_CONFIG_FILE = $AGENT_CONFIG_TWO -replace '"', ""

$global:CIMITRA_AGENT_CONFIG_FILE_PATH = ${CIMITRA_AGENT_CONFIG_FILE}

# Get Agent EXE File Path - Using string extraction

$IMAGE_PATH = (Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\Cimitra' -Name ImagePath).ImagePath;

$AGENT_EXE_AND_DISPLAYNAME = $IMAGE_PATH | Select-String -Pattern '(?ms)"(.*?)-displayname' -AllMatches | foreach { $_.Matches | foreach {$_.Groups[0].Value}}

$AGENT_EXE_AND_PATH = $AGENT_EXE_AND_DISPLAYNAME | Select-String -Pattern '(?ms)"(.*?)"' -AllMatches | foreach { $_.Matches | foreach {$_.Groups[0].Value}}

$AGENT_EXE = $AGENT_EXE_AND_PATH -replace '"', ""

$global:CIMITRA_AGENT_EXE_FILE_PATH = $AGENT_EXE

$global:CIMITRA_EXE_BASE_PATH = Split-Path -Path $CIMITRA_AGENT_EXE_FILE_PATH

$global:INSTALLATION_DIRECTORY = "${CIMITRA_EXE_BASE_PATH}\scripts\ad"

}

CONFIRM_AGENT_SERVICE_REGISTRY



write-output ""
write-output "START: INSTALLING - Cimitra Active Directory Integration Module"
write-output "---------------------------------------------------------------"
Write-Output ""

if ($args[0]) { 
$INSTALLATION_DIRECTORY = $args[0]
}

if (Write-Output $args | Select-String "\-skipSetup" )
{
$global:runSetup = $false
}

$EXTRACTED_DIRECTORY = "$INSTALLATION_DIRECTORY\activedirectory-master"

try{
New-Item -ItemType Directory -Force -Path $INSTALLATION_DIRECTORY
}catch{}


$theResult = $?

if (!$theResult){
Write-Output "Error: Could Not Create Installation Directory: $INSTALLATION_DIRECTORY"
exit 1
}

Write-Output ""
Write-Output "The PowerShell Scripts Will Be Installed To: $INSTALLATION_DIRECTORY"
Write-Output ""

Write-Output ""
write-output ""
write-output "START: Downloading Cimitra Active Directory Integration"
write-output "-----------------------------------------------------------------------"
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

try{
Remove-Item -Path .\$CIMITRA_DOWNLOAD_OUT_FILE -Force -Recurse 2>&1 | out-null
}catch{}

try{
Move-Item -Path  $EXTRACTED_DIRECTORY\*.ps1  -Destination $INSTALLATION_DIRECTORY -Force 2>&1 | out-null
}catch{}

try{
Remove-Item -Path $EXTRACTED_DIRECTORY -Force -Recurse 2>&1 | out-null
}catch{}

try{
Set-Location -Path $INSTALLATION_DIRECTORY
}catch{
Write-Output ""
Write-Output "Error: Cannot access directory: $INSTALLATION_DIRECTORY"
Write-Output ""
exit 1
}

Write-Output ""
Write-Host "Configuring Windows to Allow PowerShell Scripts to Run" -ForegroundColor blue -BackgroundColor white
Write-Output ""
Write-Output ""
Write-Host "NOTE: Use 'A' For 'Yes to All'" -ForegroundColor blue -BackgroundColor white
Write-Output ""
Unblock-File * 

try{
powershell.exe -NonInteractive -Command Set-ExecutionPolicy Unrestricted 2>&1 | out-null
}catch{
Set-ExecutionPolicy Unrestricted 
}

try{
powershell.exe -NonInteractive -Command Set-ExecutionPolicy Bypass 2>&1 | out-null
}catch{
Set-ExecutionPolicy Bypass
}

try{
powershell.exe -NonInteractive -Command Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process 2>&1 | out-null
}catch{
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process
}

try{
powershell.exe -NonInteractive -Command Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser 2>&1 | out-null
}catch{
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser}

try{
powershell.exe -NonInteractive -Command Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine 2>&1 | out-null
}catch{
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine
}



if (!(Test-Path -Path $INSTALLATION_DIRECTORY\settings.cfg -PathType leaf)){


if((Test-Path $INSTALLATION_DIRECTORY\config_reader.ps1)){

$CONFIG_IO="$INSTALLATION_DIRECTORY\config_reader.ps1"

try{
. $CONFIG_IO
}catch{}

confirmConfigSetting "$INSTALLATION_DIRECTORY\settings.cfg" "AD_COMPUTER_CONTEXT" "OU=COMPUTERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com"
confirmConfigSetting "$INSTALLATION_DIRECTORY\settings.cfg" "AD_USER_CONTEXT" "OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com"
confirmConfigSetting "$INSTALLATION_DIRECTORY\settings.cfg" "AD_SCRIPT_SLEEP_TIME" "5"

}

}

if(!(get-module -list activedirectory))
{
write-output ""
write-output "START: INSTALLING - Microsoft Remote Server Administration Tools (RSAT)"
write-output "-----------------------------------------------------------------------"
Write-Output ""

Add-WindowsCapability –online –Name “Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0”

write-output ""
write-output "FINISH: INSTALLING - Microsoft Remote Server Administration Tools (RSAT)"
write-output "------------------------------------------------------------------------"
Write-Output ""

}

Write-Output ""
Write-Host "Make sure to run the Setup Script 'setup.ps1' " -ForegroundColor blue -BackgroundColor white
Write-Output ""

write-output ""
write-output "----------------------------------------------------------------"
write-output "FINISH: INSTALLING - Cimitra Active Directory Integration Module"
Write-Output ""


if($runSetup)
{write-output ""
write-output "START: RUNNING - Cimitra Active Directory Integration Setup Script"
write-output "------------------------------------------------------------------"
Write-Output ""
.("$INSTALLATION_DIRECTORY\setup.ps1")
}