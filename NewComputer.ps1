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
$computerTypeInSet = $false
$contextInSet = $false
$setContextInSet = $false
$verboseOutputSet = $false
$createComputerResult = $true
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


$computerNameIn = ([Regex]'(?is)(?:(?<=\-computerNameIn).+(?=-computerTypeIn))').Match(($args -join "`n")).Value 

$computerNameIn = [string]::join(" ",($computerNameIn.Split("`n"))).Trim()

if(Write-Output $args | Select-String '-contextIn'){
$computerTypeIn = ([Regex]'(?is)(?:(?<=\-computerTypeIn).+(?=-contextIn))').Match(($args -join "`n")).Value 
}else{
$theArgs = $MyInvocation.Line
$computerTypeIn = $theArgs  -split "(?<=-computerTypeIn)\s" | Select -Skip 1 -First 1
}


if(Write-Output $args | Select-String '-contextIn'){
$theArgs = $MyInvocation.Line
$contextIn = $theArgs  -split "(?<=-contextIn)\s" | Select -Skip 1 -First 1
$contextInSet = $true
}

if (Write-Output "$args" | Select-String -CaseSensitive "-showErrors" ){
$verboseOutputSet = $true
}

if($computerNameIn.Length -gt 2){
$computerNameInSet = $true
}

if($computerTypeIn.Length -gt 0){
$computerTypeInSet = $true
}

if($contextIn.Length -gt 2){
$contextInSet = $true
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
Write-Host ".\$scriptName -computerNameIn <ComputerName> -computerTypeIn <Computer Type 1=Mac, 2=Windows, 3=Linux, 4=Linux, 5=Other> -contextIn <Active Directory context (optional if specified in settings.cfg)>"
Write-Host ""
Write-Host "[ EXAMPLES ]"
Write-Host ""
Write-Host "Example: .\$scriptName -computerNameIn WIN10BOX_ONE -computerTypeIn 2"
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host "Example: .\$scriptName -setContext OU=COMPUTERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com -computerNameIn WIN10BOX_ONE -computerTypeIn 2"
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host "Example: .\$scriptName -computerNameIn WIN10BOX_ONE -computerTypeIn 2 -contextIn OU=COMPUTERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com"
Write-Host ""
Write-Host "[ ERROR HANDLING ]"
Write-Host ""
Write-Host "-showErrors = Show Error Messages"
Write-Host ""
Write-Host "Example: .\$scriptName -showErrors -computerNameIn WIN10BOX_ONE -computerTypeIn 2 -contextIn OU=COMPUTERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com"
Write-Host ""
exit 0
}

if (Write-Output $args | Select-String "\-h\b|\-help\b" )
{
ShowHelp
}


if (!($computerNameInSet -and $computerTypeInSet)){
ShowHelp
}

function CALL_SLEEP{
Write-Output ""
Write-Output "Pausing for $sleepTime Seconds"
Write-Output ""
Start-Sleep -s $sleepTime
}

# Correlate the number to a word with a switch statement
switch ($computerTypeIn)
{

    1 {$ComputerType = 'MacOS'}
    2 {$ComputerType = 'Windows'}
    3 {$ComputerType = 'Chromebook'}
    4 {$ComputerType = 'Linux'}
    5 {$ComputerType = 'Other'}
    default{$ComputerType = 'MacOS'}

}

if ($contextInSet) { 
$context = $contextIn
Write-Output ""
Write-Output "Create Computer in Context: $context"
}

# Add the Computer to Active Directory
try{
# Create the computer in the AD context and   
New-ADComputer $computerNameIn -Path $context 
}catch{
# If the action of creating the computer has an error, assign the error message to the $err variable
$createComputerResult = $false
$err = "$_"
}


# If good result, display success, and update the OS

if ($createComputerResult)
{
# Pause to let AD update properly
Write-Output ""
Write-Output ""
Write-Output "The Computer: $computerNameIn was created in Active Directory"
# Pause to let AD update properly
CALL_SLEEP
Set-ADComputer -OperatingSystem "${ComputerType}" -Identity "CN=$computerNameIn,$context"
Write-Output "Computer Type = ${ComputerType}"
# Pause to let AD update properly
CALL_SLEEP
Write-Output "------------------------------------------------------------------"
Get-ADComputer -Filter 'Name -like $computerNameIn'
Write-Output "------------------------------------------------------------------"
}else{
# Report the error condition
Write-Output ""
Write-Output ""
Write-Output "The Computer: $computerNameIn was NOT created in Active Directory"
Write-Output ""
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




