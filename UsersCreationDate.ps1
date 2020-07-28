# Check Password Set Date in Active Directory
# Author: Tay Kratzer tay@cimitra.com
# Change the context variable to match your system
# -------------------------------------------------
# Get-Command -module ActiveDirectory

$context = "OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com" 
 # - OR -
 # Specify the context in settings.cfg file
 # Use this format: AD_USER_CONTEXT=<ACTIVE DIRECTORY CONTEXT>
 # Example: AD_USER_CONTEXT=OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com
 # -------------------------------------------------

$contextInSet = $false
$setContextInSet = $false
$verboseOutputSet = $false
$modifyUserResult = $true
$sleepTime = 5
$SCRIPT_DESCRIPTION = "List Users Created From X Days Ago"

if(Write-Output $args | Select-String '-dayCountIn'){
$theArgs = $MyInvocation.Line
$dayCountIn = $theArgs  -split "(?<=-dayCountIn)\s" | Select -Skip 1 -First 1
}


if(Write-Output $args | Select-String '-contextIn'){
$theArgs = $MyInvocation.Line
$contextIn = $theArgs  -split "(?<=-contextIn)\s" | Select -Skip 1 -First 1
}

if (Write-Output "$args" | Select-String -CaseSensitive "-showErrors" ){
$verboseOutputSet = $true
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

function ShowHelp{
$scriptName = Split-Path -leaf $PSCommandpath
Write-Host ""
Write-Host "${SCRIPT_DESCRIPTION}"
Write-Host ""
Write-Host "[ HELP ]"
Write-Host ""
Write-Host ".\$scriptName -h or -help"
Write-Host ""
Write-Host "[ SCRIPT USAGE ]"
Write-Host ""
Write-Host ".\$scriptName -dayCountIn <number of days ago to look> -contextIn <Active Directory context (optional if specified in settings.cfg)>"
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host ".\$scriptName -setContext <Active Directory context (optional if specified in settings.cfg)> -dayCountIn <number of days ago to look>"
Write-Host ""
Write-Host "[ EXAMPLES ]"
Write-Host ""
Write-Host "Example: .\$scriptName -dayCountIn 7"
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host "Example: .\$scriptName -setContext OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com -dayCountIn 7"
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host "Example: .\$scriptName -dayCountIn 7 -contextIn OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com"
Write-Host ""
Write-Host "[ ERROR HANDLING ]"
Write-Host ""
Write-Host "-showErrors = Show Error Messages"
Write-Host ""
Write-Host "Example: .\$scriptName -showErrors -dayCountIn 7"
Write-Host ""
exit 0
}

if (Write-Output $args | Select-String "\-h\b|\-help\b" )
{
ShowHelp
}


# This script expects 3 arguments, so if the 3rd argument is blank, then show the Help and exit
if (!( $dayCountIn )){ 
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
    Write-Output "Check Users in Context: $context"
}else{
    if($setContextInSet){
    $context = $setContextIn
    }
}


Write-Output ""
if(${dayCountIn} -eq 1){
Write-Output "Users created in the last day"
}else{
Write-Output "Users created in the last: ${dayCountIn} days"
}

Write-Output ""
Write-Output "--------------------------------------------"

try{
$When = ((Get-Date).AddDays(-${dayCountIn})).Date
Get-ADUser -Filter {whenCreated -ge $When} -Properties WhenCreated | select Name, WhenCreated
}catch{
$modifyUserResult = $false
$err = "$_"
}


# If exit code from the command was "True" then show a success message

if ($modifyUserResult)
{
Write-Output "--------------------------------------------"
Write-Output ""
}else{
Write-Output "--------------------------------------------"
Write-Output ""
Write-Output "Error: Unable to determine this information"
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



