write-output ""
$CIMITRA_DOWNLOAD = "https://github.com/cimitrasoftware/activedirectory/archive/master.zip"
$INSTALLATION_DIRECTORY = "C:\cimitra\scripts\ad"
$CIMITRA_DOWNLOAD_OUT_FILE = "cimitra_ad.zip"

$global:runSetup = $true

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
write-output "START: Cimitra Active Directory Integration Setup Script"
write-output "--------------------------------------------------------"
Write-Output ""
.("$INSTALLATION_DIRECTORY\setup.ps1")
}