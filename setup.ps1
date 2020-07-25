# Check Password Set Date in Active Directory
# Author: Tay Kratzer tay@cimitra.com
# -------------------------------------------------
# New-Variable -Name CIMITRA_SERVER_ADDRESS -Value '127.0.0.1'
# $CIMITRA_SERVER_ADDRESS='127.0.0.1'

# If a settings.cfg file exists read it and get the Active Directory Context from this file

$TEMP_FILE=New-TemporaryFile
$GLOBAL_TEMP_FILE_TWO=New-TemporaryFile
$global:cimitraCfgFound = $false
$global:cimitraAgentId = "Undefined"


if (Get-Content C:\cimitra\cimitra.cfg){
(Get-Content C:\cimitra\cimitra.cfg) | % {$_ -replace '"',''}|Out-File $TEMP_FILE
$global:cimitraCfgFound = $true
}

# Show Help
function ShowHelp{
$scriptName = Split-Path -leaf $PSCommandpath
Write-Host ""
Write-Host "Cimitra Active Directory Integration Setup Script"
Write-Host ""
Write-Host "Help"
Write-Host ""
Write-Host ".\$scriptName -h or -help"
Write-Host ""
Write-Host "Script Usage"
Write-Host ""
Write-Host ".\$scriptName (This will present a menu)"
Write-Host ""
exit 0
}

if (Write-Output $args | Select-String "\-h\b|\-help\b" )
{
ShowHelp
}


function CREATE_DEFAULT_CONNECTION_VARIABLES{

if((Test-Path ${PSScriptRoot}\config_reader.ps1)){

if((Test-Path ${PSScriptRoot}\settings.cfg))
{

$CONFIG_IO="${PSScriptRoot}\config_reader.ps1"

. $CONFIG_IO

$CONFIG=(ReadFromConfigFile "${PSScriptRoot}\settings.cfg")

if($cimitraCfgFound){
$AGENTCONFIG=(ReadFromConfigFile "$TEMP_FILE")
}

# If the setting is in the settings.cfg file, go with that setting
$CONFIRM_ADDRESS=(ConfirmFromConfigFile "${PSScriptRoot}\settings.cfg" "CIMITRA_SERVER_ADDRESS")

if ( $CONFIRM_ADDRESS ) 
{ 
Set-Variable -Name CIMITRA_SERVER_ADDRESS -Value "$CONFIG$CIMITRA_SERVER_ADDRESS" 
}
else{

# If the setting is in NOT in the settings.cfg file. look for a setting in the cimagent.cfg file
        if($cimitraCfgFound){

            $CONFIRM_HOST=(ConfirmFromConfigFile "$TEMP_FILE" "CIMITRA_HOST")

            if ($CONFIRM_HOST){
            WriteToConfigFile "${PSScriptRoot}\settings.cfg" "CIMITRA_SERVER_ADDRESS" "$AGENTCONFIG$CIMITRA_HOST"
            Set-Variable -Name CIMITRA_SERVER_ADDRESS -Value $AGENTCONFIG$CIMITRA_HOST
            }else{
            WriteToConfigFile "${PSScriptRoot}\settings.cfg" "CIMITRA_SERVER_ADDRESS" "127.0.0.1"
            Set-Variable -Name CIMITRA_SERVER_ADDRESS -Value '127.0.0.1' 
            }

          }else{
            WriteToConfigFile "${PSScriptRoot}\settings.cfg" "CIMITRA_SERVER_ADDRESS" "127.0.0.1"
            Set-Variable -Name CIMITRA_SERVER_ADDRESS -Value '127.0.0.1' 
          }

}

 

$CONFIRM_PORT=(ConfirmFromConfigFile "${PSScriptRoot}\settings.cfg" "CIMITRA_SERVER_PORT")

if ( $CONFIRM_PORT ) 
{ 
Set-Variable -Name CIMITRA_SERVER_PORT -Value "$CONFIG$CIMITRA_SERVER_PORT" }
else{
# If the setting is in NOT in the settings.cfg file. look for a setting in the cimagent.cfg file
        if($cimitraCfgFound){

            $CONFIRM_PORT=(ConfirmFromConfigFile "$TEMP_FILE" "CIMITRA_PORT")

            if ($CONFIRM_PORT){
            WriteToConfigFile "${PSScriptRoot}\settings.cfg" "CIMITRA_SERVER_PORT" "$AGENTCONFIG$CIMITRA_PORT"
            Set-Variable -Name CIMITRA_SERVER_PORT -Value "$AGENTCONFIG$CIMITRA_PORT"
            }else{
            WriteToConfigFile "${PSScriptRoot}\settings.cfg" "CIMITRA_SERVER_PORT" "443"
            Set-Variable -Name CIMITRA_SERVER_PORT -Value '443' 
            }

          }else{
            WriteToConfigFile "${PSScriptRoot}\settings.cfg" "CIMITRA_SERVER_PORT" "443"
            Set-Variable -Name CIMITRA_SERVER_PORT -Value '443' 
          }

}


$CONFIRM_AGENT_CONFIG_FILE=(ConfirmFromConfigFile "${PSScriptRoot}\settings.cfg" "CIMITRA_AGENT_CONFIG_FILE" )

if ( $CONFIRM_AGENT_CONFIG_FILE ){ 

Set-Variable -Name CIMITRA_AGENT_CONFIG_FILE -Value "$CONFIG$CIMITRA_AGENT_CONFIG_FILE" 

(Get-Content "$CONFIG$CIMITRA_AGENT_CONFIG_FILE" ) | % {$_ -replace '"',''}|Out-File $GLOBAL_TEMP_FILE_TWO

$CONFIGURED_AGENT_CONFIG=(ReadFromConfigFile "$GLOBAL_TEMP_FILE_TWO") 2>&1 | out-null

$global:cimitraAgentId = "$CONFIGURED_AGENT_CONFIG$CIMITRA_ID"

Remove-Item -Path $GLOBAL_TEMP_FILE_TWO -Force 2>&1 | out-null

}
else{

        if($cimitraCfgFound){

                $CONFIRM_ID=(ConfirmFromConfigFile "$TEMP_FILE" "CIMITRA_ID")
                if ($CONFIRM_ID){
                WriteToConfigFile "${PSScriptRoot}\settings.cfg" "CIMITRA_AGENT_CONFIG_FILE" "C:\cimitra\cimitra.cfg" 
                $global:cimitraAgentId = "$AGENTCONFIG$CIMITRA_ID"
                }
        }
 
}



Remove-Item -Path $TEMP_FILE -Force 2>&1 | out-null

Remove-Item -Path $GLOBAL_TEMP_FILE_TWO -Force 2>&1 | out-null



$CONFIRM_ADMIN=(ConfirmFromConfigFile "${PSScriptRoot}\settings.cfg" "CIMITRA_SERVER_ADMIN_ACCOUNT")

if ( $CONFIRM_ADMIN ) 
{ 
Set-Variable -Name CIMITRA_SERVER_ADMIN_ACCOUNT -Value $CONFIG$CIMITRA_SERVER_ADMIN_ACCOUNT }
else{
Set-Variable -Name CIMITRA_SERVER_ADMIN_ACCOUNT -Value 'admin@cimitra.com' 
}

$CONFIRM_PASSWORD=(ConfirmFromConfigFile "${PSScriptRoot}\settings.cfg" "CIMITRA_SERVER_ADMIN_PASSWORD")

if ( $CONFIRM_PASSWORD ) 
{ 
Set-Variable -Name CIMITRA_SERVER_ADMIN_PASSWORD -Value $CONFIG$CIMITRA_SERVER_ADMIN_PASSWORD }
else{
Set-Variable -Name CIMITRA_SERVER_ADMIN_PASSWORD -Value 'changeme' 
}


}

}

 

}

function CALL_ERROR_EXIT{
$ErrorMessageIn=$args[0]
Write-Output ""
Write-Host "ERROR: $ErrorMessageIn" -ForegroundColor red -BackgroundColor white
Write-Output ""
exit 1
}

function UPDATE_SCRIPTS{
$isntallScript = "${PSScriptRoot}\install.ps1"
Write-Output "$isntallScript ${PSScriptRoot} -skipSetup"
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






function PROMPT_FOR_AD_USER{

write-output ""
write-output "START: CONFIGURE ACTIVE DIRECTORY USERS CONTEXT"
write-output "-----------------------------------------------"
$CONFIG_IO="${PSScriptRoot}\config_reader.ps1"

. $CONFIG_IO

$CONFIG=(ReadFromConfigFile "${PSScriptRoot}\settings.cfg") 2>&1 | out-null

Write-Output ""
Write-Output "Active Directory Users Context"
Write-Output ""
$Context = Read-Host -Prompt "$CONFIG$AD_USER_CONTEXT (Enter to Accept)" 

if($Context.Length -gt 2){
$script:AD_USER_CONTEXT="$Context"
WriteToConfigFile "${PSScriptRoot}\settings.cfg" "AD_USER_CONTEXT" "$Context"
Write-Host "Active Directory Users Context: $Context" -ForegroundColor blue -BackgroundColor white
Write-Output ""
}else{
WriteToConfigFile "${PSScriptRoot}\settings.cfg" "AD_USER_CONTEXT" "$AD_USER_CONTEXT"
Write-Output ""
Write-Host "Active Directory Users Context: $AD_USER_CONTEXT" -ForegroundColor blue -BackgroundColor white
}

write-output ""
write-output "------------------------------------------------"
write-output "FINISH: CONFIGURE ACTIVE DIRECTORY USERS CONTEXT"
write-output ""

}

function PROMPT_FOR_AD_COMPUTER{

write-output ""
write-output "START: CONFIGURE ACTIVE DIRECTORY COMPUTERS CONTEXT"
write-output "---------------------------------------------------"
$CONFIG_IO="${PSScriptRoot}\config_reader.ps1"

. $CONFIG_IO

$CONFIG=(ReadFromConfigFile "${PSScriptRoot}\settings.cfg") 2>&1 | out-null

Write-Output ""
Write-Output "Active Directory Computers Context"
Write-Output ""
$Context = Read-Host -Prompt "$CONFIG$AD_COMPUTER_CONTEXT (Enter to Accept)" 

if($Context.Length -gt 2){
$script:AD_COMPUTER_CONTEXT="$Context"
WriteToConfigFile "${PSScriptRoot}\settings.cfg" "AD_COMPUTER_CONTEXT" "$Context"
Write-Host "Active Directory Computers Context: $Context" -ForegroundColor blue -BackgroundColor white
Write-Output ""
}else{
WriteToConfigFile "${PSScriptRoot}\settings.cfg" "AD_COMPUTER_CONTEXT" "$AD_COMPUTER_CONTEXT"
Write-Output ""
Write-Host "Active Directory Users Context: $AD_COMPUTER_CONTEXT" -ForegroundColor blue -BackgroundColor white
}

write-output ""
write-output "----------------------------------------------------"
write-output "FINISH: CONFIGURE ACTIVE DIRECTORY COMPUTERS CONTEXT"
write-output ""

}

function PROMPT_FOR_CIMITRA_SERVER_CREDENTIALS{

write-output ""
write-output "START: CONFIGURE CIMITRA INTEGRATION ADMIN USER"
write-output "-----------------------------------------------"

# Write-Output "cimitraAgentId = $cimitraAgentId"

$CONFIG_IO="${PSScriptRoot}\config_reader.ps1"

. $CONFIG_IO

$CONFIG=(ReadFromConfigFile "${PSScriptRoot}\settings.cfg") 2>&1 | out-null

Write-Output ""
$Server = Read-Host -Prompt "Cimitra Server Address: $CONFIG$CIMITRA_SERVER_ADDRESS (Enter to Accept)" 

if($Server.Length -gt 2){
$script:CIMITRA_SERVER_ADDRESS="$Server"
WriteToConfigFile "${PSScriptRoot}\settings.cfg" "CIMITRA_SERVER_ADDRESS" "$Server"
Write-Host "Server Address: $Server" -ForegroundColor blue -BackgroundColor white
Write-Output ""
}else{
WriteToConfigFile "${PSScriptRoot}\settings.cfg" "CIMITRA_SERVER_ADDRESS" "$CIMITRA_SERVER_ADDRESS"
Write-Output ""
Write-Host "Server Address: $CIMITRA_SERVER_ADDRESS" -ForegroundColor blue -BackgroundColor white
}

Write-Output ""
$Port = Read-Host -Prompt "Cimitra Server Port: $CIMITRA_SERVER_PORT (Enter to Accept)" 

if($Port.Length -gt 2){
$script:CIMITRA_SERVER_PORT="$Port"
WriteToConfigFile "${PSScriptRoot}\settings.cfg" "CIMITRA_SERVER_PORT" "$Port"
Write-Host "Server Port: $Port" -ForegroundColor blue -BackgroundColor white
}else{
WriteToConfigFile "${PSScriptRoot}\settings.cfg" "CIMITRA_SERVER_PORT" "$CIMITRA_SERVER_PORT"
Write-Output ""
Write-Host "Server Port: $CIMITRA_SERVER_PORT" -ForegroundColor blue -BackgroundColor white
}

Write-Output ""
$Admin = Read-Host -Prompt "Cimitra Server Admin Account: $CIMITRA_SERVER_ADMIN_ACCOUNT (Enter to Accept)" 

if($Admin.Length -gt 2){
$script:CIMITRA_SERVER_ADMIN_ACCOUNT="$Admin"
WriteToConfigFile "${PSScriptRoot}\settings.cfg" "CIMITRA_SERVER_ADMIN_ACCOUNT" "$Admin"
Write-Host "Admin Account: $Admin" -ForegroundColor blue -BackgroundColor white
}else{
WriteToConfigFile "${PSScriptRoot}\settings.cfg" "CIMITRA_SERVER_ADMIN_ACCOUNT" "$CIMITRA_SERVER_ADMIN_ACCOUNT"
Write-Output ""
Write-Host "Admin Account: $CIMITRA_SERVER_ADMIN_ACCOUNT" -ForegroundColor blue -BackgroundColor white
}

Write-Output ""
$Pass = Read-Host -AsSecureString -Prompt "Cimitra Server Admin Password: (Enter to Accept Current Password)" 


if($Pass.Length -gt 2){

$plainPwdIn =[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Pass))

$script:CIMITRA_SERVER_ADMIN_PASSWORD="$plainPwdIn"

WriteToConfigFile "${PSScriptRoot}\settings.cfg" "CIMITRA_SERVER_ADMIN_PASSWORD" "$plainPwdIn"
Write-Host "Admin Password Set" -ForegroundColor blue -BackgroundColor white
}else{
WriteToConfigFile "${PSScriptRoot}\settings.cfg" "CIMITRA_SERVER_ADMIN_PASSWORD" "$CIMITRA_SERVER_ADMIN_PASSWORD"
Write-Output ""
Write-Host "Admin Password Set" -ForegroundColor blue -BackgroundColor white
}


Write-Output ""
$Config = Read-Host -Prompt "Cimitra Agent Config File: $CIMITRA_AGENT_CONFIG_FILE (Enter to Accept)" 

if($Config.Length -gt 2){
$script:CIMITRA_AGENT_CONFIG_FILE="$Config"
WriteToConfigFile "${PSScriptRoot}\settings.cfg" "CIMITRA_AGENT_CONFIG_FILE" "$Config"
Write-Host "Cimitra Agent Config File: $Config" -ForegroundColor blue -BackgroundColor white
}else{
WriteToConfigFile "${PSScriptRoot}\settings.cfg" "CIMITRA_AGENT_CONFIG_FILE" "$CIMITRA_AGENT_CONFIG_FILE"
Write-Output ""
Write-Host "Cimitra Agent Config File: $CIMITRA_AGENT_CONFIG_FILE" -ForegroundColor blue -BackgroundColor white
}

write-output ""
write-output "------------------------------------------------"
write-output "FINISH: CONFIGURE CIMITRA INTEGRATION ADMIN USER"
write-output ""

}

function CREATE_CIMITRA_FOLDER_ENTITY{

$FolderNameIn=$args[0]
$FolderDescriptionIn=$args[1]
$ParentFolderIdIn=$args[2]

$URL = "$uri/apps"

$response = Invoke-WebRequest -Uri "${URL}" `
-Method "POST" `
-Headers @{
"Authorization"="Bearer $token"
} `
-ContentType "application/json" `
-Body "{`"type`":2,`"status`":`"active`",`"description`":`"${FolderDescriptionIn}`",`"name`":`"${FolderNameIn}`",`"parentFolderId`":`"${ParentFolderIdIn}`"}"

}

function CHECK_FOR_EXISTING_APP{

$ParentFolderIdIn=$args[0]
$ExcludeFolderIdIn=$args[1]
$AppScriptIn=$args[2]

$TEMP_FILE_ONE=New-TemporaryFile
$TEMP_FILE_TWO=New-TemporaryFile

Invoke-RestMethod -Uri $uri/apps/$ParentFolderIdIn/children -Method GET -Headers $headers -UseBasicParsing > $TEMP_FILE_ONE

if ((Get-Content "$TEMP_FILE_ONE" | Select-String -CaseSensitive "\b${AppScriptIn}\b" )){
Remove-Item -Path $TEMP_FILE_ONE -Force 2>&1 | out-null
return $true
}else{
Remove-Item -Path $TEMP_FILE_ONE -Force 2>&1 | out-null

    Invoke-RestMethod -Uri $uri/apps/$ExcludeFolderIdIn/children -Method GET -Headers $headers -UseBasicParsing > $TEMP_FILE_TWO

    if ((Get-Content "$TEMP_FILE_TWO" | Select-String -CaseSensitive "\b${AppScriptIn}\b" )){
    Remove-Item -Path $TEMP_FILE_TWO -Force 2>&1 | out-null
    return $true
    }else{
    Remove-Item -Path $TEMP_FILE_TWO -Force 2>&1 | out-null
    return $false
    }

}


}


function CREATE_CIMITRA_APP{

$AppNameIn=$args[0]
$AppScriptIn=$args[1]
$ParentFolderIdIn=$args[2]
$ExcludeFolderIdIn=$args[3]
$jsonFileIn=$args[4]


if ( CHECK_FOR_EXISTING_APP "${ParentFolderIdIn}" "${ExcludeFolderIdIn}" "${AppScriptIn}" ){
return
}else{
Write-Output ""
Write-Output "Creating Cimitra App: $AppNameIn"
Write-Output ""
}

$URL = "$uri/apps"

$theResponse = Invoke-WebRequest -Uri "${URL}" `
-Method "POST" `
-Headers @{
"Authorization"="Bearer $token"
} `
-ContentType "application/json" `
-Body "${jsonFileIn}" 2>&1 | out-null
}


function ESTABLISH_CIMITRA_API_SESSION{

$global:uri = "https://${CIMITRA_SERVER_ADDRESS}:${CIMITRA_SERVER_PORT}/api"

$payload = @{
    email = $CIMITRA_SERVER_ADMIN_ACCOUNT;
    password = $CIMITRA_SERVER_ADMIN_PASSWORD;
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri $uri/users/login -Method POST -Body $payload -ContentType "application/json"

$token = $response.token 

$global:token = $response.token 

$global:headers = @{Authorization = "Bearer $token";}

}


function DISCOVER_AGENT_DETAILS{

$TEMP_FILE_ONE=New-TemporaryFile

try{
Invoke-RestMethod -Uri $uri/agent/$cimitraAgentId -Method GET -Headers $headers -UseBasicParsing > $TEMP_FILE_ONE
}
catch{
Remove-Item -Path $TEMP_FILE_ONE -Force 2>&1 | out-null
CALL_ERROR_EXIT "The Locally Defined Cimitra Agent Does Not Exist on The Cimitra Server Specified" 
}

if (!(Get-Content "$TEMP_FILE_ONE") -match "win32"){
CALL_ERROR_EXIT "The Locally Defined Cimitra Agent Isn't Configured to Run on The Windows Platform" 
}

$agentDetail = Get-Content "$TEMP_FILE_ONE" | Select-String -Pattern "$cimitraAgentId" -CaseSensitive -SimpleMatch

$agentName = Write-Output "$agentDetail" | %{ $_.Split(' ')[1]; }

Remove-Item -Path $TEMP_FILE_ONE -Force 2>&1 | out-null
Write-Output ""
Write-Output "Cimitra Windows Agent Name: [ $agentName ]"

}


function GET_FOLDER_IDS{

$TEMP_FILE_ONE=New-TemporaryFile

Invoke-RestMethod -Uri $uri/apps -Method GET -Headers $headers -UseBasicParsing > $TEMP_FILE_ONE

$rootFolderIdOne = (Get-Content $TEMP_FILE_ONE | Select-String -SimpleMatch -CaseSensitive 'Home Folder -' -Context 1 | Select-Object -First 1 ) 

$rootFolderIdTwo = ($rootFolderIdOne -split '\n')[0]

$rootFolderIdThree = ( $rootFolderIdTwo | %{ $_.Split(':')[1];} )

$rootFolderId = $rootFolderIdThree.Trim()

Remove-Item -Path $TEMP_FILE_ONE -Force 2>&1 | out-null

Invoke-RestMethod -Uri $uri/apps/$rootFolderId/children -Method GET -Headers $headers -UseBasicParsing > $TEMP_FILE_ONE

$CONFIG_IO="${PSScriptRoot}\config_reader.ps1"

. $CONFIG_IO

$CONFIG=(ReadFromConfigFile "${PSScriptRoot}\settings.cfg") 2>&1 | out-null

$CONFIRM_DELEGATE_FOLDER=(ConfirmFromConfigFile "${PSScriptRoot}\settings.cfg" "ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL")

if ( $CONFIRM_DELEGATE_FOLDER ) 
{ 
Set-Variable -Name ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL -Value $CONFIG$ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL }
else{
Set-Variable -Name ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL -Value 'ACTIVE DIRECTORY DELEGATED' 
}

if ((Get-Content "$TEMP_FILE_ONE" | Select-String -CaseSensitive "\b${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL}\b" )){

$adFolderIdOne = (Get-Content $TEMP_FILE_ONE | Select-String -SimpleMatch -CaseSensitive "${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL}" -Context 1 | Select-Object -First 1 ) 

$adFolderIdTwo = ($adFolderIdOne -split '\n')[0]

$adFolderIdThree = ( $adFolderIdTwo | %{ $_.Split(':')[1];} )

$adFolderId = $adFolderIdThree.Trim()

$global:adFolderId = $adFolderId

}else{
Write-Output "Error: Cannot Create or Discover the Folder: ${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL}"
Remove-Item -Path $TEMP_FILE_ONE -Force
exit 1
}

$CONFIRM_EXCLUDE_FOLDER=(ConfirmFromConfigFile "${PSScriptRoot}\settings.cfg" "ACTIVE_DIRECTORY_EXCLUDED_FOLDER_LABEL")

if ( $CONFIRM_EXCLUDE_FOLDER ) 
{ 
Set-Variable -Name ACTIVE_DIRECTORY_EXCLUDED_FOLDER_LABEL -Value $CONFIG$ACTIVE_DIRECTORY_EXCLUDED_FOLDER_LABEL }
else{
Set-Variable -Name ACTIVE_DIRECTORY_EXCLUDED_FOLDER_LABEL -Value 'ACTIVE DIRECTORY EXCLUDED' 
}

if ((Get-Content "$TEMP_FILE_ONE" | Select-String -CaseSensitive "\b${ACTIVE_DIRECTORY_EXCLUDED_FOLDER_LABEL}\b" )){

$adExcludeFolderIdOne = (Get-Content $TEMP_FILE_ONE | Select-String -SimpleMatch -CaseSensitive "${ACTIVE_DIRECTORY_EXCLUDED_FOLDER_LABEL}" -Context 1 | Select-Object -First 1 ) 

$adExcludeFolderIdTwo = ($adExcludeFolderIdOne -split '\n')[0]

$adExcludeFolderIdThree = ( $adExcludeFolderIdTwo | %{ $_.Split(':')[1];} )

$adExcludeFolderId = $adExcludeFolderIdThree.Trim()

$global:adExcludeFolderId = $adExcludeFolderId

}else{
Write-Output "Error: Cannot Create or Discover the Folder: ${ACTIVE_DIRECTORY_EXCLUDED_FOLDER_LABEL}"
Remove-Item -Path $TEMP_FILE_ONE -Force
exit 1
}

Invoke-RestMethod -Uri $uri/apps/$adFolderId/children -Method GET -Headers $headers -UseBasicParsing > $TEMP_FILE_ONE

$CONFIRM_USER_FOLDER=(ConfirmFromConfigFile "${PSScriptRoot}\settings.cfg" "ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL")

if ( $CONFIRM_EXCLUDE_FOLDER ) 
{ 
Set-Variable -Name ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL -Value $CONFIG$ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL }
else{
Set-Variable -Name ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL -Value 'USER MANAGEMENT' 
}

if ((Get-Content "$TEMP_FILE_ONE" | Select-String -CaseSensitive "\b${ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL}\b" )){

$adUserFolderIdOne = (Get-Content $TEMP_FILE_ONE | Select-String -SimpleMatch -CaseSensitive "${ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL}" -Context 1 | Select-Object -First 1 ) 

$adUserFolderIdTwo = ($adUserFolderIdOne -split '\n')[0]

$adUserFolderIdThree = ( $adUserFolderIdTwo | %{ $_.Split(':')[1];} )

$adUserFolderId = $adUserFolderIdThree.Trim()

$global:adUserFolderId = $adUserFolderId

}else{
Write-Output "Error: Cannot Create or Discover the Folder: ${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL}"
Remove-Item -Path $TEMP_FILE_ONE -Force
exit 1
}

$CONFIRM_COMPUTER_FOLDER=(ConfirmFromConfigFile "${PSScriptRoot}\settings.cfg" "ACTIVE_DIRECTORY_COMPUTER_MANAGEMENT_FOLDER_LABEL")

if ( $CONFIRM_COMPUTER_FOLDER ) 
{ 
Set-Variable -Name ACTIVE_DIRECTORY_COMPUTER_MANAGEMENT_FOLDER_LABEL -Value $CONFIG$ACTIVE_DIRECTORY_COMPUTER_MANAGEMENT_FOLDER_LABEL }
else{
Set-Variable -Name ACTIVE_DIRECTORY_COMPUTER_MANAGEMENT_FOLDER_LABEL -Value 'COMPUTER MANAGEMENT' 
}

if ((Get-Content "$TEMP_FILE_ONE" | Select-String -CaseSensitive "\b${ACTIVE_DIRECTORY_COMPUTER_MANAGEMENT_FOLDER_LABEL}\b" )){

$adComputerFolderIdOne = (Get-Content $TEMP_FILE_ONE | Select-String -SimpleMatch -CaseSensitive "${ACTIVE_DIRECTORY_COMPUTER_MANAGEMENT_FOLDER_LABEL}" -Context 1 | Select-Object -First 1 ) 

$adComputerFolderIdTwo = ($adComputerFolderIdOne -split '\n')[0]

$adComputerFolderIdThree = ( $adComputerFolderIdTwo | %{ $_.Split(':')[1];} )

$adComputerFolderId = $adComputerFolderIdThree.Trim()

$global:adComputerFolderId = $adComputerFolderId

}else{
Write-Output "Error: Cannot Create or Discover the Folder: ${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_COMPUTER_MANAGEMENT_FOLDER_LABEL}"
Remove-Item -Path $TEMP_FILE_ONE -Force
exit 1
}

return

Remove-Item -Path $TEMP_FILE_ONE -Force

Invoke-RestMethod -Uri https://$uri/api/apps/$adUserFolderId/children -Method GET -Headers $headers -UseBasicParsing > $TEMP_FILE_ONE


}


function CREATE_FOLDER_STRUCTURE{

$TEMP_FILE_ONE=New-TemporaryFile

Invoke-RestMethod -Uri $uri/apps -Method GET -Headers $headers -UseBasicParsing > $TEMP_FILE_ONE

$rootFolderIdOne = (Get-Content $TEMP_FILE_ONE | Select-String -SimpleMatch -CaseSensitive 'Home Folder -' -Context 1 | Select-Object -First 1 ) 

$rootFolderIdTwo = ($rootFolderIdOne -split '\n')[0]

$rootFolderIdThree = ( $rootFolderIdTwo | %{ $_.Split(':')[1];} )

$rootFolderId = $rootFolderIdThree.Trim()

Remove-Item -Path $TEMP_FILE_ONE -Force

Invoke-RestMethod -Uri $uri/apps/$rootFolderId/children -Method GET -Headers $headers -UseBasicParsing > $TEMP_FILE_ONE

$CONFIG_IO="${PSScriptRoot}\config_reader.ps1"


. $CONFIG_IO


$CONFIG=(ReadFromConfigFile "${PSScriptRoot}\settings.cfg") 2>&1 | out-null

$CONFIRM_FOLDER_FOLDER=(ConfirmFromConfigFile "${PSScriptRoot}\settings.cfg" "ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL")

if ( $CONFIRM_DELEGATE_FOLDER ) 
{ 
Set-Variable -Name ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL -Value $CONFIG$ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL }
else{
Set-Variable -Name ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL -Value 'ACTIVE DIRECTORY DELEGATED' 
}

if ((Get-Content "$TEMP_FILE_ONE" | Select-String -CaseSensitive "\b${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL}\b" )){
Write-Output ""
Write-Output "${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL} Folder Exists"
}else{
Write-Output ""
Write-Output "${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL} Folder Create"
CREATE_CIMITRA_FOLDER_ENTITY "${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL}" "Cimitra Active Directory Integration ${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL} App Delegation Folder" "$rootFolderId"
}

$CONFIRM_EXCLUDE_FOLDER=(ConfirmFromConfigFile "${PSScriptRoot}\settings.cfg" "ACTIVE_DIRECTORY_EXCLUDED_FOLDER_LABEL")

if ( $CONFIRM_EXCLUDE_FOLDER ) 
{ 
Set-Variable -Name ACTIVE_DIRECTORY_EXCLUDED_FOLDER_LABEL -Value $CONFIG$ACTIVE_DIRECTORY_EXCLUDED_FOLDER_LABEL }
else{
Set-Variable -Name ACTIVE_DIRECTORY_EXCLUDED_FOLDER_LABEL -Value 'ACTIVE DIRECTORY EXCLUDED' 
}

if ((Get-Content "$TEMP_FILE_ONE" | Select-String -CaseSensitive "\b${ACTIVE_DIRECTORY_EXCLUDED_FOLDER_LABEL}\b" )){
Write-Output ""
Write-Output "${ACTIVE_DIRECTORY_EXCLUDED_FOLDER_LABEL} Folder Exists"
}else{
Write-Output ""
Write-Output "${ACTIVE_DIRECTORY_EXCLUDED_FOLDER_LABEL} Folder Create"
CREATE_CIMITRA_FOLDER_ENTITY "${ACTIVE_DIRECTORY_EXCLUDED_FOLDER_LABEL}" "Cimitra Active Directory Integration Exclude Folder. Any Cimitra Apps placed into this folder will not be recreated in the folder named: ${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL}." "$rootFolderId"
}



Invoke-RestMethod -Uri $uri/apps/$rootFolderId/children -Method GET -Headers $headers -UseBasicParsing > $TEMP_FILE_ONE

if ((Get-Content "$TEMP_FILE_ONE") -match "${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL}"){

$adFolderIdOne = (Get-Content $TEMP_FILE_ONE | Select-String -SimpleMatch -CaseSensitive "${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL}" -Context 1 | Select-Object -First 1 ) 

$adFolderIdTwo = ($adFolderIdOne -split '\n')[0]

$adFolderIdThree = ( $adFolderIdTwo | %{ $_.Split(':')[1];} )

$adFolderId = $adFolderIdThree.Trim()

Remove-Item -Path $TEMP_FILE_ONE -Force

}else{
Write-Output "Error: Cannot Create or Discover the Folder: ${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL}"
Remove-Item -Path $TEMP_FILE_ONE -Force
exit 1
}


Invoke-RestMethod -Uri $uri/apps/$adFolderId/children -Method GET -Headers $headers -UseBasicParsing > $TEMP_FILE_ONE


$CONFIRM_USER_FOLDER=(ConfirmFromConfigFile "${PSScriptRoot}\settings.cfg" "ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL")

if ( $CONFIRM_USER_FOLDER ) 
{ 
Set-Variable -Name ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL -Value $CONFIG$ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL }
else{
Set-Variable -Name ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL -Value 'USER MANAGEMENT' 
}

if ((Get-Content "$TEMP_FILE_ONE") -match "${ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL}"){
Write-Output ""
Write-Output "${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL} - Folder Exists"
}else{
Write-Output ""
Write-Output "${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL} - Folder Create"
CREATE_CIMITRA_FOLDER_ENTITY "${ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL}" "Cimitra Active Directory Integration ${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL} App Delegation Folder." "$adFolderId"
}

$CONFIRM_COMPUTER_FOLDER=(ConfirmFromConfigFile "${PSScriptRoot}\settings.cfg" "ACTIVE_DIRECTORY_COMPUTER_MANAGEMENT_FOLDER_LABEL")

if ( $CONFIRM_USER_FOLDER ) 
{ 
Set-Variable -Name ACTIVE_DIRECTORY_COMPUTER_MANAGEMENT_FOLDER_LABEL -Value $CONFIG$ACTIVE_DIRECTORY_COMPUTER_MANAGEMENT_FOLDER_LABEL }
else{
Set-Variable -Name ACTIVE_DIRECTORY_COMPUTER_MANAGEMENT_FOLDER_LABEL -Value 'COMPUTER MANAGEMENT' 
}

if ((Get-Content "$TEMP_FILE_ONE") -match "${ACTIVE_DIRECTORY_COMPUTER_MANAGEMENT_FOLDER_LABEL}"){
Write-Output ""
Write-Output "${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_COMPUTER_MANAGEMENT_FOLDER_LABEL} - Folder Exists"
Write-Output ""
}else{
Write-Output ""
Write-Output "${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_COMPUTER_MANAGEMENT_FOLDER_LABEL} - Folder Create"
Write-Output ""
CREATE_CIMITRA_FOLDER_ENTITY "${ACTIVE_DIRECTORY_COMPUTER_MANAGEMENT_FOLDER_LABEL}" "Cimitra Active Directory Integration ${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_COMPUTER_MANAGEMENT_FOLDER_LABEL} App Delegation Folder." "$adFolderId"
}


Remove-Item -Path $TEMP_FILE_ONE -Force


}

function REGISTER_FOLDER_NAMES{

try{

$CONFIG_IO="${PSScriptRoot}\config_reader.ps1"

. $CONFIG_IO 2>&1 | out-null

$settingsFile = "${PSScriptRoot}\settings.cfg"

confirmConfigSetting "$settingsFile" "ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL" "ACTIVE DIRECTORY DELEGATED"

confirmConfigSetting "$settingsFile" "ACTIVE_DIRECTORY_EXCLUDED_FOLDER_LABEL" "ACTIVE DIRECTORY EXCLUDED"

confirmConfigSetting "$settingsFile" "ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL" "USER MANAGEMENT"

confirmConfigSetting "$settingsFile" "ACTIVE_DIRECTORY_COMPUTER_MANAGEMENT_FOLDER_LABEL" "COMPUTER MANAGEMENT"

}catch{

CALL_ERROR_EXIT "Could not edit file: $settingsFile - Perhaps this is a rights issue? Or the supporting script ${PSScriptRoot}\config_reader.ps1 cannot be run?"

}

}


REGISTER_FOLDER_NAMES

CREATE_DEFAULT_CONNECTION_VARIABLES

function CREATE_CIMITRA_APPS{

write-output ""
write-output "START: ADD CIMITRA ACTIVE DIRECTORY INTEGRATION APPS"
write-output "------------------------------------------------"

ESTABLISH_CIMITRA_API_SESSION

DISCOVER_AGENT_DETAILS

CREATE_FOLDER_STRUCTURE

GET_FOLDER_IDS


$scriptRoot = Write-Output "${PSScriptRoot}" | % {$_ -replace '\\','\\'}

# USERS #

# Make CREATE USER App
$jsonFile = "{`"type`":1,`"status`":`"active`",`"platform`":`"win32`",`"injectParams`":[{`"param`":`"-firstNameIn`",`"value`":`"`",`"label`":`"First Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Jane`"},{`"param`":`"-lastNameIn`",`"value`":`"`",`"label`":`"Last Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Doe`"},{`"param`":`"-passwordIn`",`"value`":`"`",`"label`":`"Password`",`"regex`":`"/^[0-9A-Za-z_+-=]+`$/`",`"placeholder`":`"p433w0r9_ch4ng3`",`"private`":true}],`"interpreter`":`"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`",`"command`":`"${scriptRoot}\\NewUser.ps1`",`"params`":`" -showErrors`",`"agentId`":`"${cimitraAgentId}`",`"name`":`"CREATE USER`",`"notes`":`"NOTE - Make sure that in the file 'settings.cfg' the 'AD_USER_CONTEXT' value is properly configured with the Active Directory Context where this script is supposed to be looking to.`",`"description`":`"Create a User in Active Directory`",`"parentFolderId`":`"${adUserFolderId}`"}"
CREATE_CIMITRA_APP "CREATE USER" "NewUser.ps1" "${adUserFolderId}" "${adExcludeFolderId}" "$jsonFile"

# Make LIST USERS App
$jsonFile = "{`"type`":1,`"status`":`"active`",`"platform`":`"win32`",`"interpreter`":`"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`",`"command`":`"${scriptRoot}\\ListUsers.ps1`",`"params`":`" -showErrors`",`"agentId`":`"${cimitraAgentId}`",`"name`":`"LIST USERS`",`"notes`":`"NOTE - Make sure that in the file 'settings.cfg' the 'AD_USER_CONTEXT' value is properly configured with the Active Directory Context where this script is supposed to be looking to.`",`"description`":`"List Computers in an Active Directory Context`",`"parentFolderId`":`"${adComputerFolderId}`"}"
CREATE_CIMITRA_APP "LIST USERS" "ListUsers.ps1" "${adUserFolderId}" "${adExcludeFolderId}" "$jsonFile"

$jsonFile = "{`"type`":1,`"status`":`"active`",`"platform`":`"win32`",`"injectParams`":[{`"param`":`"-firstNameIn`",`"value`":`"`",`"label`":`"First Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Jane`"},{`"param`":`"-lastNameIn`",`"value`":`"`",`"label`":`"Last Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Doe`"},{`"param`":`"-passwordIn`",`"value`":`"`",`"label`":`"Password`",`"regex`":`"/^[0-9A-Za-z_+-=]+`$/`",`"placeholder`":`"p433w0r9_ch4ng3`",`"private`":true}],`"interpreter`":`"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`",`"command`":`"${scriptRoot}\\SetUserPassword.ps1`",`"params`":`" -showErrors`",`"agentId`":`"${cimitraAgentId}`",`"name`":`"CHANGE USER PASSWORD`",`"notes`":`"NOTE - Make sure that in the file 'settings.cfg' the 'AD_USER_CONTEXT' value is properly configured with the Active Directory Context where this script is supposed to be looking to.`",`"description`":`"Change a User Password in Active Directory`",`"parentFolderId`":`"${adUserFolderId}`"}"
CREATE_CIMITRA_APP "CHANGE USER PASSWORD" "SetUserPassword.ps1" "${adUserFolderId}" "${adExcludeFolderId}" "$jsonFile"

$jsonFile = "{`"type`":1,`"status`":`"active`",`"platform`":`"win32`",`"injectParams`":[{`"param`":`"-firstNameIn`",`"value`":`"`",`"label`":`"First Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Jane`"},{`"param`":`"-lastNameIn`",`"value`":`"`",`"label`":`"Last Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Doe`"}],`"interpreter`":`"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`",`"command`":`"${scriptRoot}\\CheckPasswordSetDate.ps1`",`"params`":`" -showErrors`",`"agentId`":`"${cimitraAgentId}`",`"name`":`"CHECK PASSWORD CHANGE DATE`",`"notes`":`"NOTE - Make sure that in the file 'settings.cfg' the 'AD_USER_CONTEXT' value is properly configured with the Active Directory Context where this script is supposed to be looking to.`",`"description`":`"Check When a User Password Was Last Changed in Active Directory`",`"parentFolderId`":`"${adUserFolderId}`"}"
CREATE_CIMITRA_APP "CHECK PASSWORD CHANGE DATE" "CheckPasswordSetDate.ps1" "${adUserFolderId}" "${adExcludeFolderId}" "$jsonFile"

# Make LIST ALL USERS IN AD TREE App
$jsonFile = "{`"type`":1,`"status`":`"active`",`"platform`":`"win32`",`"interpreter`":`"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`",`"command`":`"${scriptRoot}\\ListUsersDistinguishedNames.ps1`",`"params`":`" `",`"agentId`":`"${cimitraAgentId}`",`"name`":`"LIST ALL USERS IN AD TREE`",`"notes`":`" `",`"description`":`"List All Users in an Entire Active Directory Tree`",`"parentFolderId`":`"${adUserFolderId}`"}"
CREATE_CIMITRA_APP "LIST ALL USERS IN AD TREE" "ListUsersDistinguishedNames.ps1" "${adUserFolderId}" "${adExcludeFolderId}" "$jsonFile"

$jsonFile = "{`"type`":1,`"status`":`"active`",`"platform`":`"win32`",`"injectParams`":[{`"param`":`"-firstNameIn`",`"value`":`"`",`"label`":`"First Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Jane`"},{`"param`":`"-lastNameIn`",`"value`":`"`",`"label`":`"Last Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Doe`"},{`"param`":`"-confirmWordIn`",`"value`":`"`",`"label`":`"YES = Confirm`",`"regex`":`"/^[YES]+`$/`",`"placeholder`":`"YES`",`"private`":false}],`"interpreter`":`"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`",`"command`":`"${scriptRoot}\\RemoveUserAndConfirm.ps1`",`"params`":`" -showErrors`",`"agentId`":`"${cimitraAgentId}`",`"name`":`"REMOVE USER`",`"notes`":`"NOTE - Make sure that in the file 'settings.cfg' the 'AD_USER_CONTEXT' value is properly configured with the Active Directory Context where this script is supposed to be looking to.`",`"description`":`"Remove a User From Active Directory`",`"parentFolderId`":`"${adUserFolderId}`"}"
CREATE_CIMITRA_APP "REMOVE USER" "RemoveUserAndConfirm.ps1" "${adUserFolderId}" "${adExcludeFolderId}" "$jsonFile"

# COMPUTERS #

$jsonFile = "{`"type`":1,`"status`":`"active`",`"platform`":`"win32`",`"injectParams`":[{`"param`":`"-computerNameIn`",`"value`":`"`",`"label`":`"Computer Name`",`"regex`":`"/^[0-9A-Za-z_-]+`$/`",`"placeholder`":`"WIN_COMPUTER_ONE`"},{`"param`":`"-computerTypeIn`",`"value`":`"`",`"label`":`"Computer Type (Mac=1, Win=2, Linux=3, ChromeOS=4, Other=5)`",`"regex`":`"/^[1-5]+`$/`",`"placeholder`":`"2`"}],`"interpreter`":`"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`",`"command`":`"${scriptRoot}\\NewComputer.ps1`",`"params`":`" -showErrors`",`"agentId`":`"${cimitraAgentId}`",`"name`":`"CREATE COMPUTER`",`"notes`":`"NOTE - Make sure that in the file 'settings.cfg' the 'AD_COMPUTER_CONTEXT' value is properly configured with the Active Directory Context where this script is supposed to be looking to.`",`"description`":`"Create a Computer Object in Active Directory`",`"parentFolderId`":`"${adComputerFolderId}`"}"
CREATE_CIMITRA_APP "CREATE COMPUTER" "NewComputer.ps1" "${adComputerFolderId}" "${adExcludeFolderId}" "$jsonFile"

$jsonFile = "{`"type`":1,`"status`":`"active`",`"platform`":`"win32`",`"interpreter`":`"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`",`"command`":`"${scriptRoot}\\ListComputers.ps1`",`"params`":`" -showErrors`",`"agentId`":`"${cimitraAgentId}`",`"name`":`"LIST COMPUTERS`",`"notes`":`"NOTE - Make sure that in the file 'settings.cfg' the 'AD_COMPUTER_CONTEXT' value is properly configured with the Active Directory Context where this script is supposed to be looking to.`",`"description`":`"List Computers in an Active Directory Tree Context`",`"parentFolderId`":`"${adComputerFolderId}`"}"
CREATE_CIMITRA_APP "LIST COMPUTERS" "ListComputers.ps1" "${adComputerFolderId}" "${adExcludeFolderId}" "$jsonFile"

$jsonFile = "{`"type`":1,`"status`":`"active`",`"platform`":`"win32`",`"injectParams`":[{`"param`":`"-computerNameIn`",`"value`":`"`",`"label`":`"Current Computer Name`",`"regex`":`"/^[0-9A-Za-z_+-=]+`$/`",`"placeholder`":`"WIN_COMPUTER_ONE`"},{`"param`":`"-newComputerNameIn`",`"value`":`"`",`"label`":`"New Computer Name`",`"regex`":`"/^[0-9A-Za-z_+-=]+`$/`",`"placeholder`":`"WIN_COMPUTER_TWO`"}],`"interpreter`":`"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`",`"command`":`"${scriptRoot}\\RenameComputer.ps1`",`"params`":`" -showErrors`",`"agentId`":`"${cimitraAgentId}`",`"name`":`"RENAME COMPUTER`",`"notes`":`"NOTE - Make sure that in the file 'settings.cfg' the 'AD_COMPUTER_CONTEXT' value is properly configured with the Active Directory Context where this script is supposed to be looking to.`",`"description`":`"Rename a Computer Object in Active Directory`",`"parentFolderId`":`"${adComputerFolderId}`"}"
CREATE_CIMITRA_APP "RENAME COMPUTER" "RenameComputer.ps1" "${adComputerFolderId}" "${adExcludeFolderId}" "$jsonFile"

$jsonFile = "{`"type`":1,`"status`":`"active`",`"platform`":`"win32`",`"interpreter`":`"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`",`"command`":`"${scriptRoot}\\ListComputersDistinguishedNames.ps1`",`"params`":`" `",`"agentId`":`"${cimitraAgentId}`",`"name`":`"LIST ALL COMPUTERS IN AD TREE`",`"notes`":`" `",`"description`":`"List All Computers in an Entire Active Directory Tree`",`"parentFolderId`":`"${adComputerFolderId}`"}"
CREATE_CIMITRA_APP "LIST ALL COMPUTERS IN AD TREE" "ListComputersDistinguishedNames.ps1" "${adComputerFolderId}" "${adExcludeFolderId}" "$jsonFile"


$jsonFile = "{`"type`":1,`"status`":`"active`",`"platform`":`"win32`",`"injectParams`":[{`"param`":`"-computerNameIn`",`"value`":`"`",`"label`":`"Computer Name`",`"regex`":`"/^[0-9A-Za-z_+-=]+`$/`",`"placeholder`":`"WIN_COMPUTER_ONE`"}],`"interpreter`":`"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`",`"command`":`"${scriptRoot}\\RemoveComputer.ps1`",`"params`":`" -showErrors`",`"agentId`":`"${cimitraAgentId}`",`"name`":`"REMOVE COMPUTER`",`"notes`":`"NOTE - Make sure that in the file 'settings.cfg' the 'AD_COMPUTER_CONTEXT' value is properly configured with the Active Directory Context where this script is supposed to be looking to.`",`"description`":`"Remove a Computer From Active Directory`",`"parentFolderId`":`"${adComputerFolderId}`"}"
CREATE_CIMITRA_APP "REMOVE COMPUTER" "RemoveComputer.ps1" "${adComputerFolderId}" "${adExcludeFolderId}" "$jsonFile"


write-output "------------------------------------------------"
write-output "FINISH: ADD CIMITRA ACTIVE DIRECTORY INTEGRATION APPS"
write-output ""

}

function Show-Menu {
    param (
        [string]$Title = 'Cimitra Active Directory Integration Main Menu'
    )
    Clear-Host
    Write-Host "-------------------------------------------------"
    Write-Host "| Cimitra Active Directory Integration Main Menu |"
    Write-Host "-------------------------------------------------"
    Write-Host "" 
    Write-Host "[1] Configure Cimitra Integration Admin User"
    Write-Host "" 
    Write-Host "[2] Add Active Directory Integration"
    Write-Host "" 
    Write-Host "[3] Configure Active Directory Users Context"
    Write-Host "" 
    Write-Host "[4] Configure Active Directory Computers Context"
    Write-Host "" 
    Write-Host "[5] Update This Integration Module from GitHub"
    Write-Host "" 
    Write-Host "[6] Exit"
    Write-Host "" 
}

do
 {
    Show-Menu
    $selection = Read-Host "Please make a selection"
    switch ($selection)
    {
    '1' {
         PROMPT_FOR_CIMITRA_SERVER_CREDENTIALS
    } '2' {
         CREATE_CIMITRA_APPS
    } '3' {
         PROMPT_FOR_AD_USER
    } '4' {
         PROMPT_FOR_AD_COMPUTER
    } '5' {
         UPDATE_SCRIPTS
    } '6' {
    exit 0
    }
    }
    pause
 }
 until ($selection -eq '6')