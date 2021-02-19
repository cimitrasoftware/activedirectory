# List users in Active Directory who have never logged on
# Author: Tay Kratzer tay@cimitra.com
# Change the context variable to match your system
# Modify Date: 2/18/2021
# -------------------------------------------------

# Get the -ContextIn parameter
Param(
    [string] $ContextIn,
    [switch] $ShowErrors
 )


$context = "OU=DEMOUSERS,OU=DEMO,DC=cimitrademo,DC=com" 
 # - OR -
 # Specify the context in settings.cfg file
 # Use this format: AD_USER_CONTEXT=<ACTIVE DIRECTORY CONTEXT>
 # Example: AD_USER_CONTEXT=OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com
 # -------------------------------------------------

# If a settings.cfg file exists read it and get the Active Directory Context from this file

$verboseOutputSet = $false
$global:listUsersResult = $true

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
if ($contextTest = "$CONFIG$AD_USER_CONTEXT"){
$context = "$CONFIG$AD_USER_CONTEXT"
}

}

}


# Show Help
function ShowHelp{
$scriptName = Split-Path -leaf $PSCommandpath
Write-Host ""
Write-Host "List Users in Active Directory"
Write-Host ""
Write-Host "[ HELP ]"
Write-Host ""
Write-Host ".\$scriptName -h or -help"
Write-Host ""
Write-Host "[ SCRIPT USAGE ]"
Write-Host ""
Write-Host ".\$scriptName -ContextIn <Active Directory context (optional if specified in settings.cfg file)>"
Write-Host ""
Write-Host "[ EXAMPLES ]"
Write-Host ""
Write-Host "Example: .\$scriptName"
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host "Example: .\$scriptName -ContextIn OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com"
Write-Host ""
Write-Host "[ ERROR HANDLING ]"
Write-Host ""
Write-Host "-ShowErrors = Show Error Messages"
Write-Host ""
Write-Host "Example: .\$scriptName -ShowErrors"
Write-Host ""
exit 0
}
if (Write-Output $args | Select-String "\-h\b|\-help\b" )
{
ShowHelp
}


$ContextInEmpty = [string]::IsNullOrWhiteSpace($ContextIn)

if($ContextInEmpty){
$contextIn = $context
}else{
$contextIn = $ContextIn
}
if($contextIn.Length -lt 3){
ShowHelp
}



Write-Output ""
Write-Output "Following is a list of all users who have never logged in."
Write-Output "----------------------------------------------------------"

function LIST_USERS
{ 
try{
get-aduser -SearchBase "${contextIn}" -Filter {-not (lastlogontimestamp -like "*") -and -not (iscriticalsystemobject -eq $true)}  | select Name, SamAccountName | fl
 }catch{
 $err = "$_"
 $global:err = $err
 $global:listUsersResult = $false
 }


}

LIST_USERS

if ($listUsersResult)
{

Write-Output "----------------------------------------------------------"
}else{
Write-Output "Error: Unable Generate List in Active Directory"
Write-Output ""
Write-Output "----------------------------------------------------------"
    if ($verboseOutputSet){
    Write-Output "[ERROR MESSAGE BELOW]"
    Write-Output "-----------------------------"
    Write-Output ""
    Write-Output $err
    Write-Output ""
    Write-Output "-----------------------------"
    }

}