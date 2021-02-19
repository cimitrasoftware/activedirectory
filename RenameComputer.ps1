# Rename a Computer in Active Directory
# Author: Tay Kratzer tay@cimitra.com
# Change the context variable to match your system
# Modify Date: 2/18/2021
# -------------------------------------------------

Param(
    [string] $ComputerNameIn,
    [string] $NewComputerNameIn,
    [string] $ContextIn,
    [switch] $ShowErrors
 )


$context = "OU=COMPUTERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com" 
 # - OR -
 # Specify the context in settings.cfg file
 # Use this format: AD_COMPUTER_CONTEXT=<ACTIVE DIRECTORY CONTEXT>
 # Example: AD_COMPUTER_CONTEXT=OU=COMPUTERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com
 # -------------------------------------------------

$computerNameInSet = $false
$newComputerNameInSet = $false
$verboseOutputSet = $false
$global:renameComputerResult = $true

$sleepTime = 5

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

if ($sleepTimeTest = "$CONFIG$AD_SCRIPT_SLEEP_TIME"){
$sleepTime = "$CONFIG$AD_SCRIPT_SLEEP_TIME"
}

}

}

$computerNameIn = $ComputerNameIn

$computerNameIn = [string]::join(" ",($computerNameIn.Split("`n"))).Trim()

$newComputerNameIn = $NewComputerNameIn

$newComputerNameIn = [string]::join(" ",($newComputerNameIn.Split("`n"))).Trim() 

if ($ShowErrors){
$verboseOutputSet = $true
}


if($computerNameIn.Length -gt 2){
$computerNameInSet = $true
}


if($newComputerNameIn.Length -gt 2){
$newComputerNameInSet = $true
}

$ContextInEmpty = [string]::IsNullOrWhiteSpace($ContextIn)

if($ContextInEmpty){
$contextIn = $context
}else{
$contextIn = $ContextIn
}



# Show Help
function ShowHelp{
$scriptName = Split-Path -leaf $PSCommandpath
Write-Host ""
Write-Host "Rename Computer in Active Directory"
Write-Host ""
Write-Host "[ HELP ]"
Write-Host ""
Write-Host ".\$scriptName -h or -help"
Write-Host ""
Write-Host "[ SCRIPT USAGE ]"
Write-Host ""
Write-Host ".\$scriptName -ComputerNameIn <current computer name> -NewComputerNameIn <new computer name> -ContextIn <Active Directory context (optional if specified in settings.cfg file)>"
Write-Host ""
Write-Host "[ EXAMPLES ]"
Write-Host ""
Write-Host "Example: .\$scriptName -ComputerNameIn WIN7BOX -NewComputerNameIn WIN10BOX"
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host "Example: .\$scriptName -ComputerNameIn WIN7BOX -NewComputerNameIn WIN10BOX -ContextIn OU=COMPUTERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com"
Write-Host ""
Write-Host "[ ERROR HANDLING ]"
Write-Host ""
Write-Host "-ShowErrors = Show Error Messages"
Write-Host ""
Write-Host ""
Write-Host "Example: .\$scriptName -ShowErrors -ComputerNameIn WIN7BOX -NewComputerNameIn WIN10BOX -ContextIn OU=COMPUTERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com"
Write-Host ""
exit 0
}

if (Write-Output $args | Select-String "\-h\b|\-help\b" )
{
ShowHelp
}

if (!($computerNameInSet -and $newComputerNameInSet)){
ShowHelp
}


if($contextIn.Length -lt 3){
ShowHelp
}



try{
Rename-ADObject -Identity "CN=$computerNameIn,$contextIn" -NewName "$newComputerNameIn"  
}catch{
$global:renameComputerResult = $false
$err = "$_"
}

if ($renameComputerResult)
{
Write-Output "--------------------------------------------------------"
Write-Output ""
Write-Output "The Computer: $computerNameIn | Was Renamed to $newComputerNameIn"
Write-Output ""
Write-Output "--------------------------------------------------------"

}else{
Write-Output "--------------------------------------------------------"
Write-Output ""
Write-Output "The Computer: $computerNameIn | Was NOT Renamed to $newComputerNameIn"
Write-Output ""
Write-Output "--------------------------------------------------------"


    if ($verboseOutputSet){
    Write-Output "[ERROR MESSAGE BELOW]"
    Write-Output "-----------------------------"
    Write-Output ""
    Write-Output $err
    Write-Output ""
    Write-Output "-----------------------------"
    }


}