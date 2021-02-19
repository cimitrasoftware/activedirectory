# Author: Tay Kratzer tay@cimitra.com
# Change the context variable to match your system
# Modify Date: 2/18/2021
# -------------------------------------------------

# Get the -ContextIn parameter
Param(
    [string] $ComputerNameIn,
    [string] $ComputerTypeIn,
    [string] $DefaultComputerType,
    [string] $ContextIn,
    [switch] $ShowErrors
 )

# -------------------------------------------------
$context = "OU=COMPUTERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com" 
 # - OR -
 # Specify the context in settings.cfg file
 # Use this format: AD_COMPUTER_CONTEXT=<ACTIVE DIRECTORY CONTEXT>
 # Example: AD_COMPUTER_CONTEXT=OU=COMPUTERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com
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

# Map the $context variable to the AD_COMPUTER_CONTEXT variable read in from the settings.cfg file
if ($contextTest = "$CONFIG$AD_COMPUTER_CONTEXT"){
$context = "$CONFIG$AD_COMPUTER_CONTEXT"
}

}

}

$computerNameInSet = $false
$computerTypeInSet = $false
$contextInSet = $false
$verboseOutputSet = $false
$createComputerResult = $true
$sleepTime = 5

$computerNameIn = $ComputerNameIn 



$ContextInEmpty = [string]::IsNullOrWhiteSpace($ContextIn)

if($ContextInEmpty){
$contextIn = $context
}else{
$contextIn = $ContextIn
}


if ($ShowErrors){
$verboseOutputSet = $true
}

if($computerNameIn.Length -gt 2){
$computerNameInSet = $true
}


$ComputerTypeInEmpty = [string]::IsNullOrWhiteSpace($ComputerTypeIn)

$DefaultComputerTypeEmpty = [string]::IsNullOrWhiteSpace($DefaultComputerType)

if($ComputerTypeInEmpty){

if($DefaultComputerTypeEmpty){
$ComputerTypeIn = '1'
}

}



# Show Help
function ShowHelp{
$scriptName = Split-Path -leaf $PSCommandpath
Write-Host ""
Write-Host "Create Computer in Active Directory"
Write-Host ""
Write-Host "[ HELP ]"
Write-Host ""
Write-Host ".\$scriptName -h or -help"
Write-Host ""
Write-Host "[ SCRIPT USAGE ]"
Write-Host ""
Write-Host ".\$scriptName -ComputerNameIn <ComputerName> -ComputerTypeIn <Computer Type 1=Mac, 2=Windows, 3=Linux, 4=Linux, 5=Other> -ContextIn <Active Directory context (optional if specified in settings.cfg)>"
Write-Host ""
Write-Host "[ EXAMPLES ]"
Write-Host ""
Write-Host "Example: .\$scriptName -ComputerNameIn WIN10BOX-ONE -ComputerTypeIn 2"
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host "Example: .\$scriptName -ComputerNameIn WIN10BOX-ONE -ComputerTypeIn 2 -ContextIn OU=COMPUTERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com"
Write-Host ""
Write-Host "[ ERROR HANDLING ]"
Write-Host ""
Write-Host "-ShowErrors = Show Error Messages"
Write-Host ""
Write-Host "Example: .\$scriptName -ShowErrors -ComputerNameIn WIN10BOX-ONE -ComputerTypeIn 2 -ContextIn OU=COMPUTERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com"
Write-Host ""
exit 0
}

if (Write-Output $args | Select-String "\-h\b|\-help\b" )
{
ShowHelp
}


if (!($computerNameInSet)){
ShowHelp
}

if($contextIn.Length -lt 3){
ShowHelp
}



function Test-WindowsTerminal { test-path env:WT_SESSION }


function CALL_SLEEP{
if($env:WT_SESSION){
Write-Output ""
Write-Output "Pausing for $sleepTime Seconds"
Write-Output ""
}
Start-Sleep -s $sleepTime
}

# Correlate the number to a word with a switch statement
switch ($ComputerTypeIn)
{

    1 {$ComputerType = 'MacOS'}
    2 {$ComputerType = 'Windows'}
    3 {$ComputerType = 'Chromebook'}
    4 {$ComputerType = 'Linux'}
    5 {$ComputerType = 'Other'}
    default{$ComputerType = 'MacOS'}

}


# Add the Computer to Active Directory
try{
# Create the computer in the AD context and   
New-ADComputer $computerNameIn -Path $contextIn -OperatingSystem "${ComputerTypeIn}"
}catch{
# If the action of creating the computer has an error, assign the error message to the $err variable
$createComputerResult = $false
$err = "$_"
}


# If good result, display success, and update the OS

if ($createComputerResult)
{
# Pause to let AD update properly
Write-Host ""
Write-Output "The Computer: $computerNameIn was created in Active Directory"
# Pause to let AD update properly
Write-Output "Computer Type = ${ComputerType}"
# Pause to let AD update properly
CALL_SLEEP
Write-Output "------------------------------------------------------------------"
Get-ADComputer -Filter 'Name -like $computerNameIn' -Properties *
Write-Output "------------------------------------------------------------------"
}else{
# Report the error condition
Write-Output "The Computer: $computerNameIn was NOT created in Active Directory"
# If the -showErrors switch is used, show the error captured earlier
    if ($verboseOutputSet){
    Write-Output "[ERROR MESSAGE BELOW]"
    Write-Output "-----------------------------"
    Write-Output ""
    Write-Output $err
    Write-Output ""
    Write-Output "-----------------------------"
    }

}




