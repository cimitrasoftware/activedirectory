# Remove a Computer in Active Directory
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

if((Test-Path ${PSScriptRoot}\config_reader.ps1)){

if((Test-Path ${PSScriptRoot}\settings.cfg))
{
$CONFIG_IO="${PSScriptRoot}\config_reader.ps1"

. $CONFIG_IO

$CONFIG=(ReadFromConfigFile "${PSScriptRoot}\settings.cfg")

$context = "$CONFIG$AD_COMPUTER_CONTEXT"
}

}


if ($args[1]) { 

$context = $args[1]

}



# Show Help
function ShowHelp{
$scriptName = Split-Path -leaf $PSCommandpath
Write-Host ""
Write-Host "Script Usage"
Write-Host ""
Write-Host ".\$scriptName <current computer name> <Active Directory context (optional if specified otherwise)>"
Write-Host ""
Write-Host "Example: .\$scriptName WIN7BOX"
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host "Example: .\$scriptName WIN7BOX OU=COMPUTERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com"
Write-Host ""
exit 0
}

if (!$args[0]) { 
ShowHelp
 }
# -------------------------------------------------

$theComputer=$args[0]


# Use Remove-ADComputer to remove the computer
Remove-ADComputer  -Identity "CN=$theComputer,$context" -Confirm:$False
# Catch the exit code from running the command
$theResult = $?

if($theResult)
{
Write-Output ""
Write-Output "------------------------------------------------------------------"
Write-Output ""
Write-Output "The Computer: $theComputer was removed from Active Directory"
Write-Output ""
Write-Output "------------------------------------------------------------------"
}




