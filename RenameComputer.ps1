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

$computerNameInSet = $false
$newComputerNameInSet = $false
$contextInSet = $false
$verboseOutputSet = $false
$global:renameComputerResult = $true

$sleepTime = 5

# Look to see if a config_reader.ps1 file exists in order to use it's functionality
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

$computerNameIn = ([Regex]'(?is)(?:(?<=\-computerNameIn).+(?=-newComputerNameIn))').Match(($args -join "`n")).Value 

$computerNameIn = [string]::join(" ",($computerNameIn.Split("`n"))).Trim()


if(Write-Output $args | Select-String '-contextIn'){
$newComputerNameIn = ([Regex]'(?is)(?:(?<=\-newComputerNameIn).+(?=-contextIn))').Match(($args -join "`n")).Value
$newComputerNameIn = [string]::join(" ",($newComputerNameIn.Split("`n"))).Trim() 
}else{
$theArgs = $MyInvocation.Line
$newComputerNameIn = $theArgs  -split "(?<=-newComputerNameIn)\s" | Select -Skip 1 -First 1
$newComputerNameIn = [string]::join(" ",($newComputerNameIn.Split("`n"))).Trim()
}

if(Write-Output $args | Select-String '-contextIn'){
$theArgs = $MyInvocation.Line
$contextIn = $theArgs  -split "(?<=-contextIn)\s" | Select -Skip 1 -First 1
}

if (Write-Output "$args" | Select-String -CaseSensitive "-showErrors" ){
$verboseOutputSet = $true
}


if($computerNameIn.Length -gt 2){
$computerNameInSet = $true
}


if($newComputerNameIn.Length -gt 2){
$newComputerNameInSet = $true
}

if($contextIn.Length -gt 2){
$contextInSet = $true
}


# Show Help
function ShowHelp{
$scriptName = Split-Path -leaf $PSCommandpath
Write-Host ""
Write-Host "Help"
Write-Host ""
Write-Host ".\$scriptName -h or -help"
Write-Host ""
Write-Host "Script Usage"
Write-Host ""
Write-Host ".\$scriptName -computerNameIn <current computer name> -newComputerNameIn <new computer name> -contextIn <Active Directory context (optional if specified otherwise)>"
Write-Host ""
Write-Host "Example: .\$scriptName -computerNameIn WIN7BOX -newComputerNameIn WIN10BOX"
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host "Example: .\$scriptName -computerNameIn WIN7BOX -newComputerNameIn WIN10BOX -contextIn OU=COMPUTERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com"
Write-Host ""
Write-Host "-showErrors = Show Error Messages"
Write-Host ""
Write-Host "Example: .\$scriptName -showErrors -computerNameIn WIN7BOX -newComputerNameIn WIN10BOX -contextIn OU=COMPUTERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com"
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


try{
Rename-ADObject -Identity "CN=$computerNameIn,$context" -NewName "$newComputerNameIn"  
}catch{
$global:renameComputerResult = $false
$err = "$_"
}

if ($renameComputerResult)
{
Write-Output "--------------------------------------------------------"
Write-Output ""
Write-Output "The Computer: $computerNameIn was renamed to $newComputerNameIn"
Write-Output ""
Write-Output "--------------------------------------------------------"

}else{
Write-Output "--------------------------------------------------------"
Write-Output ""
Write-Output "The Computer: $computerNameIn was NOT renamed to $newComputerNameIn"
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