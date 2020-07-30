# Get a User's Account Information in Active Directory
# Author: Tay Kratzer tay@cimitra.com
# Get all information about all users: Get-ADUser -Properties * -Filter *
# Change the context variable to match your system
# -------------------------------------------------
$context = "OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com" 
 # - OR -
 # Specify the context in settings.cfg file
 # Use this format: AD_USER_CONTEXT=<ACTIVE DIRECTORY CONTEXT>
 # Example: AD_USER_CONTEXT=OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com
 # -------------------------------------------------

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


$firstNameInSet = $false
$lastNameInSet = $false
$contextInSet = $false
$setContextInSet = $false
$verboseOutputSet = $false
$modifyUserResult = $true
$sleepTime = 5

$firstNameIn = ([Regex]'(?is)(?:(?<=\-firstNameIn).+(?=-lastNameIn))').Match(($args -join "`n")).Value 

$firstNameIn = [string]::join(" ",($firstNameIn.Split("`n"))).Trim()

$firstNameIn = (Get-Culture).TextInfo.ToTitleCase($firstNameIn) 

if(Write-Output $args | Select-String '-contextIn'){
$lastNameIn = ([Regex]'(?is)(?:(?<=\-lastNameIn).+(?=-contextIn))').Match(($args -join "`n")).Value 
}else{
    if(Write-Output $args | Select-String '-lastNameIn'){
        $theArgs = $MyInvocation.Line
        $lastNameIn = $theArgs  -split "(?<=-lastNameIn)\s" | Select -Skip 1 -First 1
        $lastNameIn = (Get-Culture).TextInfo.ToTitleCase($lastNameIn)
        }
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

if($contextIn.Length -gt 2){
$contextInSet = $true
}



# Show Help
function ShowHelp{
$scriptName = Split-Path -leaf $PSCommandpath
Write-Host ""
Write-Host "Get User Information From Active Directory Account"
Write-Host ""
Write-Host "[ HELP ]"
Write-Host ""
Write-Host ".\$scriptName -h or -help"
Write-Host ""
Write-Host "[ SCRIPT USAGE ]"
Write-Host ""
Write-Host ".\$scriptName -firstNameIn <user first name> -lastNameIn <user last name> -contextIn <Active Directory context (optional if specified in settings.cfg)>"
Write-Host ""
Write-Host "[ EXAMPLES ]"
Write-Host ""
Write-Host "Example: .\$scriptName -firstNameIn Jane -lastNameIn Doe"
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host "Example: .\$scriptName -setContext OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com -firstNameIn Jane -lastNameIn Doe"
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host "Example: .\$scriptName -firstNameIn Jane -lastNameIn Doe -contextIn OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com"
Write-Host ""
Write-Host "[ ERROR HANDLING ]"
Write-Host ""
Write-Host "-showErrors = Show Error Messages"
Write-Host ""
Write-Host "Example: .\$scriptName -showErrors -firstNameIn Jane -lastNameIn Doe"
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

# -------------------------------------------------


# If a fourth argument is sent into this script, that fourth argument will be mapped to the $context variable

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

# User Name
# Title
# Department
# Description
# Office Phone
# Mobile Phone
# Expire Date
# Account Status: Enabled/Disabled
# Creation Date
# User samAccountName
# User CN Name
# User 


try{
Enable-ADAccount -Identity "CN=${firstNameIn} ${lastNameIn},$context" 2>&1 | out-null 
 }catch{
 $modifyUserResult = $false
 $err = "$_"
 }

 if (!($modifyUserResult)){
 Write-Output ""
 Write-Output "Cannot Get User Info for: ${firstNameIn} ${LastNameIn}"
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

# User Name
# Title
# Department
# Description
# Office Phone
# Mobile Phone
# Expire Date
# Account Status: Enabled/Disabled
# Creation Date
# User samAccountName
# User CN Name
# User 


$theMobilePhone=""
$theTitle=""
$theDepartment=""
$theDescription=""
$theOfficePhone=""
$theMobilePhone=""
$theExpireDate=""
$theAccountStatus=""
$thePasswordSetDate=""
$theCreationDate=""
$theUserSamAccounName=""
$theUserCnName=""



Write-Output ""
Write-Output "FULL NAME: ${firstNameIn} ${LastNameIn}"

try{
 $theTitle=Get-ADUser  -properties title -Identity "CN=${firstNameIn} ${lastNameIn},$context" | select title -ExpandProperty title
}catch{}

if($theTitle.Length -gt 0){
Write-Output "TITLE: $theTitle"
}else{
Write-Output "TITLE: [NONE]"
}

try{
 $theDepartment=Get-ADUser  -properties department -Identity "CN=${firstNameIn} ${lastNameIn},$context" | select department -ExpandProperty department 
}catch{}

if($theDepartment.Length -gt 0){
Write-Output "DEPARTMENT: $theDepartment"
}else{
Write-Output "DEPARTMENT: [NONE]"
}

try{
 $theDescription=Get-ADUser  -properties description -Identity "CN=${firstNameIn} ${lastNameIn},$context" | select description -ExpandProperty department 
}catch{}

if($theDescription.Length -gt 0){
Write-Output "DESCRIPTION: $theDescription"
}else{
Write-Output "DESCRIPTION: [NONE]"
}

try{
 $theOfficePhone=Get-ADUser  -properties OfficePhone -Identity "CN=${firstNameIn} ${lastNameIn},$context" | select OfficePhone -ExpandProperty OfficePhone 
}catch{}

if($OfficePhone.Length -gt 0){
Write-Output "OFFICE PHONE: $OfficePhone"
}else{
Write-Output "OFFICE PHONE: [NONE]"
}

try{
 $theMobilePhone=Get-ADUser  -properties MobilePhone -Identity "CN=${firstNameIn} ${lastNameIn},$context" | select MobilePhone -ExpandProperty MobilePhone 
}catch{}

if($theMobilePhone.Length -gt 0){
Write-Output "MOBILE PHONE: $theMobilePhone"
}else{
Write-Output "MOBILE PHONE: [NONE]"
}

try{
 $theExpirationDate=Get-ADUser  -properties AccountExpirationDate -Identity "CN=${firstNameIn} ${lastNameIn},$context" | select AccountExpirationDate -ExpandProperty AccountExpirationDate 
}catch{}

if($theExpirationDate.Length -gt 2){
Write-Output "ACCOUNT EXPIRES: $theExpirationDate"
}else{
Write-Output "ACCOUNT EXPIRES: [NONE]"
}

try{
 $thePasswordSetDate=Get-ADUser -properties PasswordLastSet -Identity "CN=${firstNameIn} ${lastNameIn},$context" | select PasswordLastSet -ExpandProperty PasswordLastSet 
}catch{}


if($thePasswordSetDate.Length -gt 0){
Write-Output "PASSWORD SET DATE: $thePasswordSetDate"
}else{
Write-Output "PASSWORD SET DATE: [NONE]"
}


try{
 $theAccountStatus=Get-ADUser  -properties Enabled -Identity "CN=${firstNameIn} ${lastNameIn},$context" | select Enabled -ExpandProperty Enabled 
}catch{}


Write-Output "ACCOUNT ENABLED: $theAccountStatus"

try{
 $theCreationDate=Get-ADUser  -properties Created -Identity "CN=${firstNameIn} ${lastNameIn},$context" | select Created -ExpandProperty Created 
}catch{}

try{
 $theUserSamAccounName=Get-ADUser  -properties SamAccountName -Identity "CN=${firstNameIn} ${lastNameIn},$context" | select SamAccountName -ExpandProperty SamAccountName 
}catch{}


Write-Output "SamAccountName: $theUserSamAccounName"

try{
 $DN=Get-ADUser  -properties DistinguishedName -Identity "CN=${firstNameIn} ${lastNameIn},$context" | select DistinguishedName -ExpandProperty DistinguishedName 
}catch{}


Write-Output "DISTINGUISHED NAME: $DN"


Write-Output ""