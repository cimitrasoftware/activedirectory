# Remove a user from Active Directory and Prompt For Y/N
# Author: Tay Kratzer tay@cimitra.com
# Change the context variable to match your system
# Modify Date: 2/18/2021
# -------------------------------------------------
Param(
    [string] $ContextIn,
    [string] $FirstNameIn,
    [string] $LastNameIn,
    [string] $ConfirmWordValue,
    [string] $ConfirmWordIn,
    [switch] $ShowErrors
 )
# -------------------------------------------------
$context = "OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com" 
 # - OR -
 # Specify the context in settings.cfg file
 # Use this format: AD_USER_CONTEXT=<ACTIVE DIRECTORY CONTEXT>
 # Example: AD_USER_CONTEXT=OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com
 # -------------------------------------------------

# Look to see if a config_reader.ps1 file exists in order to use it's functionality
# Obtain this script at this GitHub Location: 
# https://github.com/cimitrasoftware/powershell_scripts/blob/master/config_reader.ps1
# If a settings.cfg file exists read it and get the Active Directory Context from this file
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
if ($contextTest = "$CONFIG$AD_USER_CONTEXT"){
$context = "$CONFIG$AD_USER_CONTEXT"
}

}

}

$FirstNameInSet = $false
$LastNameInSet = $false
$ConfirmWordInSet = $false
$verboseOutputSet = $false
$deleteUserResult = $true
$sleepTime = 5

$firstNameIn = $FirstNameIn

$firstNameIn = (Get-Culture).TextInfo.ToTitleCase($firstNameIn) 

$lastNameIn = $LastNameIn

$lastNameIn = (Get-Culture).TextInfo.ToTitleCase($lastNameIn) 

$confirmWordIn = $ConfirmWordIn


if ($ShowErrors){
$verboseOutputSet = $true
}

if($FirstNameIn.Length -gt 2){
$firstNameInSet = $true
}

if($LastNameIn.Length -gt 2){
$lastNameInSet = $true
}

if($ConfirmWordIn.Length -gt 2){
$confirmWordInSet = $true
}

if(!($ConfirmWordValue.Length -gt 0)){
$ConfirmWordValue = 'YES'
}

$ContextInEmpty = [string]::IsNullOrWhiteSpace($ContextIn)

if($ContextInEmpty){
$contextIn = $context
}else{
$contextIn = $ContextIn
}

if(!($ConfirmWordIn -eq $ConfirmWordValue)){

Write-Output ""
Write-Output "Cannot Proceed, Incorrect Confirmation Input"
Write-Output ""
exit 0
}


# Show Help
function ShowHelp{
$scriptName = Split-Path -leaf $PSCommandpath
Write-Host ""
Write-Host "Remove a User From Active Directory and Confirm"
Write-Host ""
Write-Host "[ HELP ]"
Write-Host ""
Write-Host ".\$scriptName -h or -help"
Write-Host ""
Write-Host "[ SCRIPT USAGE ]"
Write-Host ""
Write-Host ".\$scriptName -ConfirmWordValue 'YES' -FirstNameIn <user first name> -LastNameIn <user last name> -ConfirmWordIn 'YES' -ContextIn <Active Directory context (optional if specified in settings.cfg)>"
Write-Host ""
Write-Host "[ EXAMPLES ]"
Write-Host ""
Write-Host "Example: .\$scriptName -ConfirmWordValue 'YES' -FirstNameIn Jane -LastNameIn Doe -ConfirmWordIn 'YES'"
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host "Example: .\$scriptName -ConfirmWordValue 'YES' -ContextIn OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com -FirstNameIn Jane -LastNameIn Doe -ConfirmWordIn 'YES'"
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host "Example: .\$scriptName -ConfirmWordValue 'YES' -FirstNameIn Jane -LastNameIn Doe -ConfirmWordIn 'YES' -ContextIn OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com"
Write-Host ""
Write-Host "[ ERROR HANDLING ]"
Write-Host ""
Write-Host "-ShowErrors = Show Error Messages"
Write-Host ""
Write-Host "Example: .\$scriptName -ShowErrors -ConfirmWordValue 'YES' -FirstNameIn Jane -LastNameIn Doe -ConfirmWordIn 'YES' -ContextIn OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com"
Write-Host ""
exit 0
}

if (Write-Output $args | Select-String "\-h\b|\-help\b" )
{
ShowHelp
}


if($contextIn.Length -lt 3){
ShowHelp
}



# This script expects 3 arguments, so if the 3rd argument is blank, then show the Help and exit
if (!( $firstNameInSet -and $lastNameInSet -and $confirmWordInSet )){ 
ShowHelp
 }
# -------------------------------------------------


Write-Output "Remove User: CN=$firstNameIn $lastNameIn,$contextIn"


# Use Remove-ADUser to remove the user
try{
Remove-ADUser  -Identity "CN=$firstNameIn $lastNameIn,$contextIn" -Confirm:$False 
}catch{
$deleteUserResult = $false
$err = "$_"
}

# If good result, display success message
if ($deleteUserResult)
{
Write-Output ""
Write-Output "------------------------------------------------------------------"
Write-Output ""
Write-Output "The User: ${firstNameIn} ${lastNameIn} | Was Removed From Active Directory"
Write-Output ""
Write-Output "------------------------------------------------------------------"
}else{
Write-Output ""
Write-Output "------------------------------------------------------------------"
Write-Output ""
Write-Output "The User: ${firstNameIn} ${lastNameIn} | Was NOT Removed Rrom Active Directory"
Write-Output ""
Write-Output "------------------------------------------------------------------"

    if ($verboseOutputSet){
    Write-Output "[ERROR MESSAGE BELOW]"
    Write-Output "-----------------------------"
    Write-Output ""
    Write-Output $err
    Write-Output ""
    Write-Output "-----------------------------"
    }

}

