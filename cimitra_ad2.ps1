# Add a user to Exchange or Active Directory, Or Modify an Active Directory User
# Author: Tay Kratzer tay@cimitra.com
# Modify Date: 4/20/2021
# Change the context variable to match your system
# -------------------------------------------------


<#
.DESCRIPTION
Add a user to Active Directory or Exchange, Or Modify an Active Directory User
#>

### Remove the first and last characters in a string and assign the value to an Integer ###
### $ContextNumberIn = [int]$ContextNumberIn.Substring(1,$ContextNumberIn.Length-2) ###


Param(
    # Update a user object in Active Directory
    [switch] $UpdateActiveDirectoryObject, 
    # Add a user to Active Directory
    [switch] $AddToActiveDirectory,  
    # Add a user to Exchange      
    [switch] $AddToExchange, 
    # Find a User and EXIT
    # User Remote Mailbox
    [switch] $ExchangeRemoteMailbox, 
    # User On Premise Mailbox
    [switch] $ExchangeOnSiteMailbox,
    # Find A User's Info and EXIT 
    [switch] $FindAndShowUserInfo,
    # Find All Users and EXIT 
    [switch] $FindAndShowAllUsers, 
    # Find All Users in a context and EXIT 
    [switch] $FindAndShowAllUsersInContext, 
    # Find All Expired Users and EXIT 
    [switch] $FindAndShowExpiredUsers, 
    # Find All Expired Users in a context and EXIT 
    [switch] $FindAndShowExpiredUsersInContext, 
    # Find All Disabled Users and EXIT 
    [switch] $FindAndShowDisabledUsers, 
    # Find All Disabled Users in a context and EXIT 
    [switch] $FindAndShowDisabledUsersInContext, 
    # Find All Users With No Logon Users and EXIT 
    [switch] $FindAndShowNoLogonUsers, 
    # Find All Users With No Logon in a context and EXIT 
    [switch] $FindAndShowNoLogonUsersInContext, 
    # Find All Users With Lockedout Accounts and EXIT 
    [switch] $FindAndShowAllLockedOutUsers, 
    # First name of a user to Add/Update                
    [string] $FirstNameIn,
    # Last name of a user to Add/Update                 
    [string] $LastNameIn,
    # Active Directory context of a user to Add/Update                  
    [string] $ContextIn, 
    [string] $ContextNumberIn, 
    [switch] $Debug,
    [switch] $DisableVerboseMode,
    # User's new email address on a user first name or last name change
    [string] $PrimarySmtpAddressIn,  
    # Active Directory SamAccountName for a user to Add/Update in Active Directory                  
    [string] $SamAccountNameIn,   
    # If a user's password needs to be set when being added, or the password needs to be changed, and no password is specificed, the DefaultPasswordIn will be used         
    [String] $DefaultPasswordIn,
    # New first name of a user to Update           
    [string] $NewFirstNameIn,
    # New last name of a user to Update              
    [string] $NewLastNameIn, 
    # The Exchange Account name for a new user in Exchange             
    [string] $ExchangeUserIn,
    # New SamAccountName for a user's whose SamAccountName you want to rename  
    [string] $NewSamAccountNameIn,
    # Update a user with a Manager, this is the first name of the Manager     
    [string] $ManagerFirstNameIn,
    # Update a user with a Manager, this is the last name of the Manager   
    [string] $ManagerLastNameIn,
    # Update a user with a Manager, this is the context where the Manager resides   
    [string] $ManagerContextIn,
    # Update a user with a Manager, this is the SamAccountName for that Manager  
    [string] $ManagerSamAccountNameIn,
    # Update a user's Description, can be used on Adding a user object and Updating a user object
    [string] $DescriptionIn,
    # Update a user's Mobile Phone Number, can be used on Adding a user object and Updating a user object
    [string] $DepartmentNameIn,
    # Update a user's Mobile Phone Number, can be used on Adding a user object and Updating a user object
    [string] $MobilePhoneIn,
    # Update a user's Office Phone Number, can be used on Adding a user object and Updating a user object
    [string] $OfficePhoneIn,
    # Update a user's Title, can be used on Adding a user object and Updating a user object
    [string] $TitleIn,
    # Set a user's account Expiration Date, can be used on Adding a user object and Updating a user object
    # Use Syntax: -ExpirationDateIn 2/2/2022
    [string] $ExpirationDateIn,
    # Update a user's Password, can be used on Adding a user object and Updating a user object
    [string] $UserPasswordIn,
    # Add a user to these Groups, specify a GUIDs for the Groups in a comma seperated list like so:
    #Usage Example: -GroupGUIDSIn "cec83314-2a87-4fbf-9dc7-00a4842d67ed,c5b6dc15-5a4a-40be-a85f-7a2bcfc29301,ba363486-bc66-437e-9e2e-842443aad359"
    # Can be used on Adding a user object and Updating a user object
    [string] $GroupGUIDsIn,
    [string] $GroupGUIDsInA,
    [string] $GroupGUIDsInB,
    [string] $GroupGUIDsInC,
    [string] $GroupGUIDsInD,
    [string] $GroupGUIDsInE,
    [string] $GroupGUIDsInF,
    [string] $GroupGUIDsInG,
    [string] $GroupGUIDsInH,
    [string] $GroupGUIDsInI,
    [string] $GroupGUIDsInJ,
    [string] $GroupGUIDsInK,
    [string] $GroupGUIDsInL,
    [string] $GroupGUIDsInM,
    [string] $GroupGUIDsInN,
    [string] $GroupGUIDsInO,
    [string] $GroupGUIDsInP,
    [string] $GroupGUIDsInQ,
    [string] $GroupGUIDsInR,
    [string] $GroupGUIDsInS,
    [string] $GroupGUIDsInT,
    [string] $GroupGUIDsInU,
    [string] $GroupGUIDsInV,
    [string] $GroupGUIDsInW,
    [string] $GroupGUIDsInX,
    [string] $GroupGUIDsInY,
    [string] $GroupGUIDsInZ,

    #Usage Example: -ExcludeGroupGUIDIn "cec83314-2a87-4fbf-9dc7-00a4842d67ed"
    # Can be used on Adding a user object and Updating a user object. Users in the Exlude Group will not be modified
    [string] $ExcludeGroupGUIDIn,
    # When creating an Exchange User make a special user that the Cimitra Windows Agent Service will log in as
    # You should create a Password File while logged in as the user that will be running the Cimitra Agent
    [string] $CimitraAgentLogonAccountIn,
    # Give the path to the Password File for the account you created to run the Cimitra Windows Agent Service
    [string] $ExchangeSecurePasswordFileIn,
    # Give the path to the Exchange URI\
    # Usage Example: -ExchangeConnectionURIIn 'http://example-EXCH16.acme.internal/PowerShell/'
    [string] $ExchangeConnectionURIIn,
    # The Exchange Domain to use for a New Exchange User
    # Usage Example: -ExchangeDomainNameIn "example.com"
    [string] $ExchangeDomainNameIn,
    # Hide errors that come back from Active Directory and Exchange when trying to do Adds and Updates of user objects
    [switch] $HideErrors,
    # When setting or updating a password, this will force the password to be reset on the next user logon
    [switch] $ForcePasswordReset,
    # If you specify a user's First and Last name, but do not specify the context, this script will search for the user
    # If the search finds just one user with that First and Last name it will consider the user to be a match
    # If the -DisableSearch switch is used, then Cimitra will not look for the user specified
    [switch] $DisableSearch,
    [switch] $EnableExchangeUpdates,
    [switch] $RemoveUserFromGroupGUIDsIn,
    [switch] $RemoveExpirationDate,
    [switch] $EnableUser,
    [switch] $DisableUser,
    [switch] $UnlockAccount,
    [switch] $CheckPasswordDate,
    [switch] $GetUserInfo,
    [switch] $GetUserAccountStatus,
    [switch] $RemoveUser,
    [switch] $ConfirmWordRequired,
    [string] $ConfirmWord,
    [string] $ConfirmWordIn,
    [switch] $IgnoreExcludeGroup,
    [switch] $ResetUserPassword,
    [switch] $Info,
    [switch] $DisableConfig, 
    # Between Add and Update operations on new users, there is a sleep interval called
    # The default value is 5 seconds
    # This parameter allows that sleep interval to be configurable.
    [string] $SleepTimeIn,
    [string] $NonInputA,
    [string] $NonInputB,
    [string] $NonInputC,
    [string] $NonInputD,
    [string] $NonInputE,
    [string] $NonInputF,
    [string] $NonInputG,
    [string] $NonInputH,
    [string] $NonInputI,
    [string] $NonInputJ,
    [string] $NonInputK,
    [string] $NonInputL,
    [string] $NonInputM,
    [string] $NonInputN,
    [string] $NonInputO,
    [string] $NonInputP,
    [string] $NonInputQ,
    [string] $NonInputR,
    [string] $NonInputS,
    [string] $NonInputT,
    [string] $NonInputU,
    [string] $NonInputV,
    [string] $NonInputW,
    [string] $NonInputX,
    [string] $NonInputY,
    [string] $NonInputZ
 )


# Dynamically get all parameters in the current script.
$parameters = get-command $PSCommandPath | Select-Object Parameters
# Remove all quotes and double quotes that might be passed in as part of parameters
foreach($parameterName in $parameters.Parameters.Keys){

    # This ensures we only process named parameters, rather than standard parameters such as "Verbose", "ErrorAction" etc
    $parameterValue = Get-Variable $parameterName -ErrorAction SilentlyContinue 

    if($parameterValue){
        # We do not want to process switch parameters
        if(($parameterValue.Value.GetType().Name -ne "SwitchParameter") -and ($parameterValue.Value.GetType().Name -eq 'String')){ # ignore switch parameters
            ###if($parameterValue.Value.StartsWith("`"") -or $parameterValue.Value.StartsWith("'")){###
            if(($parameterValue.Value -like "*'*") -or ($parameterValue.Value -like "*`"*")){
                # The parameter value starts with either a single or double quote character, trim quote characters
                ### $newParameterValue = $parameterValue.Value.ToString().Trim("`"") ###
                $newParameterValue = $parameterValue.Value.ToString().Replace("`"","")

                ###$newParameterValue = $newParameterValue.Trim("'")###
                $newParameterValue = $newParameterValue.Replace("'","")
                Set-Variable -Name $parameterName -Value $newParameterValue
          }

        }                
    }
}

# These are arrays used in this script that are passed arround to functions
Set-Variable -Name ValidatedGroupGUIDList -Value @() -Option AllScope
Set-Variable -Name ArrayOfGroupGUIDs -Value @() -Option AllScope

## PROCESS ALL GROUP GUIDS ##
## ----------------------- ##
$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsAInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInA)

if(!($GroupGUIDsAInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInA
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInA
    }

}


$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsBInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInB)

if(!($GroupGUIDsBInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInB
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInB
    }

}


$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsCInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInC)

if(!($GroupGUIDsCInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInC
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInC
    }

}

$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsDInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInD)

if(!($GroupGUIDsDInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInD
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInD
    }

}


$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsEInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInE)

if(!($GroupGUIDsEInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInE
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInE
    }

}


$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsFInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInF)

if(!($GroupGUIDsFInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInF
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInF
    }

}


$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsGInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInG)

if(!($GroupGUIDsGInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInG
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInG
    }

}



$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsHInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInH)

if(!($GroupGUIDsHInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInH
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInH
    }

}




$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsIInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInI)

if(!($GroupGUIDsIInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInI
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInI
    }

}



$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsJInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInJ)

if(!($GroupGUIDsJInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInJ
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInJ
    }

}


$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsKInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInK)

if(!($GroupGUIDsKInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInK
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInK
    }

}



$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsLInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInL)

if(!($GroupGUIDsLInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInL
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInL
    }

}


$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsMInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInM)

if(!($GroupGUIDsMInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInM
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInM
    }

}



$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsNInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInN)

if(!($GroupGUIDsNInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInN
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInN
    }

}



$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsOInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInO)

if(!($GroupGUIDsOInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInO
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInO
    }

}


$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsPInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInP)

if(!($GroupGUIDsPInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInP
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInP
    }

}


$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsQInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInQ)

if(!($GroupGUIDsQInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInQ
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInQ
    }

}


$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsRInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInR)

if(!($GroupGUIDsRInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInR
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInR
    }

}


$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsSInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInS)

if(!($GroupGUIDsSInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInS
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInS
    }

}



$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsTInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInT)

if(!($GroupGUIDsTInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInT
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInT
    }

}



$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsUInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInU)

if(!($GroupGUIDsUInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInU
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInU
    }

}


$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsVInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInV)

if(!($GroupGUIDsVInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInV
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInV
    }

}


$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsWInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInW)

if(!($GroupGUIDsWInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInW
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInW
    }

}


$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsXInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInX)

if(!($GroupGUIDsXInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInX
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInX
    }

}


$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsYInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInY)

if(!($GroupGUIDsYInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInY
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInY
    }

}


$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
$GroupGUIDsZInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsInZ)

if(!($GroupGUIDsZInEmpty)){
    if($GroupGUIDsInEmpty){
        $GroupGUIDsIn = $GroupGUIDsInZ
    }else{
        $GroupGUIDsIn = $GroupGUIDsIn + ',' + $GroupGUIDsInZ
    }

}

## ----------------------- ##


# Write-Output "GroupGUIDsIn = $GroupGUIDsIn"




$ContextNumberInEmpty = [string]::IsNullOrWhiteSpace($ContextNumberIn)
# Cast ContextNumberIn to be an integer value
if(!($ContextNumberInEmpty)){
$ContextNumberIn = [int]$ContextNumberIn
$global:TheContextNumber = $ContextNumberIn -as[int]
}

$global:UserContextIn = ""
$global:TheExcludeGroup = ""

function GetContext(){

$CONTEXTS_CONFIG="${PSScriptRoot}\contexts.cfg"

try{
New-Item $CONTEXTS_CONFIG *>$null
}catch{}


$ContextInEmpty = [string]::IsNullOrWhiteSpace($ContextIn)
if($ContextInEmpty){
$ContextNumberInEmpty = [string]::IsNullOrWhiteSpace($ContextNumberIn)

    if(!($ContextNumberInEmpty)){

      $ContextNumber = ($TheContextNumber -1)
      
      $ContextFileReadSuccess = $true
    
         try{
         $Something = (Get-Content ${CONTEXTS_CONFIG})[$ContextNumber] > $null
            }catch{$ContextFileReadSuccess = $false}

            if($ContextFileReadSuccess){
               $AContext = (Get-Content ${CONTEXTS_CONFIG})[$ContextNumber] 
               $global:UserContextIn = $AContext
              }
       }

}


# $context = "OU=USERS,OU=DEMO,OU=CIMITRA,DC=cimitrademo,DC=com" 
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


$ContextInEmpty = [string]::IsNullOrWhiteSpace($ContextIn)
$UserContextInEmpty = [string]::IsNullOrWhiteSpace($UserContextIn)
if($ContextInEmpty -and $UserContextInEmpty){
$UserContextIn = "$CONFIG$AD_USER_CONTEXT"
}

if ($sleepTimeTest = "$CONFIG$AD_SCRIPT_SLEEP_TIME"){
$sleepTime = "$CONFIG$AD_SCRIPT_SLEEP_TIME"
}

# If an ExcludeGroupIn parameter isn't passed in, look for it in the settings.cfg file
$ExcludeGroupGUIDInEmpty = [string]::IsNullOrWhiteSpace($ExcludeGroupGUIDIn)

if($ExcludeGroupGUIDInEmpty){
# Map the $context variable to the AD_EXCLUDE_GROUP variable read in from the settings.cfg file
    if ($excludeGroupTest = "$CONFIG$AD_EXCLUDE_GROUP"){
        $global:TheExcludeGroup = "$CONFIG$AD_EXCLUDE_GROUP"

    }

}


}

}

}

if(!($DisableVerboseMode)){
$global:verboseOutputSet = $true
}else{
$global:verboseOutputSet = $false
}

if(!($DisableConfig)){
GetContext
}

if($AddToActiveDirectory -or $AddToExchange)
{
$global:GetUserInfo = $false
}


# Reassign parameters
$global:userFirstName = $FirstNameIn
$global:userLastName = $LastNameIn
$global:sleepTime = 5
$global:createObjectWorked = $true
$global:exchangeSessionCreated = $false



if($Info){
Write-Output ""
Write-Output "-----------------INFO START-----------------"
Write-Host -NoNewline "Main Function | Line Number: "
& { write-host $myinvocation.scriptlinenumber }
Write-Output "First Name = $userFirstName"
Write-Output "Last Name = $userLastName"
Write-Output "-----------------INFO STOP------------------"
Write-Output ""
}


$global:modifyAnADUser = $false
if($UpdateActiveDirectoryObject){
$global:modifyAnADUser = $true
}

# Show Help
function ShowHelp{
$scriptName = Split-Path -leaf $PSCommandpath
Write-Host ""
Write-Host "Add a User to Active Directory or Exchange, Or Update Active Directory User"
Write-Host ""
Write-Host "[ HELP ]"
Write-Host ""
Write-Host "Get-Help .\$scriptName"
Write-Host ""
Write-Host ".\$scriptName -h or -help"
Write-Host ""
exit 0
Write-Host "[ SCRIPT USAGE ]"
Write-Host ""
Write-Host ".\$scriptName"
Write-Host ""
Write-Host ""
Write-Host "[REQUIRED PARAMETERS]"
Write-Host ""
Write-Host "-FirstNameIn <user first name> (required)"
Write-Host ""
Write-Host "-LastNameIn <user last name> (required)"
Write-Host ""
Write-Host "[OPTIONAL PARAMETERS]"
Write-Host ""
Write-Host "-ContextIn <Active Directory context (required) (optional if specified in settings.cfg)>"
Write-Host ""
Write-Host "-DefaultPasswordIn <default password> (required)"
Write-Host ""
write-Host "-GroupGUIDsIn <list of AD Group GUIDS separated with a commma>"
Write-Host ""
Write-Host "-ManagerFirstNameIn <user's manager first name>"
Write-Host ""
Write-Host "-ManagerLastNameIn <user's manager last name>"
Write-Host ""
Write-Host "-ManagerSamAccountNameIn <user's manager SamAccountName>"
Write-Host ""
Write-Host "-ExchangeUserIn <user's Exchange User Account/SamAccountName>"
Write-Host ""
Write-Host "-TitleIn <user's title>"
Write-Host ""
Write-Host "-DepartmentIn <user's department>"
Write-Host ""
Write-Host "-MobilePhoneIn <user's mobile phone>"
Write-Host ""
Write-Host "-OfficePhoneIn <user's office phone>"
Write-Host ""
Write-Host "-NewFirstNameIn <user's new first name>"
Write-Host ""
Write-Host "-NewLastNameIn <user's new last name>"
Write-Host ""
Write-Host "[OPTIONS]"
Write-Host ""
Write-Host "[ ERROR HANDLING ]"
Write-Host ""
Write-Host "-HideErrors"
Write-Host ""
Write-Host "[ PREFERENCES ]"
Write-Host ""
Write-Host "-ForcePasswordReset"
Write-Host ""
Write-Host "-SearchForManager - If Manager is not found in the default context"
Write-Host ""
Write-Host "-AddToExchange - Add the user to Exchange first, and then modify the Active Directory object"
Write-Host ""
Write-Host ""
exit 0
}

if (Write-Output $args | Select-String "\-h\b|\-help\b" )
{
ShowHelp
}





function FindAndShowUsersFunction(){

Write-Output "ALL USERS - USER INFORMATION REPORT"
Write-Output "-----------------------------------"
Write-Output "-----------------------------------"

$runResult = $true

if($FindAndShowAllUsersInContext){

    try{
    Get-ADUser -Filter * -Searchbase $contextIn  -ErrorAction Stop | select Name,Givenname,Surname,sAMAccountName,distinguishedName  | fl 
    }catch{
    $runResult = $false
    $err = "$_"
    }
}else{

    try{
    Get-ADUser -Filter * -ErrorAction Stop | select Name,Givenname,Surname,sAMAccountName,distinguishedName  | fl 
    }catch{
    $runResult = $false
    $err = "$_"
    }

}

# If exit code from the Set-ADUser command was "True" then show a success message
if (!($runResult))
{
Write-Output ""
Write-Output "Unable To Get an All User Information Report"
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

}

function FindAndShowExpiredUsersFunction(){

Write-Output "ALL EXPIRED USERS - USER INFORMATION REPORT"
Write-Output "-------------------------------------------"
Write-Output "-------------------------------------------"

$runResult = $true

if($FindAndShowExpiredUsersInContext){

    try{
    Search-ADAccount -SearchBase $contextIn -AccountExpired -UsersOnly -ErrorAction Stop |  Select-Object Name,Givenname,Surname,sAMAccountName,distinguishedName,AccountExpirationDate | fl
    }catch{
    $runResult = $false
    $err = "$_"
    }
}else{

    try{
    Search-ADAccount -AccountExpired -UsersOnly -ErrorAction Stop |  Select-Object Name,Givenname,Surname,sAMAccountName,distinguishedName,AccountExpirationDate | fl
    }catch{
    $runResult = $false
    $err = "$_"
    }

}

# If exit code from the Set-ADUser command was "True" then show a success message
if (!($runResult))
{
Write-Output ""
Write-Output "Unable To Get an All Expired Users Information Report"
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

}

function FindAndShowDisabledUsersFunction(){

Write-Output "ALL DISABLED USERS - USER INFORMATION REPORT"
Write-Output "--------------------------------------------"
Write-Output "--------------------------------------------"

$runResult = $true

if($FindAndShowDisabledUsersInContext){

    try{
    Get-ADUser -Filter {(Enabled -eq $false)} -Searchbase $contextIn  -ErrorAction Stop | select Name,Givenname,Surname,sAMAccountName,distinguishedName  | fl 
    }catch{
    $runResult = $false
    $err = "$_"
    }
}else{

    try{
    Get-ADUser -Filter {(Enabled -eq $false)} -ErrorAction Stop | select Name,Givenname,Surname,sAMAccountName,distinguishedName  | fl 
    }catch{
    $runResult = $false
    $err = "$_"
    }

}

# If exit code from the Set-ADUser command was "True" then show a success message
if (!($runResult))
{
Write-Output ""
Write-Output "Unable To Get an All Disabled User Information Report"
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

}

function FindAndShowNoLogonUsersFunction(){
 
Write-Output "ALL USERS WITH NO LOGON - USER INFORMATION REPORT"
Write-Output "-------------------------------------------------"
Write-Output "-------------------------------------------------"

$runResult = $true

if($FindAndShowNoLogonUsersInContext){

    try{
    Get-ADUser -SearchBase $contextIn -Filter {-not (lastlogontimestamp -like "*") -and -not (iscriticalsystemobject -eq $true)}  -ErrorAction Stop | select Name,Givenname,Surname,sAMAccountName,distinguishedName  | fl 
    }catch{
    $runResult = $false
    $err = "$_"
    }
}else{

    try{
    Get-ADUser -Filter {-not (lastlogontimestamp -like "*") -and -not (iscriticalsystemobject -eq $true)}  -ErrorAction Stop | select Name,Givenname,Surname,sAMAccountName,distinguishedName  | fl 
    }catch{
    $runResult = $false
    $err = "$_"
    }

}

if (!($runResult))
{
Write-Output ""
Write-Output "Unable To Get an All Users No Logon User Information Report"
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

}

function FindAndShowLockedOutUsersFunction(){

$UserExistsInLockedOutReport = $false

Write-Output "-----------------------"
Write-Output "LOCKED OUT USERS REPORT"
Write-Output "-----------------------"
Write-Output ""

$TEMP_FILE_ONE = New-TemporaryFile
$TEMP_FILE_TWO = New-TemporaryFile

$SomeUserWasLocked = $false

Search-AdAccount -LockedOut -UsersOnly | select -Property 'SamAccountName' | Format-Table -HideTableHeaders > $TEMP_FILE_ONE


Get-Content $TEMP_FILE_ONE | where {$_ -ne ""} > $TEMP_FILE_TWO

ForEach ($line in (Get-Content "$TEMP_FILE_TWO")){
     $SomeUserWasLocked = $true
     $TheUserOjbect = Get-ADUser -Identity $samAccountName -Properties lockoutTime
     $LockOutTime = [datetime]::FromFileTime($TheUserOjbect.lockoutTime)
     Write-Output "Account Locked: $TheUserOjbect"
     Write-Output "Lockedout Time: $LockOutTime"
     }

Remove-Item -Path $TEMP_FILE_ONE -Force 2>&1 | out-null
Remove-Item -Path $TEMP_FILE_TWO -Force 2>&1 | out-null


if($SomeUserWasLocked){
Write-Output ""
Write-Output "-----------------------"
}else{
Write-Output "NO LOCKED USERS FOUND"
Write-Output "-----------------------"
}

}






if($FindAndShowAllLockedOutUsers){
FindAndShowLockedOutUsersFunction
exit 0
}


if($FindAndShowAllUsers -or $FindAndShowAllUsersInContext){
FindAndShowUsersFunction
exit 0
}

if($FindAndShowExpiredUsers -or $FindAndShowExpiredUsersInContext){
FindAndShowExpiredUsersFunction
exit 0
}

if($FindAndShowDisabledUsers -or $FindAndShowDisabledUsersInContext){
FindAndShowDisabledUsersFunction
exit 0
}


if($FindAndShowNoLogonUsers -or $FindAndShowNoLogonUsersInContext){
FindAndShowNoLogonUsersFunction
exit 0
}

if($AddToExchange -and $AddToActiveDirectory)
{
Write-Output ""
Write-Output "Use either -AddToActiveDirectory (or) -AddToExchange"
Write-Output ""
Write-Output "Using both parameters simultaneously is invalid"
Write-Output ""
exit 1
}



# Set parameters 



$SleepTimeInEmpty = [string]::IsNullOrWhiteSpace($SleepTimeIn)
if($SleepTimeInEmpty){
$global:TheSleepTime = $sleepTime
}else{
$global:TheSleepTime = $SleepTimeIn
}


$global:expireUserObject = $false
$ExpirationDateInEmpty = [string]::IsNullOrWhiteSpace($ExpirationDateIn)
if(!($ExpirationDateInEmpty)){
$global:expireUserObject = $true
}

if($userFirstName.Length -gt 2){
$global:firstNameSet = $true
}else{
$global:firstNameSet = $false
}

if($userLastName.Length -gt 2){
$global:lastNameSet = $true
}else{
$global:lastNameSet = $false
}

# Was a SamAccountName specified
$global:samAccountNameInSet = $false
$global:samAccountName = "abc"
$SamAccountNameInEmpty = [string]::IsNullOrWhiteSpace($SamAccountNameIn)
if(!($SamAccountNameInEmpty)){
$global:samAccountNameInSet = $true
$global:samAccountName = "$SamAccountNameIn"


    if($Info){
    Write-Output ""
    Write-Output "-----------------INFO START-----------------"
    Write-Host -NoNewline "Main Function | Line Number: "
    & { write-host $myinvocation.scriptlinenumber }
    Write-Output "SamAccountName Set = $samAccountNameInSet"
    Write-Output "SamAccountName = $samAccountName"
    Write-Output "-----------------INFO STOP------------------"
    Write-Output ""
    }

}else{


    if($Info){
    Write-Output ""
    Write-Output "-----------------INFO START-----------------"
    Write-Host -NoNewline "Main Function | Line Number: "
    & { write-host $myinvocation.scriptlinenumber }
    Write-Output "SamAccountName Set = $samAccountNameInSet"
    Write-Output "-----------------INFO STOP------------------"
    Write-Output ""
    }

}

# If First and Last Names are specified then input is sufficient

if (!( $firstNameSet -and $lastNameSet)){ 

if(!($samAccountNameInSet))
{
Write-Output ""
Write-Output "Error you need to specify either a Userid/SamAccounName or a First Name and Last Name"
Write-Output ""
exit 0
}


}

# For determing if the script creates a user first
$global:ObjectCreationActionTaken = $false

# Was manager name specified
$global:managerNameSet = $true

$ManagerFirstNameEmpty = [string]::IsNullOrWhiteSpace($ManagerFirstNameIn)
if($ManagerFirstNameEmpty){
$global:managerNameSet = $false
}

$ManagerLastNameEmpty = [string]::IsNullOrWhiteSpace($ManagerLastNameIn)
if($ManagerLastNameEmpty){
$global:managerNameSet = $false
}

$global:managerSamAccountNameSet = $false
$ManagerSamAccountNameEmpty = [string]::IsNullOrWhiteSpace($ManagerSamAccountNameIn)
if(!($ManagerSamAccountNameEmpty)){
$global:managerNameSet = $true
$global:managerSamAccountNameSet = $true
}


$global:managerContextSet = $false
$ManagerContextEmpty = [string]::IsNullOrWhiteSpace($ManagerContextIn)
if(!($ManagerContextEmpty)){
$global:managerContextSet = $true
}


# Was a default password specified
$global:defaultPasswordSet = $false
$global:TheDefaultPasswordIn = ""
$DefaultPasswordInEmpty = [string]::IsNullOrWhiteSpace($DefaultPasswordIn)
if($DefaultPasswordInEmpty){
$global:TheDefaultPasswordIn = 'abc_123_8-0'
}else{
$global:TheDefaultPasswordIn = $DefaultPasswordIn
}

# Was a Password specified
$global:userPassword = ""
$global:userPasswordSet = $false
$UserPasswordInEmpty = [string]::IsNullOrWhiteSpace($UserPasswordIn)
if($UserPasswordInEmpty){
$global:userPassword = $TheDefaultPasswordIn
}else{
$global:userPasswordSet = $true
$global:userPassword = $UserPasswordIn
}


# Was a Department specified
$global:departmentNameInSet = $false
$DepartmentNameInEmpty = [string]::IsNullOrWhiteSpace($DepartmentNameIn)
if(!($DepartmentNameInEmpty)){
$global:departmentNameInSet = $true
}

# Was a New First Name specified
$global:newFirstNameInSet = $false
$NewFirstNameInEmpty = [string]::IsNullOrWhiteSpace($NewFirstNameIn)
if(!($NewFirstNameInEmpty)){
$global:newFirstNameInSet = $true
}

# Was a New Last Name specified
$global:newLastNameInSet = $false
$NewLastNameInEmpty = [string]::IsNullOrWhiteSpace($NewLastNameIn)
if(!($NewLastNameInEmpty)){
$global:newLastNameInSet = $true
}


# Was a list of Group GUIDS specified
$global:groupGUIDsInSet = $false
$GroupGUIDsInEmpty = [string]::IsNullOrWhiteSpace($GroupGUIDsIn)
if(!($GroupGUIDsInEmpty)){
$global:groupGUIDsInSet = $true
}


# Was a New SamAccountName specified
$global:newSamAccountNameInSet = $false
$NewSamAccountNameInEmpty = [string]::IsNullOrWhiteSpace($NewSamAccountNameIn)
if(!($NewSamAccountNameInEmpty)){
$global:newSamAccountNameInSet = $true
}

# Was a Mobile Phone specified
$global:mobilePhoneInSet = $false
$MobilePhoneInEmpty = [string]::IsNullOrWhiteSpace($MobilePhoneIn)
if(!($MobilePhoneInEmpty)){
$global:mobilePhoneInSet = $true
}

# Was an Office Phone specified
$global:officePhoneInSet = $false
$OfficePhoneInEmpty = [string]::IsNullOrWhiteSpace($OfficePhoneIn)
if(!($OfficePhoneInEmpty)){
$global:officePhoneInSet = $true
}

# Was a Title specified
$global:titleInSet = $false
$TitleInEmpty = [string]::IsNullOrWhiteSpace($TitleIn)
if(!($TitleInEmpty)){
$global:titleInSet = $true
}

# Was a Description specified
$global:descriptionInSet = $false
$DescriptionInEmpty = [string]::IsNullOrWhiteSpace($DescriptionIn)
if(!($DescriptionInEmpty)){
$global:descriptionInSet = $true
}

# Hide or show errors to users of this script
$global:ShowErrors = $true
if($HideErrors){
$global:ShowErrors = $false
}

# Is this script allowed to search for a user to positively identify the user to be modified
$global:SearchForUser = $true
if($DisableSearch){
$global:SearchForUser = $false
}

# Is this script allowed to search for a manger/user to positively identify the user to be modified
$global:SearchForManager = $true
if($DisableSearch){
$global:SearchForManager = $false
}


$global:ForcePasswordReset = $ForcePasswordReset

# Are Group GUIDS specified for a user to be added to a group or groups
$groupGUIDsInSetEmpty = [string]::IsNullOrWhiteSpace($groupGUIDsIn)
$global:groupGUIDsInSet = $false
if(!($groupGUIDsInSetEmpty)){
$global:groupGUIDsInSet = $true
}

# Was the Context specified or not
$ContextInEmpty = [string]::IsNullOrWhiteSpace($ContextIn)

$UserContextInEmpty = [string]::IsNullOrWhiteSpace($UserContextIn)


if($UserContextInEmpty){
    if($ContextInEmpty){
    $global:UserContextIn = $context
    }else{
    if($ContextIn.Length -lt 5){
    $global:UserContextIn = $context
    }else{
    $global:UserContextIn = $ContextIn
    }
    }

}



# Find a User Object and return their Distinguised Name
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



# Search for a user, and get their SamAccountName
function SearchForUserSamAccountName($TheFirstName, $TheLastName)
{
[hashtable]$return = @{}

$counterUp = 0
Write-Output "Searching For Users With The Name: [ $TheFirstName $TheLastName ]"
Write-Output ""
Write-Output "-----------------------------------------------------------"
try{
@($theUser = Get-ADUser -Filter "Name -like '$TheFirstName $TheLastName'" -ErrorAction Stop ) | Get-DistinguishedName
$SamName = $theUser.sAMAccountName
$FullName = $theUser.Name
$FullyDistinguishedName = $theUser

if($SamName.Length -gt 2)
{
$counterUp++
}

}catch{}


if($counterUp -ne 1){
$return.ErrorState = $true
return $return
}

if($counterUp -eq 1){
$return.SamName = $SamName
$return.FullName = $FullName
$return.FullyDistinguishedName = $FullyDistinguishedName
$return.ErrorState = $false
return $return
}


}


# Make sure a User exists, and make sure their isn't a duplicate of the User with the same First Name and same Last Name
function ValidateName(){

$FoundUser = $true

$TheUser = @{}

try{
$TheUser = Get-ADUser -Identity CN=${userFirstName} ${userLastName},$UserContextIn -ErrorAction Stop 2> $null
}catch{
$FoundUser = $false
}

if($FoundUser){
$samAccountName = $TheUser.sAMAccountName
$samAccountNameInSet = $true
return $true
}else{

    if($Info){
    Write-Output ""
    Write-Output "-----------------INFO START-----------------" 
    $FUNCNAME = $((Get-PSCallStack)[0].FunctionName)
    Write-Host -NoNewline "Function: $FUNCNAME | Line Number: "
    & { write-host $myinvocation.scriptlinenumber }
    Write-Output "First Name = $userFirstName"
    Write-Output "Last  Name = $userLastName"
    Write-Output "-----------------INFO STOP------------------"
    Write-Output ""
    }

$UserSearchReturn = SearchForUserSamAccountName "$userFirstName" "$userLastName"

$UserSearchErrorState = $UserSearchReturn.ErrorState
if(!($UserSearchErrorState)){

$SAM = $UserSearchReturn.SamName

$global:samAccountName = $SAM
$global:samAccountNameInSet = $true


    if($Info){
    Write-Output ""
    Write-Output "-----------------INFO START-----------------" 
    $FUNCNAME = $((Get-PSCallStack)[0].FunctionName)
    Write-Host -NoNewline "Function: $FUNCNAME | Line Number: "
    & { write-host $myinvocation.scriptlinenumber }
    Write-Output "Got the SamAccountName Back From Search Function"
    Write-Output "SamAccountName Set = $samAccountNameInSet"
    Write-Output "SamAccountName = $samAccountName"
    Write-Output "-----------------INFO STOP------------------"
    Write-Output ""
    }


$UserFullName = $UserSearchReturn.FullName
$FullyDistinguishedName = $UserSearchReturn.FullyDistinguishedName
Write-Output "Found User: $UserFullName"
Write-Output "SamAccountName: $samAccountName"
Write-Output "Fully Distinguished Name: $FullyDistinguishedName"
return $true
}else{
Write-Output "Could Not Positively Identify a Unique User: $TheFirstNameIn $TheLastNameIn"
Write-Output ""
Write-Output "Try Using the User's SamAccountName"
$SearchUtilityExists = Test-Path "$PSScriptRoot\SearchForUser.ps1"
if($SearchUtilityExists)
{
. $PSScriptRoot\SearchForUser.ps1 -FirstNameIn ${userFirstName} -LastNameIn ${userLastName}
}
return $false

}


}


}



# Positively identify the user
function PostivielyIdentifyUser(){
if(!($samAccountNameInSet)){



        if($SearchForUser)
        {

                if($Info){
                Write-Output ""
                Write-Output "-----------------INFO START-----------------"
                Write-Host -NoNewline "Main Function | Line Number: "
                & { write-host $myinvocation.scriptlinenumber }
                Write-Output "First Name = $userFirstName"
                Write-Output "Last Name = $userLastName"
                Write-Output "-----------------INFO STOP------------------"
                ValidateName
                Write-Output ""
                }



            $ValidateResult = ValidateName
            if(!($ValidateResult)){
            Write-Output "Cannot Proceed, User Not Found"
            exit 0
            }

        }

}else{

    $UserDoesNotExist = $false

    try{
        $AUSER = Get-ADUser -Identity $samAccountName -ErrorAction Stop 2> $null
    }catch{
        $UserDoesNotExist = $true
    }

    if($UserDoesNotExist){
        Write-Output ""
        Write-Output "A User With The Userid: $TheSamAccountName Does Not Exists"
        Write-Output ""
        exit 
    }else{

        if(!($firstNameSet -or $lastNameSet)){

                $TheUserIsFound = $true
                try{
                    $AUSER = Get-ADUser -Identity $samAccountName -ErrorAction Stop 2> $null
                }catch{
                    $TheUserIsFound = $false
                }

                if($TheUserIsFound){

                  $TheFirstName = $AUSER.GivenName

                   $global:userFirstName = $TheFirstName
        
                    $TheLastName = $AUSER.Surname
    
                    $global:userLastName = $TheLastName
                    $global:samAccountName = $AUSER.sAMAccountName
                    $global:samAccountNameInSet = $true

            }

        }


    }

}

}

if(!($AddToActiveDirectory -or $AddToExchange)){
PostivielyIdentifyUser
}

# Sleep/Pause Function
function CALL_SLEEP{
if($Info){
    if($TheSleepTime -eq 1)
    {
    Write-Output "Pausing For: $TheSleepTime Second"
    }else{
    Write-Output "Pausing For: $TheSleepTime Seconds"
    }
}

Start-Sleep -s $TheSleepTime
}

# If the SamAccountName is specified, we don't need the context for the user. 
# If the ability to search for a user has been disabled, then show help and exit
#
if(!($SearchForUser)){

    if(!($samAccountNameInSet)){

    if($UserContextIn.Length -lt 3){
    ShowHelp
    }

    }
}





# Use this function to add GroupGUIDs passed into the script into an Array
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



function ProcessGroupGuids(){


# Get Array of Group GUIDs passed into the script

$ArrayOfGroupGUIDs = CorrelateGroupGUIDs "$groupGUIDsIn" 

# If their are duplicate GUIDs, remove them
$GroupGUIDs = $ArrayOfGroupGUIDs | select -Unique

# If $ArrayOfGroupGUIDs is not an array, then convert it into an array. For some reason running this script in the background doesn't create arrays correctly

$ArrayActionSuccess = 

try{$theArray = $GroupGUIDs.GetUpperBound(0)}catch{
$ArrayOfGroupGUIDs = $ArrayOfGroupGUIDs.Split(" ")
}


foreach ($i in $GroupGUIDs) {

    $GetGroupSuccess = $true

    try{Get-ADGroup -Identity $i -ErrorAction Stop *> $null}catch{$GetGroupSuccess = $false} 

        if($GetGroupSuccess)
        {
            try{
            $ValidatedGroupGUIDList += $i.split(' ')
            }catch{}

        }
}




}


function IdentifyUser(){

if($AddToActiveDirectory){
return
}
    if((!$samAccountNameInSet))
    {
    try{
    $TheUser = Get-ADUser -Identity CN=$userFirstName $userLastName,$UserContextIn -ErrorAction Stop
    }catch{
    Write-Output ""
    Write-Output "Error: Cannot Positively Identify User: $userFirstName $userLastName at Context: $UserContextIn"
    Write-Output ""
    exit 1
    }
    $DistinguishedName = $TheUser.distinguishedName
    $SAM = $TheUser.sAMAccountName
    $global:samAccountNameInSet = $true
    $global:samAccountName = $SAM
    Write-Output ""
    Write-Output "User Distinguished Name: $DistinguishedName"
    }

}


function AddUserToGroups(){

foreach ($GroupGuid in $ValidatedGroupGUIDList) {

$TheGroupName = Get-ADGroup -Identity $GroupGuid #| Select-Object -Property Name | ft -HideTableHeaders
$TheGroupName =  $TheGroupName.Name



    $AddUserSuccess = $true

    if($samAccountNameInSet)
    {
    
    try{Add-ADGroupMember -Identity $GroupGuid -Members $samAccountName -ErrorAction Stop *> $null}catch{$AddUserSuccess = $false} 
    }else{
    try{Add-ADGroupMember -Identity $GroupGuid -Members CN=$userFirstName $userLastName,$UserContextIn -ErrorAction Stop *> $null}catch{
        $AddUserSuccess = $false
        $err = "$_"
        } 
    }

  

    if($AddUserSuccess){
    


        if($samAccountNameInSet){
        $TheUser = Get-ADUser -Identity $samAccountName
        $TheUser = $TheUser.Name
               
        }else{
        $TheUser = Get-ADUser -Identity CN=$userFirstName $userLastName,$UserContextIn # | Select-Object -Property Name | ft Name -HideTableHeaders
        $TheUser = $TheUser.Name
        }
        Write-Output ""
        Write-Output "User: $TheUser | Added To Group: $TheGroupName"
        


    }else{
           if($samAccountNameInSet){
            Write-Output ""
            Write-Output "User: $TheUser | NOT Added To Group: $TheGroupName"
            }else{
            Write-Output ""
            Write-Output "User: CN=$userFirstName $userLastName,$UserContextIn  | NOT Added To Group: $TheGroupName"
            } 
        if ($verboseOutputSet){
        Write-Output ""
        Write-Output "[ERROR MESSAGE BELOW]"
        Write-Output "-----------------------------"
        Write-Output ""
        Write-Output $err
        Write-Output ""
        Write-Output "-----------------------------"
        }

}

}


}


function RemoveUserFromGroups(){


foreach ($GroupGuid in $ValidatedGroupGUIDList) {

$TheGroupName = Get-ADGroup -Identity $GroupGuid #| Select-Object -Property Name | ft -HideTableHeaders
$TheGroupName =  $TheGroupName.Name

    $RemoveUserSuccess = $true

   
 try{Remove-ADGroupMember -Identity $GroupGuid -Member $samAccountName -Confirm:$false -ErrorAction Stop *> $null
    }catch{
    $RemoveUserSuccess = $false
    } 


  

    if($RemoveUserSuccess){
    
        $TheUser = Get-ADUser -Identity $samAccountName
        $TheUser = $TheUser.Name
           
        Write-Output ""
        Write-Output "User: $TheUser | Removed From Group: $TheGroupName"
        


    }else{
           if($samAccountNameInSet){
        $TheUser = Get-ADUser -Identity $samAccountName
        $TheUser = $TheUser.Name
           
        Write-Output ""
        Write-Output "User: $TheUser | NOT Removed From Group: $TheGroupName"
        if ($verboseOutputSet){
        Write-Output ""
        Write-Output "[ERROR MESSAGE BELOW]"
        Write-Output "-----------------------------"
        Write-Output ""
        Write-Output $err
        Write-Output ""
        Write-Output "-----------------------------"
        }

}


}

}

}



# Report information on a User Object
function GetUserInfoFunction(){


$theGivenName=""
$theSurname=""
$theMobilePhone=""
$theTitle=""
$theDepartment=""
$theDescription=""
$theOfficePhone=""
$theMobilePhone=""
$theExpirationDate=""
$theAccountStatus = $true
$thePasswordSetDate=""
$theCreationDate=""
$theUserSamAccounName=""
$theUserCnName=""
$theManager=""

$UserFound =  $true

try{
$theFirstName=Get-ADUser  -properties GivenName -Identity $samAccountName -ErrorAction Stop | select GivenName -ExpandProperty GivenName
}catch{$UserFound =  $false}

if(!($UserFound)){
Write-Output "USER: [ $userFirstName $userLastName ] NOT FOUND"
exit 0

}


try{
$theLastName=Get-ADUser  -properties Surname -Identity $samAccountName -ErrorAction Stop | select Surname -ExpandProperty Surname
}catch{}
Write-Output "USER INFORMATION REPORT"
Write-Output "-----------------------"
Write-Output "-----------------------"
Write-Output ""
Write-Output "FULL NAME:  ${theFirstName} ${theLastName}"
Write-Output "FIRST NAME: ${theFirstName}"
Write-Output "LAST  NAME: ${theLastName}"

try{
 $theTitle=Get-ADUser  -properties title -Identity $samAccountName -ErrorAction Stop | select title -ExpandProperty title
}catch{}

if($theTitle.Length -gt 0){
Write-Output "TITLE:  $theTitle"
}else{
Write-Output "TITLE:  [NONE]"
}


try{
$theManager=Get-ADUser -properties manager -Identity $samAccountName -ErrorAction Stop | select manager -ExpandProperty manager 
}catch{}

if($theManager.Length -gt 0){
Write-Output "MANAGER: $theManager"
}else{
Write-Output "MANAGER: [NONE]"
}


try{
 $theDepartment=Get-ADUser  -properties department -Identity $samAccountName -ErrorAction Stop | select department -ExpandProperty department 
}catch{}

if($theDepartment.Length -gt 0){
Write-Output "DEPARTMENT:  $theDepartment"
}else{
Write-Output "DEPARTMENT:  [NONE]"
}


try{
 $theDescription=Get-ADUser  -properties description -Identity $samAccountName -ErrorAction Stop | select description -ExpandProperty description
}catch{}

if($theDescription.Length -gt 0){
Write-Output "DESCRIPTION:  $theDescription"
}else{
Write-Output "DESCRIPTION:  [NONE]"
}


try{
 $theOfficePhone=Get-ADUser -properties OfficePhone -Identity $samAccountName -ErrorAction Stop | select OfficePhone -ExpandProperty OfficePhone 
}catch{}

if($theOfficePhone.Length -gt 0){
Write-Output "OFFICE PHONE:  $theOfficePhone"
}else{
Write-Output "OFFICE PHONE:  [NONE]"
}


try{
 $theMobilePhone=Get-ADUser  -properties MobilePhone -Identity $samAccountName -ErrorAction Stop | select MobilePhone -ExpandProperty MobilePhone 
}catch{}

if($theMobilePhone.Length -gt 0){
Write-Output "MOBILE PHONE:  $theMobilePhone"
}else{
Write-Output "MOBILE PHONE:  [NONE]"
}
Write-Output ""
Write-Output "USER GROUP MEMBERSHIP REPORT"
Write-Output "----------------------------------"
Get-ADPrincipalGroupMembership  $samAccountName | select name | ft -HideTableHeaders | where{$_ -ne ""}
Write-Output "----------------------------------"
Write-Output ""
try{
 $theExpirationDate=Get-ADUser -properties AccountExpirationDate -Identity $samAccountName -ErrorAction Stop | select AccountExpirationDate -ExpandProperty AccountExpirationDate 
 }catch{}

if($theExpirationDate.Length -gt 0){
Write-Output "ACCOUNT EXPIRES:  $theExpirationDate"
}else{
Write-Output "ACCOUNT EXPIRES:  [NO EXPIRATION DATE]"
}


try{
 $thePasswordSetDate=Get-ADUser -properties PasswordLastSet -Identity $samAccountName -ErrorAction Stop | select PasswordLastSet -ExpandProperty PasswordLastSet 
}catch{}


if($thePasswordSetDate.Length -gt 0){
Write-Output "PASSWORD SET DATE:  $thePasswordSetDate"
}else{
Write-Output "PASSWORD SET DATE:  [NONE]"
}


try{
 $theAccountStatus=Get-ADUser -properties Enabled -Identity $samAccountName -ErrorAction Stop | select Enabled -ExpandProperty Enabled 
}catch{}

if($theAccountStatus){
Write-Output "ACCOUNT ENABLED:  YES"
}else{
Write-Output "ACCOUNT ENABLED:  NO"
}


try{
 $theCreationDate=Get-ADUser  -properties Created -Identity $samAccountName -ErrorAction Stop | select Created -ExpandProperty Created 
}catch{}

Write-Output "Account Creation Date:  $theCreationDate"


try{
 $theUserSamAccounName=Get-ADUser  -properties SamAccountName -Identity $samAccountName -ErrorAction Stop | select SamAccountName -ExpandProperty SamAccountName 
}catch{}


Write-Output "SamAccountName:  $theUserSamAccounName"


try{
 $DN=Get-ADUser  -properties DistinguishedName -Identity $samAccountName -ErrorAction Stop | select DistinguishedName -ExpandProperty DistinguishedName 
}catch{}

 
Write-Output "DISTINGUISHED NAME:  $DN"
Write-Output ""
Write-Output "-----------------------"
Write-Output "-----------------------"

}



# Report information on a User Object
function GetUserAccountInfoFunction(){


$theExpirationDate=""
$theAccountStatus = $true
$thePasswordSetDate=""
$theCreationDate=""
$theUserSamAccounName=""
$theUserCnName=""

$UserFound =  $true

try{
$theFirstName=Get-ADUser  -properties GivenName -Identity $samAccountName -ErrorAction Stop | select GivenName -ExpandProperty GivenName
}catch{$UserFound =  $false}

if(!($UserFound)){
Write-Output "USER: [ $userFirstName $userLastName ] NOT FOUND"
exit 0

}


try{
$theLastName=Get-ADUser  -properties Surname -Identity $samAccountName -ErrorAction Stop | select Surname -ExpandProperty Surname
}catch{}
Write-Output "-----------------------"
Write-Output "USER INFORMATION REPORT"
Write-Output "-----------------------"
Write-Output ""
Write-Output "FULL NAME:  ${theFirstName} ${theLastName}"
Write-Output "FIRST NAME: ${theFirstName}"
Write-Output "LAST  NAME: ${theLastName}"


$UserExistsInLockedOutReport = $false

$TEMP_FILE_ONE = New-TemporaryFile

Search-AdAccount -LockedOut -UsersOnly | select -Property 'SamAccountName' | Format-Table -HideTableHeaders > $TEMP_FILE_ONE

$UserIsLockedOut = $false

$UserExistsInLockedOutReport = $false

ForEach ($line in (Get-Content "$TEMP_FILE_ONE")){
    if($line -match $samAccountName){
    $UserExistsInLockedOutReport = $true
    $UserIsLockedOut = $true
     }

     if($UserExistsInLockedOutReport){
     $UserExistsInLockedOutReport = $false
     $TheUserOjbect = Get-ADUser -Identity $samAccountName -Properties lockoutTime
     $LockOutTime = [datetime]::FromFileTime($TheUserOjbect.lockoutTime)

     }
}

Remove-Item -Path $TEMP_FILE_ONE -Force 2>&1 | out-null


if($UserIsLockedOut){
Write-Output "ACCOUNT LOCKED: $LockOutTime"
}else{
Write-Output "ACCOUNT NOT LOCKED"
}

try{
 $theExpirationDate=Get-ADUser -properties AccountExpirationDate -Identity $samAccountName -ErrorAction Stop | select AccountExpirationDate -ExpandProperty AccountExpirationDate 
 }catch{}

if($theExpirationDate.Length -gt 0){
Write-Output "ACCOUNT EXPIRES:  $theExpirationDate"
}else{
Write-Output "ACCOUNT EXPIRES:  [NO EXPIRATION DATE]"
}


try{
 $thePasswordSetDate=Get-ADUser -properties PasswordLastSet -Identity $samAccountName -ErrorAction Stop | select PasswordLastSet -ExpandProperty PasswordLastSet 
}catch{}


if($thePasswordSetDate.Length -gt 0){
Write-Output "PASSWORD SET DATE:  $thePasswordSetDate"
}else{
Write-Output "PASSWORD SET DATE:  [NONE]"
}


try{
 $theAccountStatus=Get-ADUser -properties Enabled -Identity $samAccountName -ErrorAction Stop | select Enabled -ExpandProperty Enabled 
}catch{}

if($theAccountStatus){
Write-Output "ACCOUNT ENABLED:  YES"
}else{
Write-Output "ACCOUNT ENABLED:  NO"
}


try{
 $theCreationDate=Get-ADUser  -properties Created -Identity $samAccountName -ErrorAction Stop | select Created -ExpandProperty Created 
}catch{}

Write-Output "Account Creation Date:  $theCreationDate"


try{
 $theUserSamAccounName=Get-ADUser  -properties SamAccountName -Identity $samAccountName -ErrorAction Stop | select SamAccountName -ExpandProperty SamAccountName 
}catch{}


Write-Output "SamAccountName:  $theUserSamAccounName"


try{
 $DN=Get-ADUser  -properties DistinguishedName -Identity $samAccountName -ErrorAction Stop | select DistinguishedName -ExpandProperty DistinguishedName 
}catch{}

 
Write-Output "DISTINGUISHED NAME:  $DN"
Write-Output ""
Write-Output "-----------------------"

}



function RenameExchangeAccountFunction()
{

PostivielyIdentifyUser

try{
$TheUser = Get-ADUser -Properties * -Identity "$samAccountName" -ErrorAction Stop
}catch{
Write-Output ""
Write-Output "User: ${userFirstName} ${userLastName} | Not Modified In Exchange"
Write-Output ""
Write-Output "Cannot Discover The User Sam Account Name"
return 
}

if($Debug){
Write-Output ""
Write-Output "User SamAccountName: $samAccountName"
Write-Output ""
}

try{
$TheUserPrincipalName = $TheUser.UserPrincipalName
}catch{
Write-Output ""
Write-Output "User: ${userFirstName} ${userLastName} | Not Modified In Exchange"
Write-Output ""
Write-Output "Cannot Discover The User Principal Name (email address)"
return 
}

if($Debug){
Write-Output ""
Write-Output "User's UserPrincipalName: $TheUserPrincipalName"
Write-Output ""
}

if($TheUserPrincipalName.Length -lt 4){
Write-Output ""
Write-Output "User: ${userFirstName} ${userLastName} | Not Modified In Exchange"
Write-Output ""
Write-Output "Cannot Discover A User Principal Name (email address)"
return 
}

$global:createObjectWorked = $false


$CimitraAgentLogonAccountInEmpty = [string]::IsNullOrWhiteSpace($CimitraAgentLogonAccountIn)
if($CimitraAgentLogonAccountInEmpty){
Write-Output ""
Write-Output "To Modify a User in Exchange, Specify The Parameter -CimitraAgentLogonAccountIn"
Write-Output ""
Write-Output "Example: -CimitraAgentLogonAccountIn 'CimitraAgent@example.com'"
Write-Output ""
return
}


$ExchangeSecurePasswordFileInEmpty = [string]::IsNullOrWhiteSpace($ExchangeSecurePasswordFileIn)
if($ExchangeSecurePasswordFileInEmpty){
Write-Output ""
Write-Output "To Modify a User in Exchange, Specify The Parameter -SecurePasswordFileIn"
Write-Output ""
Write-Output "Example: -SecurePasswordFileIn 'c:\passwords\password.txt'"
Write-Output ""
return
}

if(!(Test-Path $ExchangeSecurePasswordFileIn)){
Write-Output ""
Write-Output "The Secure Password File:"
Write-Output ""
Write-Output "$ExchangeSecurePasswordFileIn"
Write-Output ""
Write-Output "Is Not Accessible to This Script"
return
}

$CimitraAgentLogonAccountInEmpty = [string]::IsNullOrWhiteSpace($CimitraAgentLogonAccountIn)
if($CimitraAgentLogonAccountInEmpty){
Write-Output ""
Write-Output "To Modify a User in Exchange, Specify The Parameter -CimitraAgentLogonAccountIn"
Write-Output ""
Write-Output "Example: -CimitraAgentLogonAccountIn 'CimitraAgent@example.com'"
Write-Output ""
return
}


$ExchangeConnectionURIInEmpty = [string]::IsNullOrWhiteSpace($ExchangeConnectionURIIn)
if($ExchangeConnectionURIInEmpty){
Write-Output ""
Write-Output "To Modify a User in Exchange, Specify The Parameter -ExchangeConnectionURIIn"
Write-Output ""
Write-Output "Example: -ExchangeConnectionURIIn 'http://example-EXCH16.acme.internal/PowerShell/'"
Write-Output ""
return
}

$ExchangeDomainNameInEmpty = [string]::IsNullOrWhiteSpace($ExchangeDomainNameIn)
if($ExchangeDomainNameInEmpty){
Write-Output ""
Write-Output "To Modify a User in Exchange, Specify The Parameter -ExchangeDomainNameIn"
Write-Output ""
Write-Output "Example: -ExchangeDomainNameIn 'example.com'"
Write-Output ""
return
}


if($Debug){
Write-Output ""
Write-Output "All Required Parameters Have Been Input"
Write-Output ""
}


$username = "$CimitraAgentLogonAccountIn"

$pwdTxt = Get-Content "$ExchangeSecurePasswordFileIn"

$securePwd = $pwdTxt | ConvertTo-SecureString

if($Debug){
Write-Output ""
Write-Output "START: Creating Credential Object"
Write-Output ""
}


try{
$credObject = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $securePwd -ErrorAction Stop
}catch{
$err = "$_"

Write-Output ""
Write-Output "User: ${userFirstName} ${userLastName} | Not Modified In Exchange"
Write-Output ""
    if ($verboseOutputSet){
    Write-Output "[ERROR CREATING A CREDENTIAL OBJECT]"
    Write-Output "------------------------------------"
    Write-Output ""
    Write-Output "[ERROR MESSAGE BELOW]"
    Write-Output "-----------------------------"
    Write-Output ""
    Write-Output $err
    Write-Output ""
    Write-Output "-----------------------------"
    }
return
}

if($Debug){
Write-Output ""
Write-Output "FINISH: Created Credential Object"
Write-Output ""
}


if($Debug){
Write-Output ""
Write-Output "START: Creating Exchange Session"
Write-Output ""
}



try{
$global:ExchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $ExchangeConnectionURIIn -Authentication Kerberos -Credential $credObject -ErrorAction Stop
}catch{
$err = "$_"

Write-Output ""
Write-Output "User: ${userFirstName} ${userLastName} | Not Modified In Exchange"
Write-Output ""
    if ($verboseOutputSet){
    Write-Output "[ERROR CREATING AN EXCHANGE SESSION]"
    Write-Output "------------------------------------"
    Write-Output ""
    Write-Output "[ERROR MESSAGE BELOW]"
    Write-Output "-----------------------------"
    Write-Output ""
    Write-Output $err
    Write-Output ""
    Write-Output "-----------------------------"
    }
return
}


if($Debug){
Write-Output ""
Write-Output "FINISH: Created Exchange Session"
Write-Output ""
}

$global:exchangeSessionCreated = $true

#BLISS

if($Debug){
Write-Output ""
Write-Output "START: Importing Exchange Session"
Write-Output ""
}

try{
Import-PSSession $ExchangeSession -DisableNameChecking -ErrorAction Stop
}catch{
$err = "$_"

Write-Output ""
Write-Output "User: ${userFirstName} ${userLastName} | Not Modified In Exchange"
Write-Output ""
    if ($verboseOutputSet){
    Write-Output "[ERROR IMPORTING THE EXCHANGE SESSION]"
    Write-Output "--------------------------------------"
    Write-Output ""
    Write-Output "[ERROR MESSAGE BELOW]"
    Write-Output "-----------------------------"
    Write-Output ""
    Write-Output $err
    Write-Output ""
    Write-Output "-----------------------------"
    }
return
}


if($Debug){
Write-Output ""
Write-Output "FINISH: Imported Exchange Session"
Write-Output ""
}



if($newFirstNameInSet){
$GivenName = $NewFirstNameIn
}else{
$GivenName = $FirstNameIn
}


if($newLastNameInSet){
$Surname = $NewLastNameIn
}else{
$Surname = $LastNameIn
}


if($Debug){
Write-Output ""
Write-Output "START: Changing User First and Last Name"
Write-Output ""
}



try{
Set-User -Identity "$TheUserPrincipAlName" -FirstName "$GivenName" -LastName "$Surname" -DisplayName "$GivenName $Surname" -Name "$GivenName $Surname" -ErrorAction Stop
}catch{
$err = "$_"

Write-Output ""
Write-Output "User: ${userFirstName} ${userLastName} | Not Modified In Exchange"
Write-Output ""
    if ($verboseOutputSet){
    Write-Output "[ERROR MODIFYING THE EXCHANGE MAILBOX]"
    Write-Output "--------------------------------------"
    Write-Output ""
    Write-Output "[ERROR MESSAGE BELOW]"
    Write-Output "-----------------------------"
    Write-Output ""
    Write-Output $err
    Write-Output ""
    Write-Output "-----------------------------"
    }
return
}

if($Debug){
Write-Output ""
Write-Output "FINISH: Changed User First and Last Name"
Write-Output ""
}



Write-Output ""
Write-Output "User: ${userFirstName} ${userLastName} | Changed In Exchange To | User: $GivenName $Surname"

CALL_SLEEP

$PrimarySmtpAddressInEmpty = [string]::IsNullOrWhiteSpace($PrimarySmtpAddressIn)
if($PrimarySmtpAddressInEmpty){
# Nothing else to do if a new mailbox address is not specified
return
}

if($Debug){
Write-Output ""
Write-Output "START: Changing User's SMTP Address"
Write-Output ""
}


if($ExchangeOnSiteMailbox){

try{
Set-Mailbox -Identity "$TheUserPrincipalName" -EmailAddressPolicyEnabled $False -WindowsEmailAddress "$PrimarySmtpAddressIn" -PrimarySmtpAddress "$PrimarySmtpAddressIn"
}catch{
$err = "$_"

Write-Output ""
Write-Output "User: ${userFirstName} ${userLastName} | Not Modified In Exchange"
Write-Output ""
    if ($verboseOutputSet){
    Write-Output "[ERROR MODIFYING THE EXCHANGE MAILBOX]"
    Write-Output "--------------------------------------"
    Write-Output ""
    Write-Output "[ERROR MESSAGE BELOW]"
    Write-Output "-----------------------------"
    Write-Output ""
    Write-Output $err
    Write-Output ""
    Write-Output "-----------------------------"
    }
return
}




}else{


try{
Set-RemoteMailbox -Identity "$TheUserPrincipalName" -EmailAddressPolicyEnabled $False -WindowsEmailAddress "$PrimarySmtpAddressIn" -PrimarySmtpAddress "$PrimarySmtpAddressIn"
}catch{
$err = "$_"

Write-Output ""
Write-Output "User: ${userFirstName} ${userLastName} | Not Modified In Exchange"
Write-Output ""
    if ($verboseOutputSet){
    Write-Output "[ERROR MODIFYING THE EXCHANGE MAILBOX]"
    Write-Output "--------------------------------------"
    Write-Output ""
    Write-Output "[ERROR MESSAGE BELOW]"
    Write-Output "-----------------------------"
    Write-Output ""
    Write-Output $err
    Write-Output ""
    Write-Output "-----------------------------"
    }
return
}


if($Debug){
Write-Output ""
Write-Output "FINISHED: Changed User's SMTP Address"
Write-Output ""
}


Write-Output ""
Write-Output "User: ${userFirstName} ${userLastName} | Changed In Exchange To | User: $GivenName $Surname | Email: $PrimarySmtpAddressIn"

return 
}

}


function CreateExchangeAccount()
{

$global:createObjectWorked = $false

$CimitraAgentLogonAccountInEmpty = [string]::IsNullOrWhiteSpace($CimitraAgentLogonAccountIn)
if($CimitraAgentLogonAccountInEmpty){
Write-Output ""
Write-Output "To Add a User to Exchange, Specify The Parameter -CimitraAgentLogonAccountIn"
Write-Output ""
Write-Output "Example: -CimitraAgentLogonAccountIn 'CimitraAgent@example.com'"
Write-Output ""
return
}

$ExchangeSecurePasswordFileInEmpty = [string]::IsNullOrWhiteSpace($ExchangeSecurePasswordFileIn)
if($ExchangeSecurePasswordFileInEmpty){
Write-Output ""
Write-Output "To Add a User to Exchange, Specify The Parameter -SecurePasswordFileIn"
Write-Output ""
Write-Output "Example: -SecurePasswordFileIn 'c:\passwords\password.txt'"
Write-Output ""
return
}

if(!(Test-Path $ExchangeSecurePasswordFileIn)){
Write-Output ""
Write-Output "The Secure Password File:"
Write-Output ""
Write-Output "$ExchangeSecurePasswordFileIn"
Write-Output ""
Write-Output "Is Not Accessible to This Script"
return
}

$CimitraAgentLogonAccountInEmpty = [string]::IsNullOrWhiteSpace($CimitraAgentLogonAccountIn)
if($CimitraAgentLogonAccountInEmpty){
Write-Output ""
Write-Output "To Add a User to Exchange, Specify The Parameter -CimitraAgentLogonAccountIn"
Write-Output ""
Write-Output "Example: -CimitraAgentLogonAccountIn 'CimitraAgent@example.com'"
Write-Output ""
return
}


$ExchangeConnectionURIInEmpty = [string]::IsNullOrWhiteSpace($ExchangeConnectionURIIn)
if($ExchangeConnectionURIInEmpty){
Write-Output ""
Write-Output "To Add a User to Exchange, Specify The Parameter -ExchangeConnectionURIIn"
Write-Output ""
Write-Output "Example: -ExchangeConnectionURIIn 'http://example-EXCH16.acme.internal/PowerShell/'"
Write-Output ""
return
}

$ExchangeDomainNameInEmpty = [string]::IsNullOrWhiteSpace($ExchangeDomainNameIn)
if($ExchangeDomainNameInEmpty){
Write-Output ""
Write-Output "To Add a User to Exchange, Specify The Parameter -ExchangeDomainNameIn"
Write-Output ""
Write-Output "Example: -ExchangeDomainNameIn 'example.com'"
Write-Output ""
return
}

try{
$TheContext = Get-ADOrganizationalUnit -Identity $UserContextIn -ErrorAction Stop 2> $null
}catch{
Write-Output ""
Write-Output "To Add a User to Exchange, Specify The Parameter -ContextIn with a valid Context"
Write-Output ""
Write-Output "This should be an OU location in your Active Directory Tree"
Write-Output ""
Write-Output "Example: -ContextIn 'OU=USERS,DC=cimitra,DC=com'"
Write-Output ""
return
}


$Credentials = "$userPassword"

try{
$SecureCred = $Credentials | ConvertTo-SecureString -AsPlainText -Force -ErrorAction Stop
}catch{
$err = "$_"

Write-Output ""
Write-Output "User: ${userFirstName} ${userLastName} | Not Added to Exchange"
Write-Output ""
    if ($verboseOutputSet){
    Write-Output "[ERROR CONVERTING CREDENTIALS]"
    Write-Output "------------------------------"
    Write-Output ""
    Write-Output "[ERROR MESSAGE BELOW]"
    Write-Output "-----------------------------"
    Write-Output ""
    Write-Output $err
    Write-Output ""
    Write-Output "-----------------------------"
    }
return
}


$username = "$CimitraAgentLogonAccountIn"

$pwdTxt = Get-Content "$ExchangeSecurePasswordFileIn"

$securePwd = $pwdTxt | ConvertTo-SecureString

try{
$credObject = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $securePwd -ErrorAction Stop
}catch{
$err = "$_"

Write-Output ""
Write-Output "User: ${userFirstName} ${userLastName} | Not Added to Exchange"
Write-Output ""
    if ($verboseOutputSet){
    Write-Output "[ERROR CREATING A CREDENTIAL OBJECT]"
    Write-Output "------------------------------------"
    Write-Output ""
    Write-Output "[ERROR MESSAGE BELOW]"
    Write-Output "-----------------------------"
    Write-Output ""
    Write-Output $err
    Write-Output ""
    Write-Output "-----------------------------"
    }
return
}


try{
$global:ExchangeSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $ExchangeConnectionURIIn -Authentication Kerberos -Credential $credObject -ErrorAction Stop
}catch{
$err = "$_"

Write-Output ""
Write-Output "User: ${userFirstName} ${userLastName} | Not Added to Exchange"
Write-Output ""
    if ($verboseOutputSet){
    Write-Output "[ERROR CREATING AN EXCHANGE SESSION]"
    Write-Output "------------------------------------"
    Write-Output ""
    Write-Output "[ERROR MESSAGE BELOW]"
    Write-Output "-----------------------------"
    Write-Output ""
    Write-Output $err
    Write-Output ""
    Write-Output "-----------------------------"
    }
return
}



$global:exchangeSessionCreated = $true

try{
Import-PSSession $ExchangeSession -DisableNameChecking -ErrorAction Stop
}catch{
$err = "$_"

Write-Output ""
Write-Output "User: ${userFirstName} ${userLastName} | Not Added to Exchange"
Write-Output ""
    if ($verboseOutputSet){
    Write-Output "[ERROR IMPORTING THE EXCHANGE SESSION]"
    Write-Output "--------------------------------------"
    Write-Output ""
    Write-Output "[ERROR MESSAGE BELOW]"
    Write-Output "-----------------------------"
    Write-Output ""
    Write-Output $err
    Write-Output ""
    Write-Output "-----------------------------"
    }
return
}


# Create Mailbox

if($ExchangeOnSiteMailbox)
{

try{
New-Mailbox -Name "$userFirstName $userLastName" -Password $SecureCred -UserPrincipalName $ExchangeUserIn@$ExchangeDomainNameIn -OnPremisesOrganizationalUnit $UserContextIn -ACLableSyncedObjectEnabled -ResetPasswordOnNextLogon $true -FirstName $userFirstName -LastName $userLastName -ErrorAction Stop 2>$null
}catch{
$err = "$_"

Write-Output ""
Write-Output "User: ${userFirstName} ${userLastName} | Not Added to Exchange"
Write-Output ""
    if ($verboseOutputSet){
    Write-Output "[ERROR CREATING THE EXCHANGE MAILBOX]"
    Write-Output "-------------------------------------"
    Write-Output ""
    Write-Output "[ERROR MESSAGE BELOW]"
    Write-Output "-----------------------------"
    Write-Output ""
    Write-Output $err
    Write-Output ""
    Write-Output "-----------------------------"
    }
return
}


}else{

try{
New-RemoteMailbox -Name "$userFirstName $userLastName" -Password $SecureCred -UserPrincipalName $ExchangeUserIn@$ExchangeDomainNameIn -OnPremisesOrganizationalUnit $UserContextIn -ACLableSyncedObjectEnabled -ResetPasswordOnNextLogon $true -FirstName $userFirstName -LastName $userLastName -ErrorAction Stop 2>$null
}catch{
$err = "$_"

Write-Output ""
Write-Output "User: ${userFirstName} ${userLastName} | Not Added to Exchange"
Write-Output ""
    if ($verboseOutputSet){
    Write-Output "[ERROR CREATING THE EXCHANGE MAILBOX]"
    Write-Output "-------------------------------------"
    Write-Output ""
    Write-Output "[ERROR MESSAGE BELOW]"
    Write-Output "-----------------------------"
    Write-Output ""
    Write-Output $err
    Write-Output ""
    Write-Output "-----------------------------"
    }
return
}

}

Write-Output ""
Write-Output "User: ${userFirstName} ${userLastName} | Added to Exchange"

CALL_SLEEP

$identifyUser = $true

try{
$TheUser = Get-ADUser -Identity "CN=${userFirstName} ${userLastName},$UserContextIn" -ErrorAction Stop 
}catch{
$identifyUser = $false
}

if($identifyUser)
{
$global:samAccountName = $TheUser.sAMAccountName
$global:samAccountNameInSet = $true
PostivielyIdentifyUser
}

$global:createObjectWorked = $true


return 
}



function CreateActiveDirectoryAccount(){

$global:createObjectWorked = $false

if($samAccountNameInSet){
$TheSamAccountName = $samAccountName
}else{
# Make the samAccountName variable from a combination of the user's first and last name
$TheSamAccountName = ($userFirstName+$userLastName).ToLower()
}


try{
$TheContext = Get-ADOrganizationalUnit -Identity $UserContextIn -ErrorAction Stop 2> $null
}catch{
Write-Output ""
Write-Output "To Add a User to Active Directory, Specify The Parameter -ContextIn with a Valid Context"
Write-Output ""
Write-Output "This should be an OU location in your Active Directory Tree"
Write-Output ""
Write-Output "Example: -ContextIn 'OU=USERS,DC=cimitra,DC=com'"
Write-Output ""
return
}


$UserDoesNotExist = $false

try{
$TheUser = Get-ADUser -Identity $TheSamAccountName  -ErrorAction Stop 2> $null
}catch{
$UserDoesNotExist = $true
}

if(!($UserDoesNotExist)){
Write-Output ""
Write-Output "A User With The Userid: [ $TheSamAccountName ] Already Exists"
Write-Output ""
$global:samAccountName = $TheSamAccountName
$global:samAccountNameInSet = $true
GetUserInfoFunction
exit 1
}


# Write-Output "New-ADUser -Name $userFirstName $userLastName -GivenName $userFirstName -Surname $userLastName -SamAccountName $TheSamAccountName -AccountPassword (ConvertTo-SecureString $userPassword -AsPlainText -force) -passThru -path $contextIn -Enabled $true | out-null"

# Create the new user
$createUserResult = $true
try{
New-ADUser -Name "$userFirstName $userLastName" -GivenName $userFirstName -Surname $userLastName -SamAccountName $TheSamAccountName -AccountPassword (ConvertTo-SecureString $userPassword -AsPlainText -force) -passThru -path $UserContextIn -Enabled $true -ErrorAction Stop | out-null
}catch{
$err = "$_"
$createUserResult = $false
}

if($createUserResult){
Write-Output "New User: ${userFirstName} ${userLastName} | Created"
CALL_SLEEP
}else{
Write-Output "User: ${userFirstName} ${userLastName} | Not Created"
Write-Output ""
    if ($verboseOutputSet){
    Write-Output "[ERROR CREATING THE ACTIVE DIRECTORY ACCOUNT]"
    Write-Output "----------------------------------------------------"
    Write-Output ""
    Write-Output "[ERROR MESSAGE BELOW]"
    Write-Output "-----------------------------"
    Write-Output ""
    Write-Output $err
    Write-Output ""
    Write-Output "-----------------------------"
return
}

}

$TheUser = Get-ADUser -Identity "CN=$userFirstName $userLastName,$UserContextIn" 2> $null

 
$SAM = $TheUser.saMAccountName
$global:samAccountName = "$SAM"
$global:samAccountNameInSet = $true
$global:createObjectWorked = $true

}


# Are we adding a User to Exchange or Active Directory
function DetermineActionOrder(){

if($AddToExchange){
CreateExchangeAccount
    if(!($createObjectWorked)){
    exit 1
    }
$global:modifyAnADUser = $true
}

if($AddToActiveDirectory){
CreateActiveDirectoryAccount

    if(!($createObjectWorked)){
    exit 
    }

$global:modifyAnADUser = $true

}


}


function CheckForExclusions(){

if($AddToActiveDirectory){
return
}

if($IgnoreExcludeGroup){
return
}


$ExcludeGroupGUIDInEmpty = [string]::IsNullOrWhiteSpace($ExcludeGroupGUIDIn)


if($ExcludeGroupGUIDInEmpty){
$ExcludeGroupGUID = $TheExcludeGroup
}else{
$ExcludeGroupGUID = $ExcludeGroupGUIDIn
}


if($ExcludeGroupGUID.Length -lt 8){
return
}

# Check for group's existence
$checkGroupResult = $true
try{
$TheGroupName = Get-ADGroup -Identity $ExcludeGroupGUID  -ErrorAction Stop
}catch{
$err = "$_"
$checkGroupResult = $false
}

if((!$checkGroupResult)){
Write-Output ""
Write-Output "Exclusion Group Specified Does Not Exist"
Write-Output ""
    if ($verboseOutputSet){
    Write-Output "[ERROR CANNOT PROCEED]"
    Write-Output "----------------------------------------------------"
    Write-Output ""
    Write-Output "[ERROR MESSAGE BELOW]"
    Write-Output "-----------------------------"
    Write-Output ""
    Write-Output $err
    Write-Output ""
    Write-Output "-----------------------------"
exit 1

}
}


IdentifyUser
#BLISS
$user = $samAccountName
$TheUserObject = Get-ADUser -Identity $samAccountName 
$TheUserFirstname = $TheUserObject.GivenName
$TheUserLastname = $TheUserObject.Surname
$group = Get-ADGroup -Identity $ExcludeGroupGUID
$groupDN = $group.DistinguishedName

$userDetails = Get-ADUser -Identity $user -Properties MemberOf

	if ($userDetails -eq $null) {
		# The User Does Not Even Exist
        return
	} 
	else {
		$inGroup = $userDetails.MemberOf | Where-Object {$_.Contains($groupDN)}

		if ($inGroup -ne $null) {
			Write-Output "--------------------------------------------------------------------------------"
            Write-Output "Insufficent Rights to Administer User: $TheUserFirstname $TheUserLastname"
            Write-Output "--------------------------------------------------------------------------------"
            Write-Output ""
            exit 0
		}
		else {
	    # The user does not exist in the group
		}
	}


}


# See if the User to modify is in the Exclusion Group
CheckForExclusions


# Are we adding a User to Exchange or Active Directory
if($AddToExchange -or $AddToActiveDirectory)
{
DetermineActionOrder
$ObjectCreationActionTaken = $true
}


# Update an object for an already created User in Active Directory
function UpdateCreatedUserProperty($IDENTITY_IN,$AD_ATTRIBUTE_NAME,$AD_ATTRIBUTE_VALUE,$AD_ATTRIBUTE_LABEL)
{

# Write-Output "Set-ADUser -Identity '$IDENTITY_IN' $AD_ATTRIBUTE_NAME '$AD_ATTRIBUTE_VALUE'"

if(!($UseExchangeMethod)){

    $parameterHash = @{
        "Identity"=$IDENTITY_IN
        $AD_ATTRIBUTE_NAME=$AD_ATTRIBUTE_VALUE
    }

}else{

    $parameterHash = @{
        'Identity'='$ExchangeUserIn@$ExchangeDomainNameIn'
        $AD_ATTRIBUTE_NAME=$AD_ATTRIBUTE_VALUE
    }

}

$modifyUserResult = $true
try{
Set-ADUser @parameterHash -ErrorAction Stop 2> $null
}catch{
$modifyUserResult = $false
$err = "$_"
}

if($modifyUserResult){
Write-Output ""
Write-Output "User: ${userFirstName} ${userLastName} | ${AD_ATTRIBUTE_LABEL} Changed to: ${AD_ATTRIBUTE_VALUE}"
return
}else{
Write-Output ""
Write-Output "User: ${userFirstName} ${userLastName} | ${AD_ATTRIBUTE_LABEL} NOT Changed"
Write-Output ""
    if ($verboseOutputSet){
    Write-Output "[ERROR CREATING THE MODIFYING: ${AD_ATTRIBUTE_LABEL}]"
    Write-Output "----------------------------------------------------------------"
    Write-Output ""
    Write-Output "[ERROR MESSAGE BELOW]"
    Write-Output "-----------------------------"
    Write-Output ""
    Write-Output $err
    Write-Output ""
    Write-Output "-----------------------------"

    return
}


}

}


# Reset a User's password in Active Directory
function ChangePassword(){


$TheUserPasswordIn = $userPassword

$modifyUserResult = $true

# Modify the user
try{
Set-ADAccountPassword -Identity $samAccountName -Reset -NewPassword (ConvertTo-SecureString -AsPlainText ${TheUserPasswordIn} -Force) -ErrorAction Stop
}catch{
$modifyUserResult = $false
$err = "$_"
}

# See if the -ForcePasswordReset variable was passed in
if ($ForcePasswordReset){
$global:forcePasswordResetSet = $true
}

# If exit code from the New-ADUser command was "True" then show a success message
if ($modifyUserResult)
{
Write-Output "User: ${userFirstName} ${userLastName} | Password Changed"
}else{
Write-Output ""
Write-Output "User: ${userFirstName} ${userLastName} | Password Was NOT Changed"
Write-Output ""
    if ($verboseOutputSet){
    Write-Output "[ERROR MESSAGE BELOW]"
    Write-Output "-----------------------------"
    Write-Output ""
    Write-Output $err
    Write-Output ""
    Write-Output "-----------------------------"
    }
return
}

}

$modifyUserResult = $true

if($ForcePasswordReset){


# Force an immediate password reset
try{
 Set-ADUser -Identity  $samAccountName -ChangePasswordAtLogon $true -ErrorAction Stop 2>$null
 }catch{
 $modifyUserResult = $false
 }



 if($modifyUserResult){
 Write-Output ""
 Write-Output "NOTE: This user will be required to change their password the next time they log in."
 Write-Output ""
 }

}


# Disable a User Account

function DisableUserAccount()
{

$modifyUserResult = $true

# Modify the user

try{
Disable-ADAccount -Identity $samAccountName  -ErrorAction Stop
 }catch{
 $modifyUserResult = $false
 $err = "$_"
 }

 if ($modifyUserResult){
 Write-Output ""
 Write-Output "User: ${userFirstName} ${userLastName} | Account Disabled"
 Write-Output ""
 }else{
 Write-Output ""
 Write-Output "User: ${userFirstName} ${userLastName} | Account Not Disabled"
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

}

# Enable a User account
function EnableUserAccount()
{

$modifyUserResult = $true

# Modify the user

try{
Enable-ADAccount -Identity $samAccountName  -ErrorAction Stop
 }catch{
 $modifyUserResult = $false
 $err = "$_"
 }

 if ($modifyUserResult){
 Write-Output ""
 Write-Output "User: ${userFirstName} ${userLastName} | Account Enabled"
 Write-Output ""
 }else{
 Write-Output ""
 Write-Output "User: ${userFirstName} ${userLastName} | Account Not Enabled"
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

}

# Remove the lock on a User Account
function RemoveUserAccountLock()
{

$modifyUserResult = $true

# Modify the user

try{

Unlock-ADAccount -Identity $samAccountName -ErrorAction Stop
 }catch{
 $modifyUserResult = $false
 $err = "$_"
 }

 if ($modifyUserResult){
 Write-Output ""
 Write-Output "User: ${userFirstName} ${userLastName} | Account Unlocked"
 Write-Output ""
 }else{
 Write-Output ""
 Write-Output "User: ${userFirstName} ${userLastName} | Account Not Unlocked"
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

}


# Remove the Expiration Date on a User account
function RemoveUserExpirationDate()
{

$modifyUserResult = $true

# Modify the user

try{

Clear-ADAccountExpiration -Identity $samAccountName -ErrorAction Stop
 }catch{
 $modifyUserResult = $false
 $err = "$_"
 }

 if ($modifyUserResult){
 Write-Output ""
 Write-Output "User: ${userFirstName} ${userLastName} | Account Expiration Removed"
 Write-Output ""

 }else{
 Write-Output ""
 Write-Output "User: ${userFirstName} ${userLastName} | Account Expiration NOT Removed"
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

}

# Check the last Password Set Date on a User
function CheckUserPasswordDate(){

$modifyUserResult = $true

try{
$theResult = Get-ADUser -properties PasswordLastSet  -Identity $samAccountName | Select-Object PasswordLastSet -ExpandProperty PasswordLastSet -ErrorAction Stop
 
}catch{
$modifyUserResult = $false
$err = "$_"
}

if($modifyUserResult){
 Write-Output ""
 Write-Output "Password Reset for User: ${userFirstName} ${userLastName} | Was On: ${theResult}"
 Write-Output ""
 }else{
 Write-Output ""
    Write-Output "User: ${userFirstName} ${userLastName} | Cannot Check Password Reset Date"
    Write-Output ""
    if ($verboseOutputSet){
    Write-Output "[ERROR MESSAGE BELOW]"
    Write-Output "-----------------------------"
    Write-Output ""
    Write-Output $err
    Write-Output ""
    Write-Output "-----------------------------"
    }
return

 }

 
}


# Set a User Password
function SetPassword()
{

$UserPasswordInEmpty = [string]::IsNullOrWhiteSpace($UserPasswordIn)
if($UserPasswordInEmpty){
$TheUserPassword = $defaultPasswordIn
}else{
$TheUserPassword = $UserPasswordIn
}

$modifyUserResult = $true

# Modify the user
try{
Set-ADAccountPassword -Identity $samAccountName -Reset -NewPassword (ConvertTo-SecureString -AsPlainText ${TheUserPassword} -Force) -ErrorAction Stop
}catch{
$modifyUserResult = $false
$err = "$_"
}

# See if the -forcePasswordReset variable was passed in
if ($ForcePasswordReset){
$global:forcePasswordResetSet = $true
}

# If exit code from the New-ADUser command was "True" then show a success message
if ($modifyUserResult)
{
Write-Output ""
Write-Output "User: ${userFirstName} ${userLastName} | Password Set"
}else{
Write-Output ""
Write-Output "User: ${userFirstName} ${userLastName} | Password Was NOT Changed"
Write-Output ""
    if ($verboseOutputSet){
    Write-Output "[ERROR MESSAGE BELOW]"
    Write-Output "-----------------------------"
    Write-Output ""
    Write-Output $err
    Write-Output ""
    Write-Output "-----------------------------"
    }
return
}

$modifyUserResult = $true

if($ForcePasswordReset){


# Force an immediate password reset
try{
 Set-ADUser -Identity  $samAccountName -ChangePasswordAtLogon $true -ErrorAction Stop 2>$null
 }catch{
 $modifyUserResult = $false
 }
 if($modifyUserResult){
 Write-Output ""
 Write-Output "NOTE: This user will be required to change their password the next time they log in."
 Write-Output ""
 }

$modifyUserResult = $true
 
try{
$theResult = Get-ADUser -properties PasswordLastSet  -Identity $samAccountName | Select-Object PasswordLastSet -ExpandProperty PasswordLastSet 
 
}catch{
$modifyUserResult = $false
$err = "$_"
}

}


if($modifyUserResult){
 Write-Output ""
 Write-Output "Password Reset for User: ${userFirstName} ${userLastName} | Was On: ${theResult}"
 Write-Output ""
 }

}

# Rename a user's SamAccountName
function ChangeSamAccountName(){

$modifyUserResult = $true

# Modify the user
try{
Set-ADUser -Identity $samAccountName -SamAccountName $NewSamAccountNameIn 2>$null
}catch{
$modifyUserResult = $false
$err = "$_"
}

# If exit code from the New-ADUser command was "True" then show a success message
if ($modifyUserResult)
{
Write-Output ""
Write-Output "User: ${userFirstName} ${userLastName} | Userid: $samAccountName Changed To: $NewSamAccountNameIn"
$global:samAccountName = $NewSamAccountNameIn
}else{
Write-Output ""
Write-Output "User: ${userFirstName} ${userLastName} | Userid: $samAccountName NOT Changed To: $NewSamAccountNameIn"
Write-Output ""
    if ($verboseOutputSet){
    Write-Output "[ERROR MESSAGE BELOW]"
    Write-Output "-----------------------------"
    Write-Output ""
    Write-Output $err
    Write-Output ""
    Write-Output "-----------------------------"
    }
return
}



}

# Change a User's First Name
function ChangeFirstName(){

$modifyUserResult = $true

# Modify the user
try{
Get-ADUser -Identity $samAccountName  | Rename-ADObject -NewName "${NewFirstNameIn} ${userLastName}" -ErrorAction Stop
}catch{
$modifyUserResult = $false
$err = "$_"
}

try{
Get-ADUser -Identity $samAccountName  | Set-ADUser -DisplayName "${NewFirstNameIn} ${userLastName}" -ErrorAction Stop
}catch{
$modifyUserResult = $false
$err = "$_"
}

try{
Get-ADUser -Identity $samAccountName  | Set-ADUser -GivenName ${NewFirstNameIn} -ErrorAction Stop
}catch{
$modifyUserResult = $false
$err = "$_"
}

# BLISS
# If exit code from the New-ADUser command was "True" then show a success message
if($modifyUserResult)
{
Write-Output ""
Write-Output "User: ${userFirstName} ${userLastName} | Name Changed to: ${NewFirstNameIn} $userLastName"
$global:userFirstName = $NewFirstNameIn
}else{
Write-Output ""
Write-Output "User: ${userFirstName} ${userLastName} | First Name NOT Changed to: $NewFirstNameIn"
Write-Output ""
    if ($verboseOutputSet){
    Write-Output "[ERROR MESSAGE BELOW]"
    Write-Output "-----------------------------"
    Write-Output ""
    Write-Output $err
    Write-Output ""
    Write-Output "-----------------------------"
    }
return
}


}


# Change a User's Last Name
function ChangeLastName(){

$modifyUserResult = $true

# Modify the user
try{
Get-ADUser -Identity $samAccountName  | Rename-ADObject -NewName "${userFirstName} ${newLastNameIn}" -ErrorAction Stop
}catch{
$modifyUserResult = $false
$err = "$_"
}

try{
Get-ADUser -Identity $samAccountName  | Set-ADUser -DisplayName "${userFirstName} ${newLastNameIn}" -ErrorAction Stop
}catch{
$modifyUserResult = $false
$err = "$_"
}

try{
Get-ADUser -Identity $samAccountName  | Set-ADUser -Surname ${newLastNameIn} -ErrorAction Stop
}catch{
$modifyUserResult = $false
$err = "$_"
}


# If exit code from the New-ADUser command was "True" then show a success message
if($modifyUserResult)
{
Write-Output ""
Write-Output "User: ${userFirstName} ${userLastName} | Name Changed to: ${userFirstName} $NewLastNameIn"
$global:userLastName = $NewLastNameIn
}else{
Write-Output ""
Write-Output "User: ${userFirstName} ${userLastName} | Last Name NOT Changed to: $NewLastNameIn"
Write-Output ""
    if ($verboseOutputSet){
    Write-Output "[ERROR MESSAGE BELOW]"
    Write-Output "-----------------------------"
    Write-Output ""
    Write-Output $err
    Write-Output ""
    Write-Output "-----------------------------"
    }
return
}


}

# Change a User's Manager
function ChangeUserManager(){

Write-Output "User: ${userFirstName} ${userLastName} | Setting Manager Attribute"

if($managerSamAccountNameSet){

$modifyUserResult = $true

try{
Set-ADUser -Identity $samAccountName -manager $ManagerSamAccountNameIn -ErrorAction Stop  2>$null
}catch{
$modifyUserResult = $false
$err = "$_"
}


if($modifyUserResult)
{

Write-Output ""
Write-Output "User: ${userFirstName} ${userLastName} | Manager Changed to: $ManagerSamAccountNameIn"
return
}else{
Write-Output ""
Write-Output "User: ${userFirstName} ${userLastName} | Manager NOT Changed"
Write-Output ""
    if ($verboseOutputSet){
    Write-Output "[ERROR MESSAGE BELOW]"
    Write-Output "-----------------------------"
    Write-Output ""
    Write-Output $err
    Write-Output ""
    Write-Output "-----------------------------"
    }
return
}

}



$modifyUserResult = $true

if($managerContextSet -and $managerNameSet){

$LookupWorked = $true
try{
$TheManager = Get-ADUser -Identity "CN=${ManagerFirstNameIn} ${ManagerLastNameIn},${ManagerContextIn}" -ErrorAction Stop 2> $null
}catch{
$LookupWorked = $false
$modifyUserResult = $false
$err = "$_"
}



if($LookupWorked){

try{
Set-ADUser -Identity $samAccountName  -Manager "CN=${ManagerFirstNameIn} ${ManagerLastNameIn},${ManagerContextIn}" -ErrorAction Stop 2>$null
}catch{
$modifyUserResult = $false
$err = "$_"
}


if($modifyUserResult)
{
Write-Output ""
Write-Output "User: ${userFirstName} ${userLastName} | Manager Changed to: ${ManagerFirstNameIn} ${ManagerLastNameIn}"
Write-Output ""
Write-Output "Manager Distinguished Name: CN=${ManagerFirstNameIn} ${ManagerLastNameIn},${ManagerContextIn}"
return
}else{
Write-Output ""
Write-Output "User: ${userFirstName} ${userLastName} | Manager NOT Changed"
Write-Output ""
    if ($verboseOutputSet){
    Write-Output "[ERROR MESSAGE BELOW]"
    Write-Output "-----------------------------"
    Write-Output ""
    Write-Output $err
    Write-Output ""
    Write-Output "-----------------------------"
    }
return
}

if(!($SearchForManager)){
return
}

}
    
    
}


$UserSearchReturn = SearchForUserSamAccountName "$ManagerFirstNameIn" "$ManagerLastNameIn"

$UserSearchErrorState = $UserSearchReturn.ErrorState
if(!($UserSearchErrorState)){

$SAM = $UserSearchReturn.SamName
$UserFullName = $UserSearchReturn.FullName
$FullyDistinguishedName = $UserSearchReturn.FullyDistinguishedName
Write-Output ""
Write-Output "Found Manager/User: $UserFullName"
Write-Output ""
Write-Output "The Manager Userid: $SAM"
Write-Output ""
Write-Output "Distinguished Name: $FullyDistinguishedName"
}else{
Write-Output "Could Not Positively Identify a Unique User: $ManagerFirstNameIn $ManagerLastNameIn"
Write-Output ""
Write-Output "Try Using the User's SamAccountName"
$SearchUtilityExists = Test-Path "$PSScriptRoot\SearchForUser.ps1"
if($SearchUtilityExists)
{
. $PSScriptRoot\SearchForUser.ps1 -FirstNameIn ${ManagerFirstNameIn} -LastNameIn ${ManagerLastNameIn}
}
return

}


$modifyUserResult = $true


try{
Set-ADUser -Identity $samAccountName -Manager $SAM -ErrorAction Stop 2>$null
}catch{
$modifyUserResult = $false
$err = "$_"
}


if($modifyUserResult)
{
Write-Output ""
Write-Output "User: ${userFirstName} ${userLastName} | Manager Changed to: $ManagerFirstNameIn $ManagerLastNameIn"
return
}else{
Write-Output ""
Write-Output "User: ${userFirstName} ${userLastName} | Manager NOT Changed"
Write-Output ""
    if ($verboseOutputSet){
    Write-Output "[ERROR MESSAGE BELOW]"
    Write-Output "-----------------------------"
    Write-Output ""
    Write-Output $err
    Write-Output ""
    Write-Output "-----------------------------"
    }
return
}



}


# Remove a User Object
function RemoveUserObject(){

# If a Confirmation Word was required, test to see if the user typed in the correct word
if($ConfirmWordRequired)
{

if(!($ConfirmWord -ccontains $ConfirmWordIn)){
Write-Output ""
Write-Output "Confirm Word Incorrect, Unable to Proceed With Remove User"
Write-Output ""
}

}

IdentifyUser



$SAM = Get-ADUser -Identity $samAccountName

$TheUserFirstname = $SAM.GivenName
$TheUserLastname = $SAM.Surname
$TheUserDistinguisedName = $SAM.DistinguishedName


# Use Remove-ADUser to remove the user
$deleteUserResult = $true

try{
Remove-ADUser -Identity $TheUserDistinguisedName -Confirm:$False -ErrorAction Stop
}catch{
$deleteUserResult = $false
$err = "$_"
}

# If good result, display success message
if ($deleteUserResult)
{
Write-Output ""
Write-Output "------------------------------------------------------------------"
Write-Output ""
Write-Output "User: ${TheUserFirstname} ${TheUserLastname} | Was Removed"
Write-Output ""
Write-Output "------------------------------------------------------------------"
}else{
Write-Output ""
Write-Output "------------------------------------------------------------------"
Write-Output ""
Write-Output "User: ${TheUserFirstname} ${TheUserLastname} | Was NOT Removed"
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


}

# Set the Expiration Date for a User
function SetUserExpirationDate(){


IdentifyUser

$SAM = $samAccountName
$TheUserFirstname = $SAM.GivenName
$TheUserLastname = $SAM.Surname
$TheUserDistinguisedName = $SAM.DistinguishedName

# Write-Output "SAM = $SAM"

# Write-Output "Set-ADUser -Identity $samAccountName -AccountExpirationDate $ExpirationDateIn"

$modifyUserResult = $true

# Modify the user
try{
Set-ADUser -Identity $samAccountName -AccountExpirationDate $ExpirationDateIn -ErrorAction Stop
}catch{
$modifyUserResult = $false
$err = "$_"
}


# If exit code from the Set-ADUser command was "True" then show a success message
if ($modifyUserResult)
{
Write-Output ""
Write-Output "User: ${userFirstName} ${userLastName} | Expire Date Changed to: ${ExpirationDateIn}"
Write-Output ""
}else{
Write-Output ""
Write-Output "User: ${userFirstName} ${userLastName} | Expire Date NOT Changed"
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



}


if($FindAndShowUserInfo){
GetUserInfoFunction
exit 0
}


if($GetUserAccountStatus){
GetUserAccountInfoFunction
exit 0
}




# Change/Update User Properties
function IterateThroughUserPropertiesToChange(){

if(!($ObjectCreationActionTaken)){
IdentifyUser
}

if(!($ObjectCreationActionTaken)){

    if($userPasswordSet){
    ChangePassword
    }

    if($ResetUserPassword){
    ChangePassword
    }

    if($newFirstNameInSet){
        if($ExchangeRemoteMailbox -or $ExchangeOnSiteMailbox){
        RenameExchangeAccountFunction
        }else{
        ChangeFirstName
        }
    }

    if($newLastNameInSet){
        if($ExchangeRemoteMailbox -or $ExchangeOnSiteMailbox){
        RenameExchangeAccountFunction
        }else{
        ChangeLastName
        }
    }

    if($newSamAccountNameInSet){
    ChangeSamAccountName
    }
}

if($descriptionInSet){

    if(!($AddToExchange)){
    UpdateCreatedUserProperty $samAccountName "Description" "$DescriptionIn" "Description"
    }else{
    Set-User -Identity $ExchangeUserIn@$ExchangeDomainNameIn -Description $DescriptionIn
    }
}

if($departmentNameInSet){

    if(!($AddToExchange)){
    UpdateCreatedUserProperty $samAccountName "Department" "$DepartmentNameIn" "Department Name"
    }else{
    Set-User -Identity $ExchangeUserIn@$ExchangeDomainNameIn -Department $DepartmentNameIn
    }
}

if($titleInSet){

    if(!($AddToExchange)){
    UpdateCreatedUserProperty $samAccountName "Title" "$TitleIn" "Title"
    }else{
    Set-User -Identity $ExchangeUserIn@$ExchangeDomainNameIn -Title $TitleIn
    }
    
}

if($mobilePhoneInSet){

    if(!($AddToExchange)){
    UpdateCreatedUserProperty $samAccountName "MobilePhone" "$MobilePhoneIn" "Mobile Phone"
    }else{
    Set-User -Identity $ExchangeUserIn@$ExchangeDomainNameIn -MobilePhone $MobilePhoneIn
    }
}

if($officePhoneInSet){

    if(!($AddToExchange)){
    UpdateCreatedUserProperty $samAccountName "OfficePhone" "$OfficePhoneIn" "Office Phone"
    }else{
        if($EnableExchangeUpdates){
            $global:UseExchangeMethod = $true
            UpdateCreatedUserProperty $samAccountName "OfficePhone" "$OfficePhoneIn" "Office Phone"
            $global:UseExchangeMethod = $false
        }else{
            Set-User -Identity $ExchangeUserIn@$ExchangeDomainNameIn -OfficePhone $OfficePhoneIn
        }
    }
}

if($managerNameSet){
    if(!($AddToExchange)){
    ChangeUserManager
    }else{
    Set-User -Identity $ExchangeUserIn@$ExchangeDomainNameIn -Manager $ManagerSamAccountNameIn@$ExchangeDomainNameIn
    }
}

if($exchangeSessionCreated){
try{
Remove-PSSession $ExchangeSession 2> $null
}catch{}
}

if($RemoveExpirationDate){
RemoveUserExpirationDate
}

if($UnlockAccount){
RemoveUserAccountLock
}

if($DisableUser){
DisableUserAccount
}

if($EnableUser){
EnableUserAccount
}

if($CheckPasswordDate){
CheckUserPasswordDate
}

if($expireUserObject){
SetUserExpirationDate
}

if($groupGUIDsInSet){
ProcessGroupGuids
IdentifyUser
    if($RemoveUserFromGroupGUIDsIn){
    RemoveUserFromGroups
    }else{
    AddUserToGroups
    }


}

if($GetUserInfo){
GetUserInfoFunction
}

if($RemoveUser){
GetUserInfoFunction
RemoveUserObject
}

}

IterateThroughUserPropertiesToChange
Write-Output ""




