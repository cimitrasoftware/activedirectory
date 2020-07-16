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

if ($args[0]) { 
$context = $args[0]
}


function reverse
{ 
 $array = @(Get-ADUser  -Filter * -SearchBase $context)
 # [array]::reverse($array)
 $array
}
reverse