# Change a User's Last Name in Active Directory
# Author: Tay Kratzer tay@cimitra.com
# Change the context variable to match your system
# Modify Date: 2/18/2021

Param(
    [string] $FirstNameIn,
    [string] $LastNameIn,
    [string] $NewLastNameIn,
    [string] $NewSamNameIn,
    [string] $ContextIn,
    [switch] $ShowErrors
 )

# -------------------------------------------------
$context = "OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com" 
 # - OR -
 # Specify the context in settings.cfg file
 # Use this format: AD_USER_CONTEXT=<ACTIVE DIRECTORY CONTEXT>
 # Example: AD_USER_CONTEXT=OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com
 # - OR -
 # Use the -ContextIn command line variable
 # Example: -ContextIn "OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com"
# ----------------------------------------------------------------------------------

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
$newLastnameInSet = $false
$newSamNameInSet = $false
$verboseOutputSet = $false
$modifyUserResult = $true
$sleepTime = 5



$firstNameIn = $FirstNameIn
$lastNameIn = $LastNameIn
$newLastNameIn = $NewLastNameIn
$newSamNameIn = $NewSamNameIn

$firstNameIn = [string]::join(" ",($firstNameIn.Split("`n"))).Trim()
$lastNameIn = [string]::join(" ",($lastNameIn.Split("`n"))).Trim()
$newLastNameIn = [string]::join(" ",($newLastNameIn.Split("`n"))).Trim()

$firstNameIn = (Get-Culture).TextInfo.ToTitleCase($firstNameIn) 
$lastNameIn = (Get-Culture).TextInfo.ToTitleCase($lastNameIn)
$newLastNameIn = (Get-Culture).TextInfo.ToTitleCase($newLastNameIn)


# New First Name
$newLastNameIn = [string]::join(" ",($newLastNameIn.Split("`n"))).Trim() 
$newLastNameIn = (Get-Culture).TextInfo.ToTitleCase($newLastNameIn) 

if ($ShowErrors){
$verboseOutputSet = $true
}

if($firstNameIn.Length -gt 2){
$firstNameInSet = $true
}

if($lastNameIn.Length -gt 2){
$lastNameInSet = $true
}

if($newLastNameIn.Length -gt 2){
$newLastNameInSet = $true
}

if($newSamNameIn.Length -gt 2){
$newSamNameInSet = $true
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
Write-Host "Change a User's Last Name in Active Directory"
Write-Host ""
Write-Host "[ HELP ]"
Write-Host ""
Write-Host ".\$scriptName -h or -help"
Write-Host ""
Write-Host "[ SCRIPT USAGE ]"
Write-Host ""
Write-Host ".\$scriptName -FirstNameIn <user first name> -LastNameIn <user last name> -NewLastNameIn <new last name> -NewSamNameIn <new SamAccountName> -ContextIn <Active Directory context (optional if specified in settings.cfg)>"
Write-Host ""
Write-Host "[ EXAMPLES ]"
Write-Host ""
Write-Host "Example: .\$scriptName -FirstNameIn Jane -LastNameIn Doe -NewLastNameIn Smith -NewSamNameIn jsmith"
Write-Host ""
Write-Host "[ ERROR HANDLING ]"
Write-Host ""
Write-Host "-ShowErrors = Show Error Messages"
Write-Host ""
Write-Host "Example: .\$scriptName -ShowErrors -FirstNameIn Jane -LastNameIn Doe -NewLastNameIn Smith -NewSamNameIn jsmith"
Write-Host ""
exit 0
}

if (Write-Output $args | Select-String "\-h\b|\-help\b" )
{
ShowHelp
}


if (!( $firstNameInSet -and $lastNameInSet -and $newLastNameInSet )){ 
ShowHelp
 }


if($contextIn.Length -lt 3){
ShowHelp
}


# -------------------------------------------------


try{
$test = Get-ADUser -Identity "CN=${firstNameIn} ${lastNameIn},$contextIn" 
}catch{
$modifyUserResult = $false
$err = "$_"
}

if (!($modifyUserResult))
{
Write-Output ""
Write-Output "Error: ${firstNameIn} ${lastNameIn} NOT changed in Active Directory"
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


# If exit code from the New-ADUser command was "True" then show a success message
if ($modifyUserResult)
{
Write-Output ""
Write-Output "-----------------------------"
Write-Output "User: ${firstNameIn} ${lastNameIn}"
Write-Output ""
Write-Output "Change To:"
Write-Output ""
write-output "User: ${newFirstNameIn} ${lastNameIn}"
Write-Output "-----------------------------"
}else{
Write-Output "User: ${firstNameIn} ${lastNameIn} NOT changed in Active Directory"
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

# Modify the user


try{
Get-ADUser -Identity "CN=${firstNameIn} ${lastNameIn},$contextIn"  | Rename-ADObject -NewName "${firstNameIn} ${newLastNameIn}" 
}catch{
$modifyUserResult = $false
$err = "$_"
}


# If exit code from the Get-ADUser command was "True" then show a success message
if ($modifyUserResult)
{
Write-Output ""
Write-Output "User: ${firstNameIn} ${lastNameIn}"
Write-Output ""
Write-Output "Changed To:"
Write-Output ""
write-output "User: ${firstNameIn} ${newLastNameIn}"
}else{
Write-Output ""
Write-Output "User: ${firstNameIn} ${lastNameIn} NOT changed in Active Directory"
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

CALL_SLEEP

$NewSamNameInEmpty = [string]::IsNullOrWhiteSpace($NewSamNameIn)

Write-Output "User Display Name: ${firstNameIn} ${lastNameIn}"
Write-Output ""
Write-Output "Change To:"
Write-Output ""
write-output "Display Name: ${firstNameIn} ${newLastNameIn}"
Write-Output ""
try{
if($NewSamNameInEmpty){
Get-ADUser -Identity "CN=${firstNameIn} ${newLastNameIn},$contextIn"  | Set-ADUser -Surname "${newLastNameIn}" -DisplayName "${firstNameIn} ${newLastNameIn}" 
}else{
Get-ADUser -Identity "CN=${firstNameIn} ${newLastNameIn},$contextIn"  | Set-ADUser -Surname "${newLastNameIn}" -DisplayName "${firstNameIn} ${newLastNameIn}" -SamAccountName "${newSamNameIn}" 
}
}catch{
$modifyUserResult = $false
$err = "$_"
}

if($NewSamNameInEmpty){
# If exit code from the New-ADUser command was "True" then show a success message
if ($modifyUserResult)
{
Write-Output ""
Write-Output "------------"
Write-Output "| SUCCESS! |"
Write-Output "------------"
Write-Output ""
}else{
Write-Output ""
Write-Output "ERROR: User: ${firstNameIn} ${newLastNameIn} display name NOT changed in Active Directory"
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

}


