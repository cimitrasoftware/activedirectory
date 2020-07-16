# Rename a Computer in Active Directory
# Author: Tay Kratzer tay@cimitra.com
# Change the context variable to match your system
# -------------------------------------------------
$context = "OU=COMPUTERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com" 
 # - OR -
 # Specify the context in settings.cfg file
 # Use this format: AD_COMPUTER_CONTEXT=<ACTIVE DIRECTORY CONTEXT>
 # Example: AD_COMPUTER_CONTEXT=OU=COMPUTERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com
 # -------------------------------------------------

# If a settings.cfg file exists read it and get the Active Directory Context from this file

if((Test-Path ${PSScriptRoot}\settings.cfg))
{
$CONFIG_IO="${PSScriptRoot}\config_reader.ps1"

. $CONFIG_IO

$CONFIG=(ReadFromConfigFile "${PSScriptRoot}\settings.cfg")

$context = "$CONFIG$AD_COMPUTER_CONTEXT"
}


if ($args[2]) { 

$context = $args[2]

}


# Show Help
function ShowHelp{
$scriptName = Split-Path -leaf $PSCommandpath
Write-Host ""
Write-Host "Script Usage"
Write-Host ""
Write-Host ".\$scriptName <current computer name> <new computer name> <Active Directory context (optional if specified otherwise)>"
Write-Host ""
Write-Host "Example: .\$scriptName WIN7BOX WIN10BOX"
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host "Example: .\$scriptName WIN7BOX WIN10BOX OU=COMPUTERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com"
Write-Host ""
exit 0
}

if (!$args[1]) { 
ShowHelp
 }
# -------------------------------------------------

$theComputerOldNameIn = $args[0]
$theComputerNewNameIn = $args[1]




Rename-ADObject -Identity "CN=$theComputerOldNameIn,$context" -NewName "$theComputerNewNameIn"  
$theResult = $?

if ($theResult)
{
Write-Output "--------------------------------------------------------"
Write-Output ""
Write-Output "The Computer: $theComputerOldNameIn was renamed to $theComputerNewNameIn"
Write-Output ""
Write-Output "--------------------------------------------------------"

}