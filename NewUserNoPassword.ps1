# Check Password Set Date in Active Directory
# Author: Tay Kratzer tay@cimitra.com
# Change the context variable to match your system
# -------------------------------------------------
$context = "OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com" 
 # - OR -
 # Specify the context in settings.cfg file
 # Use this format: AD_USER_CONTEXT=<ACTIVE DIRECTORY CONTEXT>
 # Example: AD_USER_CONTEXT=OU=COMPUTERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com
 # -------------------------------------------------

# If a settings.cfg file exists read it and get the Active Directory Context from this file
if((Test-Path ${PSScriptRoot}\config_reader.ps1)){

if((Test-Path ${PSScriptRoot}\settings.cfg))
{
$CONFIG_IO="${PSScriptRoot}\config_reader.ps1"

. $CONFIG_IO

$CONFIG=(ReadFromConfigFile "${PSScriptRoot}\settings.cfg")

$context = "$CONFIG$AD_USER_CONTEXT"
}

}


# Show Help
function ShowHelp{
$scriptName = Split-Path -leaf $PSCommandpath
Write-Host ""
Write-Host "Script Usage"
Write-Host ""
Write-Host ".\$scriptName <user first name> <user last name> <Active Directory context (optional if specified otherwise)>"
Write-Host ""
Write-Host "Example: .\$scriptName Jamie Smith"
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host "Example: .\$scriptName Jamie Smith OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com"
Write-Host ""
exit 0
}

if (!$args[1]){ 
ShowHelp
 }
# -------------------------------------------------


if ($args[2]) { 

$context = $args[2]

}

# Get the first command-line variable
$firstNameIn=$args[0]
# Make sure the first character is uppercased
$firstNameIn = (Get-Culture).TextInfo.ToTitleCase($firstNameIn)
# Get the second command-line variable
$lastNameIn=$args[1]
# Make sure the first character is uppercased
$lastNameIn = (Get-Culture).TextInfo.ToTitleCase($lastNameIn)
# Make the samAccountName variable from a combination of the user's first and last name
$samAccountName = ($firstNameIn+$lastNameIn).ToLower()
# Default password
$password = 'Changeme_123'

New-ADUser -Name "$firstNameIn $lastNameIn" -GivenName "$firstNameIn" -Surname "$lastNameIn" -SamAccountName "$samAccountName" -AccountPassword (ConvertTo-SecureString "$password" -AsPlainText -force) -passThru -path "$context"
$theResult = $?

# If good result, display success message
if ($theResult)
{
Write-Output ""
Write-Output ""
Write-Output "New User ${firstNameIn} ${lastNameIn} created in Active Directory"
}

Enable-ADAccount -Identity "CN=$firstNameIn $lastNameIn,$context" -Confirm:$False

Set-ADUser -Identity  "CN=$firstNameIn $lastNameIn,$context" -ChangePasswordAtLogon $true