# Check Password Set Date in Active Directory
# Author: Tay Kratzer tay@cimitra.com
# Change the context variable to match your system
# Modify Date: 2/18/2021
# -------------------------------------------------

Param(
    [string] $FirstNameIn,
    [string] $LastNameIn,
    [string] $ContextIn,
    [switch] $ShowErrors
 )

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


$firstNameInSet = $false
$lastNameInSet = $false
$verboseOutputSet = $false
$modifyUserResult = $true
$sleepTime = 5

$firstNameIn = $FirstNameIn
$lastNameIn = $LastNameIn

$firstNameIn = [string]::join(" ",($firstNameIn.Split("`n"))).Trim()
$lastNameIn = [string]::join(" ",($lastNameIn.Split("`n"))).Trim()

$firstNameIn = (Get-Culture).TextInfo.ToTitleCase($firstNameIn) 
$lastNameIn = (Get-Culture).TextInfo.ToTitleCase($lastNameIn)

 

$ContextInEmpty = [string]::IsNullOrWhiteSpace($ContextIn)


if($ContextInEmpty){
$contextIn = $context
}else{
$contextIn = $ContextIn
}

if ($ShowErrors){
$verboseOutputSet = $true
}


if($firstNameIn.Length -gt 2){
$firstNameInSet = $true
}

if($lastNameIn.Length -gt 2){
$lastNameInSet = $true
}


# Show Help
function ShowHelp{
$scriptName = Split-Path -leaf $PSCommandpath
Write-Host ""
Write-Host "Disable a User's Active Directory Account"
Write-Host ""
Write-Host "[ HELP ]"
Write-Host ""
Write-Host ".\$scriptName -h or -help"
Write-Host ""
Write-Host "[ SCRIPT USAGE ]"
Write-Host ""
Write-Host ".\$scriptName -FirstNameIn <user first name> -LastNameIn <user last name> -ContextIn <Active Directory context (optional if specified in settings.cfg)>"
Write-Host ""
Write-Host "[ EXAMPLES ]"
Write-Host ""
Write-Host "Example: .\$scriptName -FirstNameIn Jane -LastNameIn Doe"
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host "Example: .\$scriptName -ContextIn OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com -FirstNameIn Jane -LastNameIn Doe"
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host "Example: .\$scriptName -FirstNameIn Jane -LastNameIn Doe -ContextIn OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com"
Write-Host ""
Write-Host "[ ERROR HANDLING ]"
Write-Host ""
Write-Host "-ShowErrors = Show Error Messages"
Write-Host ""
Write-Host "Example: .\$scriptName -ShowErrors -FirstNameIn Jane -LastNameIn Doe"
Write-Host ""
exit 0
}

if (Write-Output $args | Select-String "\-h\b|\-help\b" )
{
ShowHelp
}

# This script expects 2 arguments
if (!( $firstNameInSet -and $lastNameInSet )){ 
ShowHelp
 }

 if($contextIn.Length -lt 3){
ShowHelp
}

# -------------------------------------------------


try{
Disable-ADAccount -Identity "CN=${firstNameIn} ${lastNameIn},$contextIn"  
 }catch{
 $modifyUserResult = $false
 $err = "$_"
 }

 if ($modifyUserResult){
 Write-Output "------------------------------------------------------------------------------"
 Write-Output ""
 Write-Output "Account Disabled for User: ${firstNameIn} ${lastNameIn}"
 Write-Output ""
 Write-Output "------------------------------------------------------------------------------"
 }else{
 Write-Output ""
 Write-Output "Account for User: ${firstNameIn} ${lastNameIn} NOT Disabled"
Write-Output ""
    if ($verboseOutputSet){
    Write-Output "[ERROR MESSAGE BELOW]"
    Write-Output "-----------------------------"
    Write-Output ""
    Write-Output $err
    Write-Output ""
    Write-Output "-----------------------------"
    }
exit

 }

 try{
 Set-ADUser -Identity "CN=${firstNameIn} ${lastNameIn},$contextIn" -Enabled $false  
 }catch{
 $modifyUserResult = $false
 $err = "$_"
 }

  if (!($modifyUserResult)){
 Write-Output ""
 Write-Output "Account for User: ${firstNameIn} ${lastNameIn} NOT Fully Disabled"
Write-Output ""
    if ($verboseOutputSet){
    Write-Output "[ERROR MESSAGE BELOW]"
    Write-Output "-----------------------------"
    Write-Output ""
    Write-Output $err
    Write-Output ""
    Write-Output "-----------------------------"
    }

 }




