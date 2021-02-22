# Search for a Computer in Active Directory
# Co-Author: Tay Kratzer tay@cimitra.com
# Date: 2/18/21

Param(
    [string] $ComputerNameIn,
    [switch] $ShowErrors
 )


 $verboseOutputSet = $false


# Show Help
function ShowHelp{
$scriptName = Split-Path -leaf $PSCommandpath
Write-Host ""
Write-Host "Search for a Computer in Active Directory In Every OU"
Write-Host ""
Write-Host "[ HELP ]"
Write-Host ""
Write-Host ".\$scriptName -h or -help"
Write-Host ""
Write-Host "[ SCRIPT USAGE ]"
Write-Host ""
Write-Host ".\$scriptName -ComputerNameIn"
Write-Host ""
Write-Host "[ EXAMPLE ]"
Write-Host ""
Write-Host "Example: .\$scriptName -ComputerNameIn WIN-COMPUTER-ONE"
Write-Host ""
Write-Host "[ ERROR HANDLING ]"
Write-Host ""
Write-Host "-ShowErrors = Show Error Messages"
Write-Host ""
Write-Host "Example: .\$scriptName -ShowErrors -ComputerNameIn WIN-COMPUTER-ONE"
Write-Host ""
exit 0
}

if (Write-Output $args | Select-String "\-h\b|\-help\b" )
{
ShowHelp
}

if ($ShowErrors){
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


Write-Output ""
Write-Output "Computers with the name [ $ComputerNameIn ] in the AD tree."
Write-Output "-----------------------------------------------------------"
try{
@(Get-ADComputer -Filter "Name -like '$ComputerNameIn' " ) | Get-DistinguishedName
$global:actionResult = $true
}catch{
$err = "$_"
$global:err = $err
$global:actionResult = $false
}


if($actionResult){
Write-Output "-----------------------------------------------------------"
}else{
Write-Output "Error: Unable to List Computers in Active Directory"
Write-Output ""
Write-Output "-----------------------------------------------------------"
    if ($verboseOutputSet){
    Write-Output "[ERROR MESSAGE BELOW]"
    Write-Output "-----------------------------"
    Write-Output ""
    Write-Output $err
    Write-Output ""
    Write-Output "-----------------------------"
    }

}


