

function UPDATE_SCRIPTS{
$installScript = "${PSScriptRoot}\install.ps1"
Write-Output "$installScript ${PSScriptRoot} -skipSetup"
try{
Set-Location -Path ${PSScriptRoot}
}catch{
Write-Output ""
Write-Output "Error Changing to Directory ${PSScriptRoot}"
Write-Output ""
return 0
}

.\install.ps1 "${PSScriptRoot}" "-skipSetup"

}

write-output "START: INSTALL LATEST VERSION OF CIMITRA/ACTIVE DIRECTORY SCRIPTS"
write-output "-----------------------------------------------------------------"
UPDATE_SCRIPTS
write-output "------------------------------------------------------------------"
write-output "FINISH: INSTALL LATEST VERSION OF CIMITRA/ACTIVE DIRECTORY SCRIPTS"

