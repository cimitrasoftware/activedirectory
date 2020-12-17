# Move a Computer in Active Directory to a new OU
# Authors: Tay Kratzer tay@cimitra.com, Jennifer Stuller @ Tiffin University
# Date: 12/16/20
# -------------------------------------------------

# Testing Examples

# .\FindAndMoveComputer.ps1 -showErrors -ComputerNameIn "WIN-COMPUTER-ONE" -NewContext "OU=STUDENTS,OU=DEMOCOMPUTERS,DC=cimitrademo,DC=local"

# .\FindAndMoveComputer.ps1.ps1 -showErrors -ComputerNameIn "WIN-COMPUTER-ONE" -NewContext "OU=IT_DEPARTMENT,OU=DEMOCOMPUTERS,DC=cimitrademo,DC=local"


Param(
    [string] $ComputerNameIn,
    [string] $NewContextIn
 )

$ComputerNameInSet = $false
$NewContextInSet = $false
$verboseOutputSet = $false
$MoveComputerResult = $true


if (Write-Output "$args" | Select-String -CaseSensitive "-showErrors" ){
$verboseOutputSet = $true
}

if($NewContextIn.Length -gt 2){
$NewContextInSet = $true
}

if($ComputerNameIn.Length -gt 2){
$ComputerNameInSet = $true
}


# Show Help
function ShowHelp{
$scriptName = Split-Path -leaf $PSCommandpath
Write-Host ""
Write-Host "Find a Computer and Move the Computer In Active Directory to a New Context"
Write-Host ""
Write-Host "[ HELP ]"
Write-Host ""
Write-Host ".\$scriptName -h or -help"
Write-Host ""
Write-Host "[ SCRIPT USAGE ]"
Write-Host ""
Write-Host ".\$scriptName  -ComputerNameIn <current computer name> -NewContextIn <Current Active Directory context>"
Write-Host ""
Write-Host "[ EXAMPLES ]"
Write-Host ""
Write-Host "Example: .\$scriptName -ComputerNameIn WIN7BOX -NewContextIn OU=HELDESK,O=STAFF,OU=CIMITRA,DC=cimitrademo,DC=com"
Write-Host ""
Write-Host "[ ERROR HANDLING ]"
Write-Host ""
Write-Host "-showErrors = Show Error Messages"
Write-Host ""
Write-Host "Example: .\$scriptName -showErrors -ComputerNameIn WIN7BOX -NewContextIn OU=HELDESK,O=STAFF,OU=CIMITRA,DC=cimitrademo,DC=com"
Write-Host ""
exit 0
}

if (Write-Output $args | Select-String "\-h\b|\-help\b" )
{
ShowHelp
}


# This script expects 2 arguments
if (!( $ComputerNameInSet )){ 
ShowHelp
 }

# -------------------------------------------------

if (!( $NewContextInSet )){ 
ShowHelp
 }
# -------------------------------------------------


## Get friendly names for the current computer name and context
#-------------------------------------------------------------#
try{
# This gets the computers full name and context
$CurrentComputerIn = Get-ADComputer -Filter "Name -like '$ComputerNameIn'" | Select-Object -ExpandProperty DistinguishedName
# This parses off the computer's context
$CurrentComputerContext = ($CurrentComputerIn -split ',',2)[-1]
# This parses off the computer's name with CN=<COMPUTER NAME>
$CurrentComputerAndCN = ($CurrentComputerIn -split ',',2)[0]
# This parses off the "CN=" portion of the computer name
$ComputerNameActualName = ($CurrentComputerAndCN -split '=',2)[1]
}catch{}
#-------------------------------------------------------------#

##Determine if the computer was actually found, by getting the length of a specific attribute
$ObjectLength = ((Get-ADComputer -Filter "Name -like '$ComputerNameIn'").DistinguishedName).Length
#-------------------------------------------------------------#

# If the Computer Object length is less than 2, the computer wasn't found, exit the script
if($ObjectLength -lt 2){

Write-Output ""
Write-Output "------------------------------------------------------------------"
Write-Output ""
Write-Output "Cannot Locate A Computer By The Name Of: $ComputerNameIn" 
Write-Output ""
Write-Output "------------------------------------------------------------------"

exit 1
}
#-------------------------------------------------------------#

## Main function
#-------------------------------------------------------------#
try{
Get-ADComputer -Filter "Name -like '$ComputerNameIn'" | Select-Object -ExpandProperty DistinguishedName | Move-ADObject -TargetPath "$NewContextIn"
}catch{
$moveComputerResult = $false
$err = "$_"
}

if($moveComputerResult)
{
Write-Output ""
Write-Output "------------------------------------------------------------------"
Write-Output "The Computer Input: $ComputerNameActualName"
Write-Output ""
Write-Output "Moved From Context: $CurrentComputerContext "
Write-Output ""
Write-Output "To The New Context: $NewContextIn"
Write-Output "------------------------------------------------------------------"
}else{
Write-Output ""
Write-Output "------------------------------------------------------------------"
Write-Output "The Computer: $ComputerNameIn was NOT moved to a New Context: $NewContextIn"
Write-Output "------------------------------------------------------------------"

    if ($verboseOutputSet){
    Write-Output "[ERROR MESSAGE BELOW]"
    Write-Output "-----------------------------"
    Write-Output ""
    Write-Output $err
    Write-Output ""
    Write-Output "-----------------------------"
    exit 1
    }

}
#-------------------------------------------------------------#