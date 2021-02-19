# Set User's Department in Active Directory
# Author: Tay Kratzer tay@cimitra.com
# Modify Date: 2/18/2021
# Change the context variable to match your system
# -------------------------------------------------

Param(
    [string] $FirstNameIn,
    [string] $LastNameIn,
    [string] $DepartmentNameIn,
    [string] $ContextIn,
    [switch] $ShowErrors
 )

$context = "OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com" 
 # - OR -
 # Specify the context in settings.cfg file
 # Use this format: AD_USER_CONTEXT=<ACTIVE DIRECTORY CONTEXT>
 # Example: AD_USER_CONTEXT=OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com
 # -------------------------------------------------

# Look to see if a config_reader.ps1 file exists in order to use it's functionality
# Obtain this script at this GitHub Location: 
# https://github.com/cimitrasoftware/powershell_scripts/blob/master/config_reader.ps1
if((Test-Path ${PSScriptRoot}\config_reader.ps1)){

# If a settings.cfg file exists, let's use that file to reading in variables
if((Test-Path ${PSScriptRoot}\settings.cfg))
{
# Give a short name to the config_reader.ps1 script
$CONFIG_IO="${PSScriptRoot}\config_reader.ps1"

# Source in the configuration reader script
. $CONFIG_IO

# Use the "ReadFromConfigFile" function in the configuration reader script
$CONFIG=(ReadFromConfigFile "${PSScriptRoot}\settings.cfg")

# Map the $context variable to the AD_USER_CONTEXT variable read in from the settings.cfg file
$context = "$CONFIG$AD_USER_CONTEXT"

if ($sleepTimeTest = "$CONFIG$AD_SCRIPT_SLEEP_TIME"){
$sleepTime = "$CONFIG$AD_SCRIPT_SLEEP_TIME"
}

}

}

$firstNameInSet = $false
$lastNameInSet = $false
$departmentNameInSet = $false
$verboseOutputSet = $false
$modifyUserResult = $true
$sleepTime = 5



$firstNameIn = $FirstNameIn

$firstNameIn = (Get-Culture).TextInfo.ToTitleCase($firstNameIn) 

$lastNameIn = $LastNameIn

$lastNameIn = (Get-Culture).TextInfo.ToTitleCase($lastNameIn) 

$departmentIn = $DepartmentNameIn 

if ($ShowErrors){
$verboseOutputSet = $true
}

if($firstNameIn.Length -gt 2){
$firstNameInSet = $true
}

if($lastNameIn.Length -gt 2){
$lastNameInSet = $true
}

if($departmentNameIn.Length -gt 2){
$departmentNameInSet = $true
}

$ContextInEmpty = [string]::IsNullOrWhiteSpace($ContextIn)

if($ContextInEmpty){
$contextIn = $context
}else{
$contextIn = $ContextIn
}

function CALL_SLEEP{
Write-Output ""
Write-Output "Pausing for $sleepTime Seconds"
Write-Output ""
Start-Sleep -s $sleepTime
}


# Show Help
function ShowHelp{
$scriptName = Split-Path -leaf $PSCommandpath
Write-Host ""
Write-Host "Set a User's Department in Active Directory"
Write-Host ""
Write-Host "[ HELP ]"
Write-Host ""
Write-Host ".\$scriptName -h or -help"
Write-Host ""
Write-Host "[ SCRIPT USAGE ]"
Write-Host ""
Write-Host ".\$scriptName -FirstNameIn <user first name> -FastNameIn <user last name> -DepartmentNameIn <department> -contextIn <Active Directory context (optional if specified in settings.cfg)>"
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host ".\$scriptName -FirstNameIn <user first name> -LastNameIn <user last name> -DepartmentNameIn <department> "
Write-Host ""
Write-Host "[ EXAMPLES ]"
Write-Host ""
Write-Host "Example: .\$scriptName -FirstNameIn Jane -LastNameIn Doe -DepartmentNameIn Development"
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host "Example: .\$scriptName -FirstNameIn Jane -LastNameIn Doe -DepartmentNameIn Development -ContextIn OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com"
Write-Host ""
Write-Host "[ ERROR HANDLING ]"
Write-Host ""
Write-Host "-ShowErrors = Show Error Messages"
Write-Host ""
Write-Host "Example: .\$scriptName -ShowErrors -FirstNameIn Jane -LastNameIn Doe -DepartmentNameIn Development"
Write-Host ""
exit 0
}

if (Write-Output $args | Select-String "\-h\b|\-help\b" )
{
ShowHelp
}


# This script expects 3 arguments, so if the 3rd argument is blank, then show the Help and exit
if (!( $firstNameInSet -and $lastNameInSet -and $departmentNameInSet )){ 
ShowHelp
 }
# -------------------------------------------------


if($contextIn.Length -lt 3){
ShowHelp
}


# Modify the user
try{
Set-ADUser -Identity "CN=${firstNameIn} ${lastNameIn},$contextIn" -Department "$departmentIn"
}catch{
$modifyUserResult = $false
$err = "$_"
}


# If exit code from the Set-ADUser command was "True" then show a success message
if ($modifyUserResult)
{
Write-Output ""
Write-Output "User: ${firstNameIn} ${lastNameIn} | Department changed to: ${departmentIn} "
Write-Output ""
}else{
Write-Output ""
Write-Output "User: ${firstNameIn} ${lastNameIn} | Department NOT changed in Active Directory"
Write-Output ""
    if ($verboseOutputSet){
    Write-Output "[ERROR MESSAGE BELOW]"
    Write-Output "-----------------------------"
    Write-Output ""
    Write-Output $err
    Write-Output ""
    Write-Output "-----------------------------"
    }
exit 1
}

