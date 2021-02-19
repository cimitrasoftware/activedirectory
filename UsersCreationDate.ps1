# Check Users Created Since a Certain Set of Days in Active Directory
# Author: Tay Kratzer tay@cimitra.com
# Modify Date: 2/18/2021
# Change the context variable to match your system
# -------------------------------------------------

Param(
    [string] $DayCountIn,
    [switch] $ShowErrors
 )

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
}

}



$verboseOutputSet = $false
$sleepTime = 5
$modifyUserResult = $true
$SCRIPT_DESCRIPTION = "List Users Created From X Days Ago"


$dayCountIn = $DayCountIn


if ($ShowErrors){
$verboseOutputSet = $true
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
Write-Host ".\$scriptName -DayCountIn <number of days ago to look> "
Write-Host ""
Write-Host "[ EXAMPLES ]"
Write-Host ""
Write-Host "Example: .\$scriptName -DayCountIn 7"
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host "Example: .\$scriptName -DayCountIn 7"
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host "Example: .\$scriptName -DayCountIn 7"
Write-Host ""
Write-Host "[ ERROR HANDLING ]"
Write-Host ""
Write-Host "-ShowErrors = Show Error Messages"
Write-Host ""
Write-Host "Example: .\$scriptName -ShowErrors -DayCountIn 7"
Write-Host ""
exit 0
}

if (Write-Output $args | Select-String "\-h\b|\-help\b" )
{
ShowHelp
}


if (!( $dayCountIn )){ 
ShowHelp
 }
# -------------------------------------------------


 Write-Output ""
if(${dayCountIn} -eq 1){
Write-Output "Users created in the last day"
}else{
Write-Output "Users created in the last: ${dayCountIn} days"
}
Write-Output "--------------------------------------------"

try{
$When = ((Get-Date).AddDays(-${dayCountIn})).Date
Get-ADUser -Filter {whenCreated -ge $When} -Properties WhenCreated | select Name, WhenCreated | fl
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
Write-Output ""
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



