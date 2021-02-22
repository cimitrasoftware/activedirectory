# Create a New User in Active Directory
# Author: Tay Kratzer tay@cimitra.com
# Change the context variable to match your system
# Modify Date: 2/18/2021
# -------------------------------------------------

# Get the -ContextIn parameter
Param(
    [string] $ContextIn,
    [string] $FullNameIn,
    [string] $DefaultPasswordIn,
    [switch] $RequirePasswordChange,
    [switch] $EnableAccount,
    [switch] $ShowErrors
 )
 
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

$createUserResult = $true


# Show Help
function ShowHelp{
$scriptName = Split-Path -leaf $PSCommandpath
Write-Host ""
Write-Host "Script Usage"
Write-Host ""
Write-Host ".\$scriptName -FullNameIn '<user first name> <user last name>' -ContextIn 
'<Active Directory context (optional if specified otherwise)>'"
Write-Host ""
Write-Host "Example: .\$scriptName -FullNameIn 'Jamie Smith'"
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host "Example: .\$scriptName -FullNameIn 'Jamie Smith' -ContextIn 'OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com'"
Write-Host ""
exit 0
}

$FullNameInEmpty = [string]::IsNullOrWhiteSpace($FullNameIn)

if($FullNameInEmpty){
ShowHelp
}
# -------------------------------------------------


$DefaultPasswordInEmpty = [string]::IsNullOrWhiteSpace($DefaultPasswordIn)

if($DefaultPasswordInEmpty){
$DefaultPasswordIn = 'abc_123_-00'
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



# Get the First Name
$firstNameIn = $FullNameIn.split(' ')[0]
# Make sure the first character is uppercased
$firstNameIn = (Get-Culture).TextInfo.ToTitleCase($firstNameIn)
# Get the Last Name
$lastNameIn = $FullNameIn.split(' ')[1]
# Make sure the first character is uppercased
$lastNameIn = (Get-Culture).TextInfo.ToTitleCase($lastNameIn)
# Make the samAccountName variable from a combination of the user's first and last name
$samAccountName = ($firstNameIn+$lastNameIn).ToLower()
# Default password
$password = $DefaultPasswordIn


# Create the new user
try{

New-ADUser -Name "$firstNameIn $lastNameIn" -GivenName "$firstNameIn" -Surname "$lastNameIn" -SamAccountName "$samAccountName" -AccountPassword (ConvertTo-SecureString "$password" -AsPlainText -force) -passThru -path "$contextIn" -Enabled $true | out-null

}catch{
$createUserResult = $false
$err = "$_"
}


# If exit code from the New-ADUser command was "True" then show a success message
if ($createUserResult)
{
Write-Output ""
Write-Output "New User: ${firstNameIn} ${lastNameIn} created in Active Directory"
Write-Output ""
}else{
Write-Output ""
Write-Output "User: ( ${firstNameIn} ${lastNameIn} ) was NOT created in Active Directory"
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



if($RequirePasswordChange){
Set-ADUser -Identity  "CN=$firstNameIn $lastNameIn,$contextIn" -ChangePasswordAtLogon $true
Write-Output ""
Write-Output "New User: ${firstNameIn} ${lastNameIn} Will Need to Change Their Password on Next Login"
Write-Output ""

}