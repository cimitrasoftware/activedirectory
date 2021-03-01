# Get User Info From Active Directory
# Author: Tay Kratzer tay@cimitra.com
# Change the context variable to match your system
# Modify Date: 2/18/2021
# -------------------------------------------------

Param(
    [string] $FirstNameIn,
    [string] $LastNameIn,
    [string] $ContextIn,
    [switch] $SearchForUser,
    [switch] $ShowErrors
 )

 Set-Variable -Name contextIn -Value "" -Option AllScope

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
Write-Host "Get User Information From Active Directory Account"
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
Write-Host "Example: .\$scriptName -FirstNameIn Jane -LastNameIn Doe -ContextIn OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com"
Write-Host ""
Write-Host "[ ERROR HANDLING ]"
Write-Host ""
Write-Host "-showErrors = Show Error Messages"
Write-Host ""
Write-Host "Example: .\$scriptName -showErrors -FirstNameIn Jane -LastNameIn Doe"
Write-Host ""
exit 0
}

if($contextIn.Length -lt 3){
ShowHelp
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

$theGivenName=""
$theSurname=""
$theMobilePhone=""
$theTitle=""
$theDepartment=""
$theDescription=""
$theOfficePhone=""
$theMobilePhone=""
$theExpirationDate=""
$global:theAccountStatus = $true
$thePasswordSetDate=""
$theCreationDate=""
$theUserSamAccounName=""
$theUserCnName=""


function  Get-DistinguishedName {
    param (
        [Parameter(Mandatory,
        ParameterSetName = 'Input')]
        [string[]]
        $CanonicalName,

        [Parameter(Mandatory,
            ValueFromPipeline,
            ParameterSetName = 'Pipeline')]
        [string]
        $InputObject
    )
    process {
        if ($PSCmdlet.ParameterSetName -eq 'Pipeline') {
            $arr = $_ -split '/'
            [array]::reverse($arr)
            $output = @()
            $output += $arr[0] -replace '^.*$', '$0'
            $output += ($arr | select -Skip 1 | select -SkipLast 1) -replace '^.*$', 'OU=$0'
            $output += ($arr | ? { $_ -like '*.*' }) -split '\.' -replace '^.*$', 'DC=$0'
            $output -join ','
        }
        else {
            foreach ($cn in $CanonicalName) {
                $arr = $cn -split '/'
                [array]::reverse($arr)
                $output = @()
                $output += $arr[0] -replace '^.*$', '$0'
                $output += ($arr | select -Skip 1 | select -SkipLast 1) -replace '^.*$', 'OU=$0'
                $output += ($arr | ? { $_ -like '*.*' }) -split '\.' -replace '^.*$', 'DC=$0'
                $output -join ','
            }
        }
    }
}



function SearchForUserName(){
$counterUp = 0
Write-Output "Searching For User With The Name [ $firstNameIn $lastNameIn ]"
Write-Output "-----------------------------------------------------------"
try{
@($theUser = Get-ADUser -Filter "Name -like '$firstNameIn $lastNameIn'" ) | Get-DistinguishedName
$UserName = $theUser.Name
$SamName = $theUser.sAMAccountName
$DistinguishedName = $theUser.distinguishedName
$CurrentUser = $theUser.distinguishedName
$global:actionResult = $true
if($UserName.Length -gt 2)
{
$counterUp++
}
}catch{
$err = "$_"
$global:err = $err
$global:actionResult = $false
}

if($counterUp -ne 1){
Write-Output "Could Not Positively Identify a Unique User: $firstNameIn $lastNameIn"
Write-Output ""

$SearchUtilityExists = Test-Path "$PSScriptRoot\SearchForUser.ps1"
if($SearchUtilityExists)
{
. $PSScriptRoot\SearchForUser.ps1 -FirstNameIn ${firstNameIn} -LastNameIn ${lastNameIn}
}
exit 0
}

if($counterUp -eq 1){
$samAccountNameIn = $SamName
$samAccountNameInSet = $true

$user = Get-ADUser -Identity $SamName -Properties CanonicalName
$contextIn = "OU="+($user.DistinguishedName -split ",OU=",2)[1]

}

}


function ValidateUser(){

try{
Get-ADUser -Identity "CN=${firstNameIn} ${lastNameIn},$contextIn" *> $null
}catch{
if($SearchForUser){
SearchForUserName
}else{
Write-Output "User | ${firstNameIn} ${lastNameIn} | Does Not Exist"
Write-Output ""
Write-Output "Searched For Fully Qualified Distinguished Name: CN=${firstNameIn} ${lastNameIn},$contextIn"
exit 0
}

}

}



ValidateUser


try{
 $theFirstName=Get-ADUser  -properties GivenName -Identity "CN=${firstNameIn} ${lastNameIn},$contextIn" | select GivenName -ExpandProperty GivenName
}catch{}


try{
 $theLastName=Get-ADUser  -properties Surname -Identity "CN=${firstNameIn} ${lastNameIn},$contextIn" | select Surname -ExpandProperty Surname
}catch{}


Write-Output "FULL NAME:  ${theFirstName} ${theLastName}"
Write-Output "FIRST NAME: ${theFirstName}"
Write-Output "LAST  NAME: ${theLastName}"

try{
 $theTitle=Get-ADUser  -properties title -Identity "CN=${firstNameIn} ${lastNameIn},$contextIn" | select title -ExpandProperty title
}catch{}

if($theTitle.Length -gt 0){
Write-Output "TITLE:  $theTitle"
}else{
Write-Output "TITLE:  [NONE]"
}


try{
 $theDepartment=Get-ADUser  -properties department -Identity "CN=${firstNameIn} ${lastNameIn},$contextIn" | select department -ExpandProperty department 
}catch{}

if($theDepartment.Length -gt 0){
Write-Output "DEPARTMENT:  $theDepartment"
}else{
Write-Output "DEPARTMENT:  [NONE]"
}


try{
 $theDescription=Get-ADUser  -properties description -Identity "CN=${firstNameIn} ${lastNameIn},$contextIn" | select description -ExpandProperty description
}catch{}

if($theDescription.Length -gt 0){
Write-Output "DESCRIPTION:  $theDescription"
}else{
Write-Output "DESCRIPTION:  [NONE]"
}


try{
 $theOfficePhone=Get-ADUser -properties OfficePhone -Identity "CN=${firstNameIn} ${lastNameIn},$contextIn" | select OfficePhone -ExpandProperty OfficePhone 
}catch{}

if($theOfficePhone.Length -gt 0){
Write-Output "OFFICE PHONE:  $theOfficePhone"
}else{
Write-Output "OFFICE PHONE:  [NONE]"
}


try{
 $theMobilePhone=Get-ADUser  -properties MobilePhone -Identity "CN=${firstNameIn} ${lastNameIn},$contextIn" | select MobilePhone -ExpandProperty MobilePhone 
}catch{}

if($theMobilePhone.Length -gt 0){
Write-Output "MOBILE PHONE:  $theMobilePhone"
}else{
Write-Output "MOBILE PHONE:  [NONE]"
}

Write-Output "GROUP MEMBERSHIP"
Write-Output "----------------------------------"
Get-ADPrincipalGroupMembership "CN=${firstNameIn} ${lastNameIn},$contextIn" | select name | ft -HideTableHeaders | where{$_ -ne ""}
Write-Output "----------------------------------"

try{
 $theExpirationDate=Get-ADUser -properties AccountExpirationDate -Identity "CN=${firstNameIn} ${lastNameIn},$contextIn" | select AccountExpirationDate -ExpandProperty AccountExpirationDate 
 }catch{}

if($theExpirationDate.Length -gt 0){
Write-Output "ACCOUNT EXPIRES:  $theExpirationDate"
}else{
Write-Output "ACCOUNT EXPIRES:  [NO EXPIRATION DATE]"
}


try{
 $thePasswordSetDate=Get-ADUser -properties PasswordLastSet -Identity "CN=${firstNameIn} ${lastNameIn},$contextIn" | select PasswordLastSet -ExpandProperty PasswordLastSet 
}catch{}


if($thePasswordSetDate.Length -gt 0){
Write-Output "PASSWORD SET DATE:  $thePasswordSetDate"
}else{
Write-Output "PASSWORD SET DATE:  [NONE]"
}


try{
 $theAccountStatus=Get-ADUser -properties Enabled -Identity "CN=${firstNameIn} ${lastNameIn},$contextIn" | select Enabled -ExpandProperty Enabled 
}catch{}

if($theAccountStatus){
Write-Output "ACCOUNT ENABLED:  YES"
}else{
Write-Output "ACCOUNT ENABLED:  NO"
}


try{
 $theCreationDate=Get-ADUser  -properties Created -Identity "CN=${firstNameIn} ${lastNameIn},$contextIn" | select Created -ExpandProperty Created 
}catch{}

Write-Output "Account Creation Date:  $theCreationDate"


try{
 $theUserSamAccounName=Get-ADUser  -properties SamAccountName -Identity "CN=${firstNameIn} ${lastNameIn},$contextIn" | select SamAccountName -ExpandProperty SamAccountName 
}catch{}


Write-Output "SamAccountName:  $theUserSamAccounName"


try{
 $DN=Get-ADUser  -properties DistinguishedName -Identity "CN=${firstNameIn} ${lastNameIn},$contextIn" | select DistinguishedName -ExpandProperty DistinguishedName 
}catch{}

 
Write-Output "DISTINGUISHED NAME:  $DN"




