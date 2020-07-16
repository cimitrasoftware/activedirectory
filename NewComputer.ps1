# Create a Computer in Active Directory
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


if ($args[2]) { 

$context = $args[2]

}



# Show Help
function ShowHelp{
$scriptName = Split-Path -leaf $PSCommandpath
Write-Host ""
Write-Host "Script Usage"
Write-Host ""
Write-Host ".\$scriptName <ComputerName> <Computer Type 1=Mac, 2=Windows, 3=Linux, 4=Linux, 5=Other><Active Directory context (optional if specified otherwise)>"
Write-Host ""
Write-Host "Example: .\$scriptName WIN10BOX_ONE 2"
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host "Example: .\$scriptName WIN10BOX_ONE 2 OU=COMPUTERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com"
Write-Host ""
exit 0
}

if (!$args[1]) { 
ShowHelp
 }
# -------------------------------------------------

# Get the first command-line variable
$theComputer=$args[0]
# Get the second command-line variable
$theComputerType=$args[1]

# Correlate the number to a word with a switch statement
switch ($theComputerType)
{

    1 {$ComputerType = 'MacOS'}
    2 {$ComputerType = 'Windows'}
    3 {$ComputerType = 'Chromebook'}
    4 {$ComputerType = 'Linux'}
    5 {$ComputerType = 'Other'}
    default{$ComputerType = 'MacOS'}

}

# Add the Computer to Active Directory
New-ADComputer $theComputer -Path $context 
# Get the exit result from Active Directory
$theResult = $?

# If good result, display success, and update the OS
if ($theResult)
{
Write-Output ""
Write-Output ""
Write-Output "The Computer: $theComputer was created in Active Directory"
Set-ADComputer -OperatingSystem "${ComputerType}" -Identity "CN=$theComputer,$context"
Write-Output "Computer Type = ${ComputerType}"
Write-Output "------------------------------------------------------------------"
Get-ADComputer -Filter 'Name -like $theComputer'
Write-Output "------------------------------------------------------------------"
}




