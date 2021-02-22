# Move a Computer in Active Directory to a new OU
# Author: Tay Kratzer tay@cimitra.com
# Date: 2/18/21
# -------------------------------------------------

# Testing Examples

# .\MoveComputer.ps1 -showErrors -CurrentContextIn "OU=IT_DEPARTMENT,OU=DEMOCOMPUTERS,DC=cimitrademo,DC=local" -ComputerNameIn "WIN-COMPUTER-ONE" -NewContext "OU=STUDENTS,OU=DEMOCOMPUTERS,DC=cimitrademo,DC=local"

# .\MoveComputer.ps1 -showErrors -CurrentContextIn "OU=STUDENTS,OU=DEMOCOMPUTERS,DC=cimitrademo,DC=local" -ComputerNameIn "WIN-COMPUTER-ONE" -NewContext "OU=IT_DEPARTMENT,OU=DEMOCOMPUTERS,DC=cimitrademo,DC=local"


Param(
   [string] $ComputerNameIn,
   [string] $CurrentContextIn,
   [string] $NewContextIn,
   [switch] $ShowErrors
 )


$ComputerNameInSet = $false
$CurrentContextInSet = $false
$NewContextInSet = $false
$verboseOutputSet = $false
$MoveComputerResult = $true


if ($ShowErrors){
$verboseOutputSet = $true
}

if($CurrentContextIn.Length -gt 2){
$CurrentContextInSet = $true
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
Write-Host "Move a Computer In Active Directory to a New Context"
Write-Host ""
Write-Host "[ HELP ]"
Write-Host ""
Write-Host ".\$scriptName -h or -help"
Write-Host ""
Write-Host "[ SCRIPT USAGE ]"
Write-Host ""
Write-Host ".\$scriptName  -ComputerNameIn <current computer name> -CurrentContextIn <Current Active Directory context for computer>  -NewContextIn <Current Active Directory context>"
Write-Host ""
Write-Host "[ EXAMPLES ]"
Write-Host ""
Write-Host "Example: .\$scriptName -ComputerNameIn WIN7BOX  -CurrentContextIn OU=HELODESK=,O=STUDENTS,OU=CIMITRA,DC=cimitrademo,DC=com -NewContextIn OU=HELDESK,O=STAFF,OU=CIMITRA,DC=cimitrademo,DC=com"
Write-Host ""
Write-Host "[ ERROR HANDLING ]"
Write-Host ""
Write-Host "-ShowErrors = Show Error Messages"
Write-Host ""
Write-Host "Example: .\$scriptName -ShowErrors -ComputerNameIn WIN7BOX -CurrentContextIn OU=HELPDESK=,O=STUDENTS,OU=CIMITRA,DC=cimitrademo,DC=com -NewContextIn OU=HELDESK,O=STAFF,OU=CIMITRA,DC=cimitrademo,DC=com"
Write-Host ""
exit 0
}

if (Write-Output $args | Select-String "\-h\b|\-help\b" )
{
ShowHelp
}


# This script expects 3 arguments
if (!( $ComputerNameInSet )){ 
ShowHelp
 }
# -------------------------------------------------

if (!( $CurrentContextInSet )){ 
ShowHelp
 }
# -------------------------------------------------

if (!( $NewContextInSet )){ 
ShowHelp
 }
# -------------------------------------------------

 
# Use Move-ADObject to move computer
try{
Move-ADObject -Identity "CN=$ComputerNameIn,$CurrentContextIn" -TargetPath "$NewContextIn" -Confirm:$False
}catch{
$moveComputerResult = $false
$err = "$_"
}


if($moveComputerResult)
{
Write-Output ""
Write-Output "------------------------------------------------------------------"
Write-Output "The Computer: $ComputerNameIn was Moved to a New Context"
Write-Output ""
Write-Output "Previous Context: $CurrentContextIn"
Write-Output ""
Write-Output "New Context: $NewContextIn"
Write-Output "------------------------------------------------------------------"
}else{
Write-Output ""
Write-Output "------------------------------------------------------------------"
Write-Output "The Computer: $ComputerNameIn was NOT moved to a New Context"
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