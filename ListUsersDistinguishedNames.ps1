# Check Password Set Date in Active Directory
# Co-Author: Tay Kratzer tay@cimitra.com


$verboseOutputSet = $false

# If a settings.cfg file exists read it and get the Active Directory Context from this file
if((Test-Path ${PSScriptRoot}\config_reader.ps1)){

if((Test-Path ${PSScriptRoot}\settings.cfg))
{
$CONFIG_IO="${PSScriptRoot}\config_reader.ps1"

. $CONFIG_IO

$CONFIG=(ReadFromConfigFile "${PSScriptRoot}\settings.cfg")

}

}
# -------------------------------------------------


# Show Help
function ShowHelp{
$scriptName = Split-Path -leaf $PSCommandpath
Write-Host ""
Write-Host "List All Users in Active Directory In Every OU"
Write-Host ""
Write-Host "[ HELP ]"
Write-Host ""
Write-Host ".\$scriptName -h or -help"
Write-Host ""
Write-Host "[ SCRIPT USAGE ]"
Write-Host ""
Write-Host ".\$scriptName"
Write-Host ""
Write-Host "[ EXAMPLE ]"
Write-Host ""
Write-Host "Example: .\$scriptName"
Write-Host ""
Write-Host "[ ERROR HANDLING ]"
Write-Host ""
Write-Host "-showErrors = Show Error Messages"
Write-Host ""
Write-Host "Example: .\$scriptName -showErrors"
Write-Host ""
exit 0
}

if (Write-Output $args | Select-String "\-h\b|\-help\b" )
{
ShowHelp
}

if (Write-Output "$args" | Select-String -CaseSensitive "-showErrors" ){
$verboseOutputSet = $true
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
            $output += $arr[0] -replace '^.*$', 'CN=$0'
            $output += ($arr | select -Skip 1 | select -SkipLast 1) -replace '^.*$', 'OU=$0'
            $output += ($arr | ? { $_ -like '*.*' }) -split '\.' -replace '^.*$', 'DC=$0'
            $output -join ','
        }
        else {
            foreach ($cn in $CanonicalName) {
                $arr = $cn -split '/'
                [array]::reverse($arr)
                $output = @()
                $output += $arr[0] -replace '^.*$', 'CN=$0'
                $output += ($arr | select -Skip 1 | select -SkipLast 1) -replace '^.*$', 'OU=$0'
                $output += ($arr | ? { $_ -like '*.*' }) -split '\.' -replace '^.*$', 'DC=$0'
                $output -join ','
            }
        }
    }
}


$context = "OU=DEMOUSERS,DC=cimitrademo,DC=local" 

try{
Write-Output ""
Write-Output "Following is a list of all of the users in the AD tree."
Write-Output ""
Write-Output "------------------------------------------------------"
@(Get-ADUser -Filter * ) | Get-DistinguishedName
$global:actionResult = $true
}catch{
$global:actionResult = $false
$err = "$_"
$global:err = $err
}

if($actionResult){
Write-Output ""
Write-Output "------------------------------------------------------"
}else{
Write-Output "Error: Unable to List Users in Active Directory"
Write-Output ""
Write-Output "------------------------------------------------------"
    if ($verboseOutputSet){
    Write-Output "[ERROR MESSAGE BELOW]"
    Write-Output "-----------------------------"
    Write-Output ""
    Write-Output $err
    Write-Output ""
    Write-Output "-----------------------------"
    }

}

