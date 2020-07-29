# Check Password Set Date in Active Directory
# Author: Tay Kratzer tay@cimitra.com
# Change the context variable to match your system
# -------------------------------------------------
$context = "OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com" 
 # - OR -
 # Specify the context in settings.cfg file
 # Use this format: AD_USER_CONTEXT=<ACTIVE DIRECTORY CONTEXT>
 # Example: AD_USER_CONTEXT=OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com
 # -------------------------------------------------

$firstNameInSet = $false
$lastNameInSet = $false
$passwordInSet = $false
$contextInSet = $false
$setContextInSet = $false
$verboseOutputSet = $false
$global:forcePasswordResetSet = $false
$modifyUserResult = $true
$sleepTime = 5



$firstNameIn = ([Regex]'(?is)(?:(?<=\-firstNameIn).+(?=-lastNameIn))').Match(($args -join "`n")).Value 

$firstNameIn = [string]::join(" ",($firstNameIn.Split("`n"))).Trim()

$firstNameIn = (Get-Culture).TextInfo.ToTitleCase($firstNameIn) 

$lastNameIn = ([Regex]'(?is)(?:(?<=\-lastNameIn).+(?=-passwordIn))').Match(($args -join "`n")).Value 

$lastNameIn = [string]::join(" ",($lastNameIn.Split("`n"))).Trim() 

$lastNameIn = (Get-Culture).TextInfo.ToTitleCase($lastNameIn) 

Write-Output $args | Select-String '-passwordIn' -Context 0,1 | ForEach-Object {
$passwordIn = $_.Context.PostContext.Trim() 
}

if(Write-Output $args | Select-String '-contextIn'){
$theArgs = $MyInvocation.Line
$contextIn = $theArgs  -split "(?<=-contextIn)\s" | Select -Skip 1 -First 1
}

if (Write-Output "$args" | Select-String -CaseSensitive "-showErrors" ){
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

if($contextIn.Length -gt 2){
$contextInSet = $true
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
Write-Host ".\$scriptName -firstNameIn <user first name> -lastNameIn <user last name> -passwordIn <password> -contextIn <Active Directory context (optional if specified in settings.cfg)>"
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host ".\$scriptName -setContext <Active Directory context (optional if specified in settings.cfg)> -firstNameIn <user first name> -lastNameIn <user last name> -passwordIn <password>"
Write-Host ""
Write-Host "[ EXAMPLES ]"
Write-Host ""
Write-Host "Example: .\$scriptName -firstNameIn Jane -lastNameIn Doe -passwordIn p433w0r9_ch4ng3"
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host "Example: .\$scriptName -setContext OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com -firstNameIn Jane -lastNameIn Doe -passwordIn p433w0r9_ch4ng3"
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host "Example: .\$scriptName -firstNameIn Jane -lastNameIn Doe -passwordIn p433w0r9_ch4ng3 -contextIn OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com"
Write-Host ""
Write-Host "[ ERROR HANDLING ]"
Write-Host ""
Write-Host "-showErrors = Show Error Messages"
Write-Host ""
Write-Host "Example: .\$scriptName -showErrors -firstNameIn Jane -lastNameIn Doe -passwordIn p433w0r9_ch4ng3"
Write-Host ""
Write-Host "-forcePasswordReset = Force a Password Reset on Next User Login"
Write-Host ""
Write-Host "Example: .\$scriptName -forcePasswordReset -firstNameIn Jane -lastNameIn Doe -passwordIn p433w0r9_ch4ng3"
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


# If a fourth argument is sent into this script, that fourth argument will be mapped to the $context variable

if(Write-Output $args | Select-String '-setContext'){
$theArgs = $MyInvocation.Line
$setContextIn = $theArgs  -split "(?<=-setContext)\s" | Select -Skip 1 -First 1
}

if($setContextIn.Length -gt 2){
$setContextInSet = $true
}


if ($contextInSet){ 
    $context = $contextIn
    Write-Output ""
    Write-Output "Modify User in Context: $context"
}else{
    if($setContextInSet){
    $context = $setContextIn
    }
}


# Modify the user
try{
Set-ADAccountPassword -Identity "CN=${firstNameIn} ${lastNameIn},$context" -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "${passwordIn}" -Force)
}catch{
$modifyUserResult = $false
$err = "$_"
}

# See if the -forcePasswordReset variable was passed in
if (Write-Output "$args" | Select-String -CaseSensitive "-forcePasswordReset" ){
$global:forcePasswordResetSet = $true
}

# If exit code from the New-ADUser command was "True" then show a success message
if ($modifyUserResult)
{
Write-Output ""
Write-Output "User: ${firstNameIn} ${lastNameIn} password changed in Active Directory"
Write-Output ""
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

$theResult=Get-ADUser -properties PasswordLastSet  -Identity "CN=${firstNameIn} ${lastNameIn},$context" | Select-Object PasswordLastSet -ExpandProperty PasswordLastSet
 
 Write-Output "------------------------------------------------------------------------------"
 Write-Output ""
 Write-Output "Password reset for User: ${firstNameIn} ${lastNameIn} was on: ${theResult}"
 Write-Output ""
 Write-Output "------------------------------------------------------------------------------"
