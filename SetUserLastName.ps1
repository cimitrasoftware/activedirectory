# Change a User's Last Name in Active Directory
# Author: Tay Kratzer tay@cimitra.com
# Change the context variable to match your system
# -------------------------------------------------
$context = "OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com" 
 # - OR -
 # Specify the context in settings.cfg file
 # Use this format: AD_USER_CONTEXT=<ACTIVE DIRECTORY CONTEXT>
 # Example: AD_USER_CONTEXT=OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com
 # -------------------------------------------------

$firstNameInSet = $false
$lastNameInSet = $false
$newLastnameInSet = $false
$newSamNameInSet = $false
$contextInSet = $false
$setContextInSet = $false
$verboseOutputSet = $false
$modifyUserResult = $true
$sleepTime = 5



$firstNameIn = ([Regex]'(?is)(?:(?<=\-firstNameIn).+(?=-lastNameIn))').Match(($args -join "`n")).Value 

$firstNameIn = [string]::join(" ",($firstNameIn.Split("`n"))).Trim()

$firstNameIn = (Get-Culture).TextInfo.ToTitleCase($firstNameIn) 

$lastNameIn = ([Regex]'(?is)(?:(?<=\-lastNameIn).+(?=-newLastNameIn))').Match(($args -join "`n")).Value 

$lastNameIn = [string]::join(" ",($lastNameIn.Split("`n"))).Trim() 

$lastNameIn = (Get-Culture).TextInfo.ToTitleCase($lastNameIn) 

# New Last Name

$newLastNameIn = ([Regex]'(?is)(?:(?<=\-newLastNameIn).+(?=-newSamNameIn))').Match(($args -join "`n")).Value 

$newLastNameIn = [string]::join(" ",($newLastNameIn.Split("`n"))).Trim() 

$newLastNameIn = (Get-Culture).TextInfo.ToTitleCase($newLastNameIn) 

# New SamAccountName

if(Write-Output $args | Select-String '-contextIn'){
$newSamNameIn = ([Regex]'(?is)(?:(?<=\-newSamNameIn).+(?=-contextIn))').Match(($args -join "`n")).Value 
$newSamNameIn = [string]::join(" ",($newSamNameIn.Split("`n"))).Trim() 
}else{
[string]$commandLineIn = $args
$newSamNameIn = $commandLineIn -split "(?<=-newSamNameIn)\s" | Select -Skip 1 -First 1
$newSamNameIn = [string]::join(" ",($newSamNameIn.Split("`n"))).Trim() 
}


if(Write-Output $args | Select-String '-contextIn'){
$theArgs = $MyInvocation.Line
$contextIn = $theArgs  -split "(?<=-contextIn)\s" | Select -Skip 1 -First 1
}

if (Write-Output "$args" | Select-String -CaseSensitive "-showErrors" ){
$verboseOutputSet = $true
}

if($firstNameIn.Length -gt 2){
$firstNameInSet = $true
}

if($lastNameIn.Length -gt 2){
$lastNameInSet = $true
}

if($newLastNameIn.Length -gt 2){
$newLastNameInSet = $true
}

if($newSamNameIn.Length -gt 2){
$newSamNameInSet = $true
}

if($contextIn.Length -gt 2){
$contextInSet = $true
}


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

# Map the $context variable to the AD_USER_CONTEXT variable read in from the settings.cfg file
$context = "$CONFIG$AD_USER_CONTEXT"

if ($sleepTimeTest = "$CONFIG$AD_SCRIPT_SLEEP_TIME"){
$sleepTime = "$CONFIG$AD_SCRIPT_SLEEP_TIME"
}

}

}

function CALL_SLEEP{
Write-Output ""
Write-Output "Pausing for $sleepTime Seconds"
Write-Output ""
Start-Sleep -s $sleepTime
}


# Show Help
function ShowHelp{
$scriptName = Split-Path -leaf $PSCommandpath
Write-Host ""
Write-Host "Change a User's Last Name in Active Directory"
Write-Host ""
Write-Host "[ HELP ]"
Write-Host ""
Write-Host ".\$scriptName -h or -help"
Write-Host ""
Write-Host "[ SCRIPT USAGE ]"
Write-Host ""
Write-Host ".\$scriptName -firstNameIn <user first name> -lastNameIn <user last name> -newLastNameIn <new last name> -newSamNameIn <new SamAccountName> -contextIn <Active Directory context (optional if specified in settings.cfg)>"
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host ".\$scriptName -setContext <Active Directory context (optional if specified in settings.cfg)> -firstNameIn <user first name> -lastNameIn <user last name> -newLastNameIn <new last name> -newSamNameIn <new SamAccountName> "
Write-Host ""
Write-Host "[ EXAMPLES ]"
Write-Host ""
Write-Host "Example: .\$scriptName -firstNameIn Jane -lastNameIn Doe -newLastNameIn Smith -newSamNameIn jsmith"
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host "Example: .\$scriptName -setContext OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com -firstNameIn Jane -lastNameIn Doe -newLastNameIn Smith -newSamNameIn jsmith"
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host "Example: .\$scriptName -firstNameIn Jane -lastNameIn Doe -newLastNameIn Smith -newSamNameIn jsmith -contextIn OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com"
Write-Host ""
Write-Host "[ ERROR HANDLING ]"
Write-Host ""
Write-Host "-showErrors = Show Error Messages"
Write-Host ""
Write-Host "Example: .\$scriptName -showErrors -firstNameIn Jane -lastNameIn Doe -newLastNameIn Smith -newSamNameIn jsmith"
Write-Host ""
exit 0
}

if (Write-Output $args | Select-String "\-h\b|\-help\b" )
{
ShowHelp
}


if (!( $firstNameInSet -and $lastNameInSet -and $newLastNameInSet -and $newSamNameInSet )){ 
ShowHelp
 }
# -------------------------------------------------



if(Write-Output $args | Select-String '-setContext'){
$theArgs = $MyInvocation.Line
$setContextIn = $theArgs  -split "(?<=-setContext)\s" | Select -Skip 1 -First 1
}

if($setContextIn.Length -gt 2){
$setContextInSet = $true
}


if ($contextInSet){ 
    $context = $contextIn
    Write-Output ""
    Write-Output "Modify User in Context: $context"
}else{
    if($setContextInSet){
    $context = $setContextIn
    }
}


try{
$test = Get-ADUser -Identity "CN=${firstNameIn} ${lastNameIn},$context" 
}catch{
$modifyUserResult = $false
$err = "$_"
}

if (!($modifyUserResult))
{
Write-Output ""
Write-Output "Error: ${firstNameIn} ${lastNameIn} NOT changed in Active Directory"
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


# If exit code from the New-ADUser command was "True" then show a success message
if ($modifyUserResult)
{
Write-Output ""
Write-Output "-----------------------------"
Write-Output "User: ${firstNameIn} ${lastNameIn}"
Write-Output ""
Write-Output "Change To:"
Write-Output ""
write-output "User: ${firstNameIn} ${newLastNameIn}"
Write-Output "-----------------------------"
}else{
Write-Output "User: ${firstNameIn} ${lastNameIn} NOT changed in Active Directory"
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

# Modify the user


try{
Get-ADUser -Identity "CN=${firstNameIn} ${lastNameIn},$context"  | Rename-ADObject -NewName "${firstNameIn} ${newLastNameIn}" 
}catch{
$modifyUserResult = $false
$err = "$_"
}


# If exit code from the New-ADUser command was "True" then show a success message
if ($modifyUserResult)
{
Write-Output ""
Write-Output "User: ${firstNameIn} ${lastNameIn}"
Write-Output ""
Write-Output "Changed To:"
Write-Output ""
write-output "User: ${firstNameIn} ${newLastNameIn}"
}else{
Write-Output ""
Write-Output "User: ${firstNameIn} ${lastNameIn} NOT changed in Active Directory"
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

CALL_SLEEP

Write-Output "User Display Name: ${firstNameIn} ${lastNameIn}"
Write-Output ""
Write-Output "Change To:"
Write-Output ""
write-output "Display Name: ${firstNameIn} ${newLastNameIn}"
Write-Output ""
try{
Get-ADUser -Identity "CN=${firstNameIn} ${newLastNameIn},$context"  | Set-ADUser -Surname "${newLastNameIn}" -DisplayName "${firstNameIn} ${newLastNameIn}" -SamAccountName "${newSamNameIn}" 
}catch{
$modifyUserResult = $false
$err = "$_"
}

# If exit code from the New-ADUser command was "True" then show a success message
if ($modifyUserResult)
{
Write-Output ""
Write-Output "------------"
Write-Output "| SUCCESS! |"
Write-Output "------------"
Write-Output ""
}else{
Write-Output ""
Write-Output "ERROR: User: ${firstNameIn} ${newLastNameIn} display name NOT changed in Active Directory"
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


