# Change Password in Active Directory
# Author: Tay Kratzer tay@cimitra.com
# Change the context variable to match your system
# Modify Date: 2/18/21
# -------------------------------------------------

Param(
    [string] $FirstNameIn,
    [string] $LastNameIn,
    [string] $ContextIn,
    [string] $PasswordIn,
    [switch] $ForcePasswordReset,
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
$passwordInSet = $false
$verboseOutputSet = $false
$global:forcePasswordResetSet = $false
$modifyUserResult = $true
$sleepTime = 5



$firstNameIn = $FirstNameIn
$lastNameIn = $LastNameIn

$firstNameIn = [string]::join(" ",($firstNameIn.Split("`n"))).Trim()

$lastNameIn = [string]::join(" ",($lastNameIn.Split("`n"))).Trim()



$firstNameIn = (Get-Culture).TextInfo.ToTitleCase($firstNameIn) 
$lastNameIn = (Get-Culture).TextInfo.ToTitleCase($lastNameIn)


$passwordIn = [string]::join(" ",($PasswordIn.Split("`n"))).Trim()


if ($ShowErrors){
$verboseOutputSet = $true
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
Write-Host "Set a User's Password in Active Directory"
Write-Host ""
Write-Host "[ HELP ]"
Write-Host ""
Write-Host ".\$scriptName -h or -help"
Write-Host ""
Write-Host "[ SCRIPT USAGE ]"
Write-Host ""
Write-Host ".\$scriptName -FirstNameIn <user first name> -LastNameIn <user last name> -PasswordIn <password> -contextIn <Active Directory context (optional if specified in settings.cfg)>"
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host ".\$scriptName -ContextIn <Active Directory context (optional if specified in settings.cfg)> -FirstNameIn <user first name> -LastNameIn <user last name> -PasswordIn <password>"
Write-Host ""
Write-Host "[ EXAMPLES ]"
Write-Host ""
Write-Host "Example: .\$scriptName -FirstNameIn Jane -LastNameIn Doe -PasswordIn p433w0r9_ch4ng3"
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host "Example: .\$scriptName -ContextIn OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com -FirstNameIn Jane -LastNameIn Doe -PasswordIn p433w0r9_ch4ng3"
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host "Example: .\$scriptName -FirstNameIn Jane -LastNameIn Doe -PasswordIn p433w0r9_ch4ng3 -contextIn OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com"
Write-Host ""
Write-Host "[ ERROR HANDLING ]"
Write-Host ""
Write-Host "-ShowErrors = Show Error Messages"
Write-Host ""
Write-Host "Example: .\$scriptName -ShowErrors -FirstNameIn Jane -LastNameIn Doe -PasswordIn p433w0r9_ch4ng3"
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


# Must Use The Password Switch
if (!( $passwordInSet )){ 
ShowHelp
 }
# -------------------------------------------------


# This script expects 3 arguments, so if the 3rd argument is blank, then show the Help and exit
if (!( $firstNameInSet -and $lastNameInSet -and $passwordInSet )){ 
ShowHelp
 }
# -------------------------------------------------

if($contextIn.Length -lt 3){
ShowHelp
}



# Modify the user
try{
Set-ADAccountPassword -Identity "CN=${firstNameIn} ${lastNameIn},$contextIn" -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "${passwordIn}" -Force)
}catch{
$modifyUserResult = $false
$err = "$_"
}

# See if the -forcePasswordReset variable was passed in
if ($ForcePasswordReset){
$global:forcePasswordResetSet = $true
}

# If exit code from the New-ADUser command was "True" then show a success message
if ($modifyUserResult)
{
Write-Output ""
Write-Output "User: ${firstNameIn} ${lastNameIn} password changed"
}else{
Write-Output ""
Write-Output "User: ${firstNameIn} ${lastNameIn} password was NOT changed in Active Directory"
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



if($forcePasswordResetSet){
CALL_SLEEP
# Force an immediate password reset
 Set-ADUser -Identity  "CN=$firstNameIn $lastNameIn,$context" -ChangePasswordAtLogon $true
 Write-Output ""
 Write-Output "NOTE: This user will be required to change their password the next time they log in."
 Write-Output ""
}

$theResult = Get-ADUser -properties PasswordLastSet  -Identity "CN=${firstNameIn} ${lastNameIn},$contextIn" | Select-Object PasswordLastSet -ExpandProperty PasswordLastSet
 
if(!($forcePasswordResetSet)){
 Write-Output "------------------------------------------------------------------------------"
 Write-Output ""
 Write-Output "Password Reset for User: ${firstNameIn} ${lastNameIn} was on: ${theResult}"
 Write-Output ""
 Write-Output "------------------------------------------------------------------------------"
 }