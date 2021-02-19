﻿# Create a New User in Active Directory
# Author: Tay Kratzer tay@cimitra.com
# Change the context variable to match your system
# Modify Date: 2/18/2021
# -------------------------------------------------

# Get the -ContextIn parameter
Param(
    [string] $ContextIn,
    [string] $FirstNameIn,
    [string] $LastNameIn,
    [string] $PasswordIn,
    [switch] $ForcePasswordReset,
    [switch] $ShowErrors

 )


$context = "OU=DEMOUSERS,OU=DEMO,DC=cimitrademo,DC=com" 
 # - OR -
 # Specify the context in settings.cfg file
 # Use this format: AD_USER_CONTEXT=<ACTIVE DIRECTORY CONTEXT>
 # Example: AD_USER_CONTEXT=OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com
 # -------------------------------------------------

# If a settings.cfg file exists read it and get the Active Directory Context from this file

$firstNameInSet = $false
$lastNameInSet = $false
$passwordInSet = $false
$verboseOutputSet = $false
$global:forcePasswordResetSet = $false
$createUserResult = $true
$sleepTime = 5

# Get the First Name variable passed in
# Get change to title case if the culture dictates
$firstNameIn = (Get-Culture).TextInfo.ToTitleCase($FirstNameIn) 

# Get the Last Name variable passed in
# Get change to title case if the culture dictates
$lastNameIn = (Get-Culture).TextInfo.ToTitleCase($LastNameIn) 

# Get the Password variable passed in
Write-Output $args | Select-String '-PasswordIn' -Context 0,1 | ForEach-Object {
$passwordIn = $_.Context.PostContext.Trim() 
}


# See if the -ShowErrors variable was passed in
if ($ShowErrors){
$verboseOutputSet = $true
}

# See if the -showErrors variable was passed in
if ($ForcePasswordReset){
$global:forcePasswordResetSet = $true
}


if($firstNameIn.Length -gt 2){
$firstNameInSet = $true
}

if($lastNameIn.Length -gt 2){
$lastNameInSet = $true
}

if($passwordIn.Length -gt 2){
$passwordInSet = $true
}


# Look to see if a config_reader.ps1 file exists in order to use it's functionality
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
Write-Host "Create User in Active Directory"
Write-Host ""
Write-Host "[ HELP ]"
Write-Host ""
Write-Host ".\$scriptName -h or -help"
Write-Host ""
Write-Host "[ SCRIPT USAGE ]"
Write-Host ""
Write-Host ".\$scriptName -FirstNameIn <user first name> -LastNameIn <user last name> -PasswordIn <password> -ContextIn <Active Directory context (optional if specified in settings.cfg)>"
Write-Host ""
Write-Host "[ EXAMPLES ]"
Write-Host ""
Write-Host "Example: .\$scriptName -FirstNameIn Jane -LastNameIn Doe -PasswordIn p433w0r9_ch4ng3"
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host "Example: .\$scriptName -FirstNameIn Jane -LastNameIn Doe -PasswordIn p433w0r9_ch4ng3 -ContextIn OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com"
Write-Host ""
Write-Host "[ ERROR HANDLING ]"
Write-Host ""
Write-Host "-ShowErrors = Show Error Messages"
Write-Host ""
Write-Host "Example: .\$scriptName -ShowErrors -FirstNameIn Jane -LastNameIn Doe -PasswordIn p433w0r9_ch4ng3 -ContextIn OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com"
Write-Host ""
Write-Host "[ PREFERENCES ]"
Write-Host ""
Write-Host "-ForcePasswordReset = Force a Password Reset on Next User Login"
Write-Host ""
Write-Host "Example: .\$scriptName -ForcePasswordReset -FirstNameIn Jane -LastNameIn Doe -PasswordIn p433w0r9_ch4ng3"
Write-Host ""
exit 0
}

if (Write-Output $args | Select-String "\-h\b|\-help\b" )
{
ShowHelp
}


# This script expects 3 arguments, so if the 3rd argument is blank, then show the Help and exit
if (!( $firstNameInSet -and $lastNameInSet -and $passwordInSet )){ 
ShowHelp
 }
# -------------------------------------------------


$ContextInEmpty = [string]::IsNullOrWhiteSpace($ContextIn)

if($ContextInEmpty){
$contextIn = $context
}else{
$contextIn = $ContextIn
}
if($contextIn.Length -lt 3){
ShowHelp
}


# Make the samAccountName variable from a combination of the user's first and last name
$samAccountName = ($firstNameIn+$lastNameIn).ToLower()

# Create the new user
try{

New-ADUser -Name "$firstNameIn $lastNameIn" -GivenName "$firstNameIn" -Surname "$lastNameIn" -SamAccountName "$samAccountName" -AccountPassword (ConvertTo-SecureString "$passwordIn" -AsPlainText -force) -passThru -path "$contextIn" -Enabled $true | out-null

}catch{
$createUserResult = $false
$err = "$_"
}


# If exit code from the New-ADUser command was "True" then show a success message
if ($createUserResult)
{
Write-Output ""
Write-Output "New User: ${firstNameIn} ${lastNameIn} created in Active Directory"
Write-Output ""
}else{
Write-Output ""
Write-Output "User: ( ${firstNameIn} ${lastNameIn} ) was NOT created in Active Directory"
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





if($ForcePasswordReset){
 CALL_SLEEP
# Force an immediate password reset
 Set-ADUser -Identity  "CN=$firstNameIn $lastNameIn,$contextIn" -ChangePasswordAtLogon $true
 Write-Output ""
 Write-Output "NOTE: $firstNameIn will be required to change their password the next time they log in."
 Write-Output ""

}

