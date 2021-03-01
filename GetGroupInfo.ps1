# Get User Info From Active Directory
# Author: Tay Kratzer tay@cimitra.com
# Change the context variable to match your system
# Modify Date: 2/18/2021
# -------------------------------------------------

Param(
    [string] $GroupNameIn,
    [string] $ContextIn,
    [switch] $ShowErrors
 )

  Set-Variable -Name groupNameIn -Value "$GroupNameIn" -Option AllScope


## USING A SETTINGS CONFIGURATION FILE ##
# -------------------------------------------------
# Create a file called settings.cfg
# Add these two fields
# AD_USER_CONTEXT=OU=DEMOUSERS,OU=DEMO,DC=cimitrademo,DC=com
# AD_COMPUTER_CONTEXT=OU=COMPUTERS,OU=DEMO,DC=cimitrademo,DC=com
# Edit the settings to match your Active Directory context for users and computers
# -------------------------------------------------

# -------------------------------------------------
$context = "OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com" 
 # - OR -
 # Specify the context in settings.cfg file
 # Use this format: AD_USER_CONTEXT=<ACTIVE DIRECTORY CONTEXT>
 # Example: AD_USER_CONTEXT=OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com
 # - OR -
 # Use the -ContextIn command line variable
 # Example: -ContextIn "OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com"
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


$groupNameInSet = $false
$verboseOutputSet = $false
$modifyUserResult = $true

$ContextInEmpty = [string]::IsNullOrWhiteSpace($ContextIn)


if($ContextInEmpty){
$contextIn = $context
}else{
$contextIn = $ContextIn
}


if ($ShowErrors){
$verboseOutputSet = $true
}

if($groupNameIn.Length -gt 2){
$groupNameInSet = $true
}



# Show Help
function ShowHelp{
$scriptName = Split-Path -leaf $PSCommandpath
Write-Host ""
Write-Host "Get Group Information From Active Directory Group"
Write-Host ""
Write-Host "[ HELP ]"
Write-Host ""
Write-Host ".\$scriptName -h or -help"
Write-Host ""
Write-Host "[ SCRIPT USAGE ]"
Write-Host ""
Write-Host ".\$scriptName -GroupNameIn <Active Directory Group> -ContextIn <Active Directory context (optional if specified in settings.cfg)>"
Write-Host ""
Write-Host "[ EXAMPLES ]"
Write-Host ""
Write-Host "Example: .\$scriptName -GroupNameIn 'Accounting Group'"
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host "Example: .\$scriptName -GroupNameIn 'Accounting Group' -ContextIn OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com"
Write-Host ""
Write-Host "[ ERROR HANDLING ]"
Write-Host ""
Write-Host "-showErrors = Show Error Messages"
Write-Host ""
Write-Host "Example: .\$scriptName -ShowErrors -GroupNameIn 'Accounting Group'"
Write-Host ""
exit 0
}

if($contextIn.Length -lt 3){
ShowHelp
}


if (Write-Output $args | Select-String "\-h\b|\-help\b" )
{
ShowHelp
}

# This script expects 1 arguments
if (!( $groupNameInSet )){ 
ShowHelp
 }

# -------------------------------------------------

try{
$GroupObject = Get-ADGroup -Identity "$groupNameIn"
$GroupGUID = $GroupObject.ObjectGUID.ToString()
$GroupName = $GroupObject.Name.ToString()
$DistinguishedName = $GroupObject.DistinguishedName.ToString()
$GroupOU = "OU="+($DistinguishedName -split ",OU=",2)[1]
}catch{}

Write-Output "Info On Group [ $GroupName ]"
Write-Output "--------------------------------------------------------------------"
Write-Output ""
Write-Output "Group Name: $GroupName"
Write-Output ""
Write-Output "Group GUID: $GroupGUID"
Write-Output ""
Write-Output "Group OU Location: $GroupOU"
Write-Output ""
Write-Output "--------------------------------------------------------------------"
Write-Output "Membership For Group [ $GroupName ]"
Write-Output "--------------------------------------------------------------------"
Get-ADGroupMember -Identity "$groupNameIn" | Select-Object name, objectClass,distinguishedName | ft -HideTableHeaders
Write-Output "--------------------------------------------------------------------"


try{
Get-ADGroup -Identity "$groupNameIn" -Properties *
}catch{}


