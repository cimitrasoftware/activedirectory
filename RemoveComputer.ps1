# Remove a computer from Active Directory
# Author: Tay Kratzer tay@cimitra.com
# Change the context variable to match your system
# Modify Date: 2/18/2021
# -------------------------------------------------

# Get the -ContextIn parameter
Param(
    [string] $ComputerNameIn,
    [string] $ContextIn,
    [switch] $ShowErrors
 )


$context = "OU=COMPUTERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com" 

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

# Map the $context variable to the AD_COMPUTER_CONTEXT variable read in from the settings.cfg file
if ($contextTest = "$CONFIG$AD_COMPUTER_CONTEXT"){
$context = "$CONFIG$AD_COMPUTER_CONTEXT"
}

}

}

$computerNameInSet = $false
$contextInSet = $false
$setContextInSet = $false
$verboseOutputSet = $false
$deleteComputerResult = $true


$theComputer = $ComputerNameIn

$ContextInEmpty = [string]::IsNullOrWhiteSpace($ContextIn)

if($ContextInEmpty){
$contextIn = $context
}else{
$contextIn = $ContextIn
}

if($contextIn.Length -lt 3){
ShowHelp
}



if($theComputer.Length -gt 2){
$computerNameInSet = $true
}

if ($ShowErrors){
$verboseOutputSet = $true
}



# Show Help
function ShowHelp{
$scriptName = Split-Path -leaf $PSCommandpath
Write-Host ""
Write-Host "Remove a Computer From Active Directory"
Write-Host ""
Write-Host "[ HELP ]"
Write-Host ""
Write-Host ".\$scriptName -h or -help"
Write-Host ""
Write-Host "[ SCRIPT USAGE ]"
Write-Host ""
Write-Host ".\$scriptName -ComputerNameIn <current computer name> -ContextIn <Active Directory context (optional if specified in settings.cfg)>"
Write-Host ""
Write-Host "[ EXAMPLES ]"
Write-Host ""
Write-Host "Example: .\$scriptName -ComputerNameIn WIN7BOX"
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host "Example: .\$scriptName -ComputerNameIn WIN7BOX -ContextIn OU=COMPUTERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com"
Write-Host ""
Write-Host "[ ERROR HANDLING ]"
Write-Host ""
Write-Host "-ShowErrors = Show Error Messages"
Write-Host ""
Write-Host "Example: .\$scriptName -ShowErrors -ComputerNameIn WIN7BOX"
Write-Host ""
exit 0
}

if (Write-Output $args | Select-String "\-h\b|\-help\b" )
{
ShowHelp
}

if($contextIn.Length -lt 3){
ShowHelp
}



# This script expects 1 argument
if (!( $computerNameInSet )){ 
ShowHelp
 }
# -------------------------------------------------

# Invoke-Expression, that was a find! I wanted to be able to capture all output, and Invoke-Expression was key!

$TempFile = New-TemporaryFile 

$COMPUTER_DETAILS = Invoke-Expression 'Get-ADComputer "CN=$theComputer,$contextIn" -Properties *' 2>$TempFile

# Use Remove-ADComputer to remove the computer
try{
Remove-ADComputer  -Identity "CN=$theComputer,$contextIn" -Confirm:$False
}catch{
$deleteComputerResult = $false
$err = "$_"
}


if($deleteComputerResult)
{
Write-Output ""
Write-Output "------------------------------------------------------------------"
Write-Output ""
Write-Output "The Computer: $theComputer was removed from Active Directory"
Write-Output ""
Write-Output "------------------------------------------------------------------"
Write-Output "Computer Object Details"
Write-Output "------------------------------------------------------------------"
$COMPUTER_DETAILS
    if ($verboseOutputSet){
    if(Test-Path $TempFile -PathType Leaf){
    Get-Content  "$TempFile"
    }
    }

Write-Output "------------------------------------------------------------------"
}else{
Write-Output ""
Write-Output "------------------------------------------------------------------"
Write-Output ""
Write-Output "The Computer: $theComputer was NOT removed from Active Directory"
Write-Output ""
Write-Output "------------------------------------------------------------------"

    if ($verboseOutputSet){
    Write-Output "[ERROR MESSAGE BELOW]"
    Write-Output "-----------------------------"
    Write-Output ""
    Write-Output $err
    Write-Output ""
    Write-Output "-----------------------------"
    }

}

# Get rid of the Temporary File
if(Test-Path $TempFile -PathType Leaf){
Remove-Item "$TempFile"
}

