# Add users to a Group or Groups
# Author: Tay Kratzer tay@cimitra.com
# Modify Date: 2/27/2021
# Change the context variable to match your system
# -------------------------------------------------


Set-Variable -Name verboseOutputSet -Value $false -Option AllScope
Set-Variable -Name SearchForUser -Value $false -Option AllScope
Set-Variable -Name samAccountNameIn -Value "" -Option AllScope
Set-Variable -Name groupGUIDsIn -Value "" -Option AllScope
Set-Variable -Name ContextIn -Value "" -Option AllScope
Set-Variable -Name contextIn -Value "" -Option AllScope
Set-Variable -Name ValidatedGroupGUIDList -Value @() -Option AllScope
Set-Variable -Name ArrayOfGroupGUIDs -Value @() -Option AllScope

$lastNameIn = ""
$firstNameIn = ""


for ( $i = 0; $i -lt $args.count; $i++ ) {
    if ($args[ $i ] -eq "-LastNameIn"){ $lastNameIn=$args[ $i+1 ]}
    if ($args[ $i ] -eq "-FirstNameIn"){ $firstNameIn=$args[ $i+1 ]}
    if ($args[ $i ] -eq "-SamAccountNameIn"){ $samAccountNameIn=$args[ $i+1 ]}
    if ($args[ $i ] -eq "-GroupGUIDsIn"){ $groupGUIDsIn=$args[ $i+1 ]}
    if ($args[ $i ] -eq "-ContextIn"){ $ContextIn=$args[ $i+1 ]}
    if ($args[ $i ] -eq "-ShowErrors"){ $verboseOutputSet = $true}
    if ($args[ $i ] -eq "-SearchForUser"){ $SearchForUser = $true}
}

# Check for parameters where the parameter is empty, and thus the next parameter is another parameter that uses a -<parameter name>
$samAccountNameFirstChar = $samAccountNameIn[0]

if($samAccountNameFirstChar -eq '-'){
$samAccountNameIn=""
}

$firstNameInFirstChar = $firstNameIn[0]

if($firstNameInFirstChar -eq '-'){
$firstNameIn=""
}

$lastNameInFirstChar = $lastNameIn[0]

if($lastNameInFirstChar -eq '-'){
$lasstNameIn=""
}

$ContextInFirstChar = $ContextIn[0]

if($ContextInFirstChar -eq '-'){
$ContextIn=""
}

$groupGUIDsInFirstChar = $groupGUIDsIn[0]

if($groupGUIDsInFirstChar -eq '-'){
$groupGUIDsIn=""
}


# Make names comply with cultural norms
if($firstNameIn.Length -gt 2){
$firstNameIn = (Get-Culture).TextInfo.ToTitleCase($firstNameIn) 
}

if($lastNameIn.Length -gt 2){
$lastNameIn = (Get-Culture).TextInfo.ToTitleCase($lastNameIn) 
}

$context = "OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com" 
 # - OR -
 # Specify the context in settings.cfg file
 # Use this format: AD_USER_CONTEXT=<ACTIVE DIRECTORY CONTEXT>
 # Example: AD_USER_CONTEXT=OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com
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
Set-Variable -Name samAccountNameInSet -Value $false -Option AllScope
$groupGUIDsInSet = $true
$modifyUserResult = $true
$sleepTime = 5
$groupGUIDsIn = $GroupGUIDsIN

$SamAccountNameInEmpty = [string]::IsNullOrWhiteSpace($samAccountNameIn)

if(!($SamAccountNameInEmpty)){
$samAccountNameInSet = $true
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


$groupGUIDsInSetEmpty = [string]::IsNullOrWhiteSpace($groupGUIDsIn)

if($groupGUIDsInSetEmpty){
$groupGUIDsInSet = $false
}

$ContextInEmpty = [string]::IsNullOrWhiteSpace($ContextIn)

if($ContextInEmpty){
$contextIn = $context
}else{
$contextIn = $ContextIn
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
Write-Host "Add a User to Groups in Active Directory"
Write-Host ""
Write-Host "[ HELP ]"
Write-Host ""
Write-Host ".\$scriptName -h or -help"
Write-Host ""
Write-Host "[ SCRIPT USAGE ]"
Write-Host ""
Write-Host ".\$scriptName -FirstNameIn <user first name> -LastNameIn <user last name> -GroupGUIDsIn <list of AD Group GUIDS separated with a commma> -contextIn <Active Directory context (optional if specified in settings.cfg)>"
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host ".\$scriptName -SamAccountNameIn <user sAMAccountName> -GroupGUIDsIn <list of AD Group GUIDS separated with a commma> "
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host ".\$scriptName -SearchForUser -FirstNameIn <user first name> -LastNameIn <user last name> -GroupGUIDsIn <list of AD Group GUIDS separated with a commma> "
Write-Host ""
Write-Host "[ EXAMPLES ]"
Write-Host ""
Write-Host "Example: .\$scriptName -FirstNameIn Jane -LastNameIn Doe -GroupGUIDsIn 'e31b003c-45a4-4534-b340-ddbdde36a89d','03574aef-3a04-4646-b88c-bca7d90c9987' "
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host "Example: .\$scriptName -FirstNameIn Jane -LastNameIn Doe -GroupGUIDsIn 'e31b003c-45a4-4534-b340-ddbdde36a89d','03574aef-3a04-4646-b88c-bca7d90c9987' -ContextIn OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com"
Write-Host ""
Write-Host "-OR-"
Write-Host ""
Write-Host "Example: .\$scriptName -SamAccountNameIn janedoe -GroupGUIDsIn 'e31b003c-45a4-4534-b340-ddbdde36a89d','03574aef-3a04-4646-b88c-bca7d90c9987'"
Write-Host ""
Write-Host "[ ERROR HANDLING ]"
Write-Host ""
Write-Host "-ShowErrors = Show Error Messages"
Write-Host ""
Write-Host "Example: .\$scriptName -ShowErrors ..."
Write-Host ""
exit 0
}

if (Write-Output $args | Select-String "\-h\b|\-help\b" )
{
ShowHelp
}

$sufficientInput = $false

# If First and Last Names are specified and a/some GroupGuids, then input is sufficient

if ( $firstNameInSet -and $lastNameInSet -and $groupGUIDsInSet){ 
$sufficientInput = $true
 }

# If SamAccountName is specified and a/some GroupGuids, then input is sufficient
 if ( $samAccountNameInSet -and $groupGUIDsInSet){ 
$sufficientInput = $true
 }
# -------------------------------------------------


# If the SamAccountName is specified, we don't need the context for the user

if(!($samAccountNameInSet)){

if($contextIn.Length -lt 3){
ShowHelp
}

}

if(!($sufficientInput)){
ShowHelp
}


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
Write-Output "Searching For Users With The Name [ $firstNameIn $lastNameIn ]"
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
Write-Output "Try Using the User's SamAccountName"
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
}

}


function ValidateName(){

try{
Get-ADUser -Identity "CN=${firstNameIn} ${lastNameIn},$contextIn" *> $null
}catch{
SearchForUserName
}


}

if(!($samAccountNameInSet))
{
if($SearchForUser)
{
ValidateName
}

}

Function CorrelateGroupGUIDs {
# Turn list of GUIDS passed into script into an array
    param(
        [Parameter(Mandatory=$true)]
        [string]$GuidList,
        [array]$add
    )

        $GroupGUIDs = $GuidList.split(',')
        try{
        $GroupGUIDs += $add.split(' ')
        }catch{}


    return $GroupGUIDs
}



# Get Array of Group GUIDs passed into the script
$ArrayOfGroupGUIDs = CorrelateGroupGUIDs "$groupGUIDsIn"

# If $ArrayOfGroupGUIDs is not an array, then convert it into an array. For some reason running this script in the background doesn't create arrays correctly
try{$ArrayOfGroupGUIDs.GetUpperBound(0)}catch{
$ArrayOfGroupGUIDs = $ArrayOfGroupGUIDs.Split(" ")
}

foreach ($i in $ArrayOfGroupGUIDs) {

    $GetGroupSuccess = $true

    try{Get-ADGroup -Identity $i *> $null}catch{$GetGroupSuccess = $false} 

        if($GetGroupSuccess)
        {
            try{
            $ValidatedGroupGUIDList += $i.split(' ')
            }catch{}

        }
}


function IdentifyUser(){


    if($samAccountNameInSet)
    {
    $TheUser = Get-ADUser -Identity "$samAccountNameIn"
    $DistinguishedName = $TheUser.distinguishedName
    Write-Output "User: $DistinguishedName"
    }else{
    Write-Output "Get-ADUser -Identity 'CN=$firstNameIn $lastNameIn,$contextIn'"
    $TheUser = Get-ADUser -Identity "CN=$firstNameIn $lastNameIn,$contextIn"
    $DistinguishedName = $TheUser.distinguishedName
    Write-Output "User: $DistinguishedName"
    }

}

IdentifyUser


foreach ($GroupGuid in $ValidatedGroupGUIDList) {

$TheGroupName = Get-ADGroup -Identity "$GroupGuid" #| Select-Object -Property Name | ft -HideTableHeaders
$TheGroupName =  $TheGroupName.Name



    $AddUserSuccess = $true

    if($samAccountNameInSet)
    {
    
    try{Add-ADGroupMember -Identity $GroupGuid -Members "$samAccountNameIn" *> $null}catch{$AddUserSuccess = $false} 
    }else{
    try{Add-ADGroupMember -Identity $GroupGuid -Members "CN=$firstNameIn $lastNameIn,$contextIn" *> $null}catch{
        $AddUserSuccess = $false
        $err = "$_"
        } 
    }

  

    if($AddUserSuccess){
    


        if($samAccountNameInSet){
        $TheUser = Get-ADUser -Identity "$samAccountNameIn"
        $TheUser = $TheUser.Name
               
        }else{
        $TheUser = Get-ADUser -Identity "CN=$firstNameIn $lastNameIn,$contextIn" # | Select-Object -Property Name | ft Name -HideTableHeaders
        $TheUser = $TheUser.Name
        }
                # Write-Output ""
        Write-Output "User: $TheUser | Added To Group: $TheGroupName"


    }else{
           if($samAccountNameInSet){
            Write-Output "User: $TheUser | NOT Added To Group: $TheGroupName"
            }else{
            Write-Output "User: CN=$firstNameIn $lastNameIn,$contextIn  | NOT Added To Group: $TheGroupName"
            } 
        Write-Output ""
        Write-Output "[ERROR MESSAGE BELOW]"
        Write-Output "-----------------------------"
        Write-Output ""
        Write-Output $err
        Write-Output ""
        Write-Output "-----------------------------"

    }

}

Write-Output ""

