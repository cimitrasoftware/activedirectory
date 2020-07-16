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
if((Test-Path ${PSScriptRoot}\config_reader.ps1)){

if((Test-Path ${PSScriptRoot}\settings.cfg))
{
$CONFIG_IO="${PSScriptRoot}\config_reader.ps1"

. $CONFIG_IO

$CONFIG=(ReadFromConfigFile "${PSScriptRoot}\settings.cfg")

$context = "$CONFIG$AD_COMPUTER_CONTEXT"
}

}
# -------------------------------------------------

if ($args[0]) { 

$context = $args[0]

 }

Write-Output ""
Write-Output "Active Directory Context: $context"
Write-Output ""
Write-Output "Following is a list of all of the computers, newest to oldest."
Write-Output ""
Write-Output "------------------------------------------------------"
function reverse
{ 
 $arr = @(Get-ADComputer -Filter * -SearchBase $context | Select Name) 
 [array]::reverse($arr)
 $arr
}
#Call the reverse function
reverse
Write-Output ""
Write-Output "------------------------------------------------------"