﻿# Check Password Set Date in Active Directory
# Author: Tay Kratzer tay@cimitra.com
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


$firstNameInSet = $false
$lastNameInSet = $false
$contextInSet = $false
$verboseOutputSet = $false
$modifyUserResult = $true
$sleepTime = 5

$firstNameIn = ([Regex]'(?is)(?:(?<=\-firstNameIn).+(?=-lastNameIn))').Match(($args -join "`n")).Value 

$firstNameIn = [string]::join(" ",($firstNameIn.Split("`n"))).Trim()

$firstNameIn = (Get-Culture).TextInfo.ToTitleCase($firstNameIn) 

if(Write-Output $args | Select-String '-contextIn'){
$lastNameIn = ([Regex]'(?is)(?:(?<=\-lastNameIn).+(?=-contextIn))').Match(($args -join "`n")).Value 
}else{
    if(Write-Output $args | Select-String '-lastNameIn'){
        $theArgs = $MyInvocation.Line
        $lastNameIn = $theArgs  -split "(?<=-lastNameIn)\s" | Select -Skip 1 -First 1
        $lastNameIn = (Get-Culture).TextInfo.ToTitleCase($lastNameIn)
        }
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

if($contextIn.Length -gt 2){
$contextInSet = $true
}



# Show Help
function ShowHelp{
$scriptName = Split-Path -leaf $PSCommandpath
Write-Host ""
Write-Host "Help"
Write-Host ""
Write-Host ".\$scriptName -h or -help"
Write-Host ""
Write-Host "Script Usage"
Write-Host ""
Write-Host ".\$scriptName -firstNameIn <user first name> -lastNameIn <user last name> -contextIn <Active Directory context (optional if specified otherwise)>"
Write-Host ""
Write-Host "Example: .\$scriptName -firstNameIn Jane -lastNameIn Doe"
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host "Example: .\$scriptName -firstNameIn Jane -lastNameIn Doe -contextIn OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com"
Write-Host ""
Write-Host "-showErrors = Show Error Messages"
Write-Host ""
Write-Host "Example: .\$scriptName -showErrors -firstNameIn Jane -lastNameIn Doe -contextIn OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com"
Write-Host ""
exit 0
}

if (Write-Output $args | Select-String "\-h\b|\-help\b" )
{
ShowHelp
}

# This script expects 2 arguments
if (!( $firstNameInSet -and $lastNameInSet )){ 
ShowHelp
 }

# -------------------------------------------------


# If a fourth argument is sent into this script, that fourth argument will be mapped to the $context variable

if ($contextInSet) { 
$context = $contextIn
Write-Output ""
Write-Output "Modify User in Context: $context"
}

try{
 $theResult=Get-ADUser -properties PasswordLastSet  -Identity "CN=${firstNameIn} ${lastNameIn},$context" | Select-Object PasswordLastSet -ExpandProperty PasswordLastSet 
 }catch{
 $modifyUserResult = $false
 $err = "$_"
 }

 if ($modifyUserResult){
 Write-Output "------------------------------------------------------------------------------"
 Write-Output ""
 Write-Output "Last Password Reset for User: ${firstNameIn} ${LastNameIn} was on: ${theResult}"
 Write-Output ""
 Write-Output "------------------------------------------------------------------------------"
 }else{
 Write-Output ""
Write-Output "Unable to Find Last Password Reset for User: ${firstNameIn} ${lastNameIn}"
Write-Output ""
    if ($verboseOutputSet){
    Write-Output "[ERROR MESSAGE BELOW]"
    Write-Output "-----------------------------"
    Write-Output ""
    Write-Output $err
    Write-Output ""
    Write-Output "-----------------------------"
    }


 }


