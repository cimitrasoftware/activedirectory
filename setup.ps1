# Check Password Set Date in Active Directory
# Author: Tay Kratzer tay@cimitra.com
# -------------------------------------------------
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
Write-Host "Active Directory Computers Context: $AD_COMPUTER_CONTEXT" -ForegroundColor blue -BackgroundColor white
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

function CREATE_CIMITRA_LINK_ENTITY{

$LinkNameIn=$args[0]
$LinkDescriptionIn=$args[1]
$LinkURL=$args[2]
$ParentFolderIdIn=$args[3]

$URL = "$uri/apps"

$response = Invoke-WebRequest -Uri "${URL}" `
-Method "POST" `
-Headers @{
"Authorization"="Bearer $token"
} `
-ContentType "application/json" `
-Body "{`"type`":3,`"status`":`"active`",`"url`":`"${LinkURL}`",`"name`":`"${LinkNameIn}`",`"description`":`"${LinkDescriptionIn}`",`"parentFolderId`":`"${ParentFolderIdIn}`"}"
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
# BLISS
$AppNameIn=$args[0]
$AppScriptIn=$args[1]
$ParentFolderIdIn=$args[2]
$ExcludeFolderIdIn=$args[3]
$jsonFileIn=$args[4]

if ( CHECK_FOR_EXISTING_APP "${ParentFolderIdIn}" "${adAdminFolderId}" "${AppScriptIn}" ){
return
}

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

$uri = "https://${CIMITRA_SERVER_ADDRESS}:${CIMITRA_SERVER_PORT}/api"

$global:uri = "${uri}"

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


function CHECK_CONNECTIVITY{

write-output ""
write-output "START: CHECK CIMITRA INTEGRATION ADMIN USER SETTINGS"
write-output "----------------------------------------------------"

write-output ""
write-output "START: Establish API Session With Cimitra Server"
write-output "-------------------------------------------------"


ESTABLISH_CIMITRA_API_SESSION

write-output ""
write-output "FINISH: Establish API Session With Cimitra Server"
write-output "--------------------------------------------------"


write-output ""
write-output "START: Discover Cimitra Agent Details"
write-output "-------------------------------------"

DISCOVER_AGENT_DETAILS
write-output ""
write-output "FINISH: Discover Cimitra Agent Details"
write-output "--------------------------------------"


}


function GET_FOLDER_IDS{

$TEMP_FILE_ONE=New-TemporaryFile

# Get User's Root Folder

Invoke-RestMethod -Uri $uri/apps -Method GET -Headers $headers -UseBasicParsing > $TEMP_FILE_ONE

$rootFolderIdOne = (Get-Content $TEMP_FILE_ONE | Select-String -SimpleMatch -CaseSensitive 'Home Folder -' -Context 1 | Select-Object -First 1 ) 

$rootFolderIdTwo = ($rootFolderIdOne -split '\n')[0]

$rootFolderIdThree = ( $rootFolderIdTwo | %{ $_.Split(':')[1];} )

$rootFolderId = $rootFolderIdThree.Trim()

# Got User's Root Folder Id

Remove-Item -Path $TEMP_FILE_ONE -Force 2>&1 | out-null

# Got User's Root Folder's Children

Invoke-RestMethod -Uri $uri/apps/$rootFolderId/children -Method GET -Headers $headers -UseBasicParsing > $TEMP_FILE_ONE

$CONFIG_IO="${PSScriptRoot}\config_reader.ps1"

. $CONFIG_IO


Set-Variable -Name ACTIVE_DIRECTORY_MAIN_FOLDER -Value 'ACTIVE DIRECTORY'

# Look for the ACTIVE DIRECTORY folder

if ((Get-Content "$TEMP_FILE_ONE" | Select-String -CaseSensitive "\b${ACTIVE_DIRECTORY_MAIN_FOLDER}\b" )){

$adRootFolderIdOne = (Get-Content $TEMP_FILE_ONE | Select-String -SimpleMatch -CaseSensitive "${ACTIVE_DIRECTORY_MAIN_FOLDER}" -Context 1 | Select-Object -First 1 ) 

$adRootFolderIdTwo = ($adRootFolderIdOne -split '\n')[0]

$adRootFolderIdThree = ( $adRootFolderIdTwo | %{ $_.Split(':')[1];} )

$adRootFolderId = $adRootFolderIdThree.Trim()

$global:adRootFolderId = $adRootFolderId

Remove-Item -Path $TEMP_FILE_ONE -Force 2>&1 | out-null

# Get the ACTIVE DIRECTORY folder's children


Invoke-RestMethod -Uri $uri/apps/$adRootFolderId/children -Method GET -Headers $headers -UseBasicParsing > $TEMP_FILE_ONE

}else{
Write-Output "Error: Cannot Create or Discover the Folder: ${ACTIVE_DIRECTORY_MAIN_FOLDER}"
Remove-Item -Path $TEMP_FILE_ONE -Force
exit 1
}

# Get the ACTIVE DIRECTORY | ADMIN folder

$CONFIRM_ADMIN_FOLDER=(ConfirmFromConfigFile "${PSScriptRoot}\settings.cfg" "ACTIVE_DIRECTORY_ADMIN_FOLDER_LABEL")

if ( $CONFIRM_ADMIN_FOLDER ) 
{ 
Set-Variable -Name ACTIVE_DIRECTORY_ADMIN_FOLDER_LABEL -Value $CONFIG$ACTIVE_DIRECTORY_ADMIN_FOLDER_LABEL }
else{
Set-Variable -Name ACTIVE_DIRECTORY_ADMIN_FOLDER_LABEL -Value 'ADMIN' 
}



if ((Get-Content "$TEMP_FILE_ONE" | Select-String -CaseSensitive "\b${ACTIVE_DIRECTORY_ADMIN_FOLDER_LABEL}\b" )){

$adAdminFolderIdOne = (Get-Content $TEMP_FILE_ONE | Select-String -SimpleMatch -CaseSensitive "${ACTIVE_DIRECTORY_ADMIN_FOLDER_LABEL}" -Context 1 | Select-Object -First 1 ) 

$adAdminFolderIdTwo = ($adAdminFolderIdOne -split '\n')[0]

$adAdminFolderIdThree = ( $adAdminFolderIdTwo | %{ $_.Split(':')[1];} )

$adAdminFolderId = $adAdminFolderIdThree.Trim()

$global:adAdminFolderId = $adAdminFolderId

}else{
Write-Output "Error: Cannot Create or Discover the Folder: ${ACTIVE_DIRECTORY_ADMIN_FOLDER_LABEL}"
Remove-Item -Path $TEMP_FILE_ONE -Force
exit 1
}


$CONFIRM_DELEGATE_FOLDER=(ConfirmFromConfigFile "${PSScriptRoot}\settings.cfg" "ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL")

if ( $CONFIRM_DELEGATE_FOLDER ) 
{ 
Set-Variable -Name ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL -Value $CONFIG$ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL }
else{
Set-Variable -Name ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL -Value 'DELEGATE' 
}

# Get the ACTIVE DIRECTORY | DELGATE folder


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


# Get the ACTIVE DIRECTORY | EXCLUDE folder

$CONFIRM_EXCLUDE_FOLDER=(ConfirmFromConfigFile "${PSScriptRoot}\settings.cfg" "ACTIVE_DIRECTORY_EXCLUDED_FOLDER_LABEL")

if ( $CONFIRM_EXCLUDE_FOLDER ) 
{ 
Set-Variable -Name ACTIVE_DIRECTORY_EXCLUDED_FOLDER_LABEL -Value $CONFIG$ACTIVE_DIRECTORY_EXCLUDED_FOLDER_LABEL }
else{
Set-Variable -Name ACTIVE_DIRECTORY_EXCLUDED_FOLDER_LABEL -Value 'EXCLUDE' 
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

# Get the ACTIVE DIRECTORY | DELGATE folder's children

Invoke-RestMethod -Uri $uri/apps/$adFolderId/children -Method GET -Headers $headers -UseBasicParsing > $TEMP_FILE_ONE

$CONFIRM_USER_FOLDER=(ConfirmFromConfigFile "${PSScriptRoot}\settings.cfg" "ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL")

if ( $CONFIRM_EXCLUDE_FOLDER ) 
{ 
Set-Variable -Name ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL -Value $CONFIG$ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL }
else{
Set-Variable -Name ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL -Value 'USER MANAGEMENT' 
}

# Get the ACTIVE DIRECTORY | DELGATE | USER MANAGEMENT folder

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

# Get the ACTIVE DIRECTORY | DELGATE | USER MANAGEMENT | USER ACCESS folder

Invoke-RestMethod -Uri $uri/apps/$adUserFolderId/children -Method GET -Headers $headers -UseBasicParsing > $TEMP_FILE_ONE

$CONFIRM_ACCESS_FOLDER=(ConfirmFromConfigFile "${PSScriptRoot}\settings.cfg" "ACTIVE_DIRECTORY_USER_ACCESS_FOLDER_LABEL")

if ( $CONFIRM_ACCESS_FOLDER ) 
{ 
Set-Variable -Name ACTIVE_DIRECTORY_USER_ACCESS_FOLDER_LABEL -Value $CONFIG$ACTIVE_DIRECTORY_USER_ACCESS_FOLDER_LABEL }
else{
Set-Variable -Name ACTIVE_DIRECTORY_USER_ACCESS_FOLDER_LABEL -Value 'USER ACCESS' 
}


if ((Get-Content "$TEMP_FILE_ONE" | Select-String -CaseSensitive "\b${ACTIVE_DIRECTORY_USER_ACCESS_FOLDER_LABEL}\b" )){

$adUserAccessIdOne = (Get-Content $TEMP_FILE_ONE | Select-String -SimpleMatch -CaseSensitive "${ACTIVE_DIRECTORY_USER_ACCESS_FOLDER_LABEL}" -Context 1 | Select-Object -First 1 ) 

$adUserAccessIdTwo = ($adUserAccessIdOne -split '\n')[0]

$adUserAccessIdThree = ( $adUserAccessIdTwo | %{ $_.Split(':')[1];} )

$adUserAccessId = $adUserAccessIdThree.Trim()

$global:adUserAccessId = $adUserAccessId

}else{
Write-Output "Error: Cannot Create or Discover the Folder: ${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_USER_ACCESS_FOLDER_LABEL}"
Remove-Item -Path $TEMP_FILE_ONE -Force
exit 1
}


# Get the ACTIVE DIRECTORY | DELGATE | USER MANAGEMENT | USER CHANGES folder


$CONFIRM_CHANGES_FOLDER=(ConfirmFromConfigFile "${PSScriptRoot}\settings.cfg" "ACTIVE_DIRECTORY_USER_CHANGES_FOLDER_LABEL")

if ( $CONFIRM_CHANGES_FOLDER ) 
{ 
Set-Variable -Name ACTIVE_DIRECTORY_USER_CHANGES_FOLDER_LABEL -Value $CONFIG$ACTIVE_DIRECTORY_USER_CHANGES_FOLDER_LABEL }
else{
Set-Variable -Name ACTIVE_DIRECTORY_USER_CHANGES_FOLDER_LABEL -Value 'USER CHANGES' 
}


if ((Get-Content "$TEMP_FILE_ONE" | Select-String -CaseSensitive "\b${ACTIVE_DIRECTORY_USER_CHANGES_FOLDER_LABEL}\b" )){

$adUserChangesIdOne = (Get-Content $TEMP_FILE_ONE | Select-String -SimpleMatch -CaseSensitive "${ACTIVE_DIRECTORY_USER_CHANGES_FOLDER_LABEL}" -Context 1 | Select-Object -First 1 ) 

$adUserChangesIdTwo = ($adUserChangesIdOne -split '\n')[0]

$adUserChangesIdThree = ( $adUserChangesIdTwo | %{ $_.Split(':')[1];} )

$adUserChangesId = $adUserChangesIdThree.Trim()

$global:adUserChangesId = $adUserChangesId

}else{
Write-Output "Error: Cannot Create or Discover the Folder: ${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_USER_CHANGES_FOLDER_LABEL}"
Remove-Item -Path $TEMP_FILE_ONE -Force
exit 1
}


# Get the ACTIVE DIRECTORY | DELGATE | USER MANAGEMENT | USER REPORTS folder


$CONFIRM_REPORTS_FOLDER=(ConfirmFromConfigFile "${PSScriptRoot}\settings.cfg" "ACTIVE_DIRECTORY_USER_REPORTS_FOLDER_LABEL")

if ( $CONFIRM_ACCESS_FOLDER ) 
{ 
Set-Variable -Name ACTIVE_DIRECTORY_USER_REPORTS_FOLDER_LABEL -Value $CONFIG$ACTIVE_DIRECTORY_USER_REPORTS_FOLDER_LABEL }
else{
Set-Variable -Name ACTIVE_DIRECTORY_USER_REPORTS_FOLDER_LABEL -Value 'USER CHANGES' 
}


if ((Get-Content "$TEMP_FILE_ONE" | Select-String -CaseSensitive "\b${ACTIVE_DIRECTORY_USER_REPORTS_FOLDER_LABEL}\b" )){

$adUserReportsIdOne = (Get-Content $TEMP_FILE_ONE | Select-String -SimpleMatch -CaseSensitive "${ACTIVE_DIRECTORY_USER_REPORTS_FOLDER_LABEL}" -Context 1 | Select-Object -First 1 ) 

$adUserReportsIdTwo = ($adUserReportsIdOne -split '\n')[0]

$adUserReportsIdThree = ( $adUserReportsIdTwo | %{ $_.Split(':')[1];} )

$adUserReportsId = $adUserReportsIdThree.Trim()

$global:adUserReportsId = $adUserReportsId

}else{
Write-Output "Error: Cannot Create or Discover the Folder: ${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_USER_REPORTS_FOLDER_LABEL}"
Remove-Item -Path $TEMP_FILE_ONE -Force
exit 1
}

# Get the ACTIVE DIRECTORY | DELGATE | USER MANAGEMENT | CREATE folder


$CONFIRM_CREATE_FOLDER=(ConfirmFromConfigFile "${PSScriptRoot}\settings.cfg" "ACTIVE_DIRECTORY_USER_CREATE_FOLDER_LABEL")

if ( $CONFIRM_CREATE_FOLDER ) 
{ 
Set-Variable -Name ACTIVE_DIRECTORY_USER_CREATE_FOLDER_LABEL -Value $CONFIG$ACTIVE_DIRECTORY_USER_CREATE_FOLDER_LABEL }
else{
Set-Variable -Name ACTIVE_DIRECTORY_USER_CREATE_FOLDER_LABEL -Value 'CREATE' 
}


if ((Get-Content "$TEMP_FILE_ONE" | Select-String -CaseSensitive "\b${ACTIVE_DIRECTORY_USER_CREATE_FOLDER_LABEL}\b" )){

$adUserCreateIdOne = (Get-Content $TEMP_FILE_ONE | Select-String -SimpleMatch -CaseSensitive "${ACTIVE_DIRECTORY_USER_CREATE_FOLDER_LABEL}" -Context 1 | Select-Object -First 1 ) 

$adUserCreateIdTwo = ($adUserCreateIdOne -split '\n')[0]

$adUserCreateIdThree = ( $adUserCreateIdTwo | %{ $_.Split(':')[1];} )

$adUserCreateId = $adUserCreateIdThree.Trim()

$global:adUserCreateId = $adUserCreateId

}else{
Write-Output "Error: Cannot Create or Discover the Folder: ${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_USER_CREATE_FOLDER_LABEL}"
Remove-Item -Path $TEMP_FILE_ONE -Force
exit 1
}

# Get the ACTIVE DIRECTORY | DELGATE | USER MANAGEMENT | REMOVE/CHANGE/DELETE folder


$CONFIRM_REMOVE_FOLDER=(ConfirmFromConfigFile "${PSScriptRoot}\settings.cfg" "ACTIVE_DIRECTORY_USER_REMOVE_CHANGE_DELETE_FOLDER_LABEL")

if ( $CONFIRM_REMOVE_FOLDER ) 
{ 
Set-Variable -Name ACTIVE_DIRECTORY_USER_REMOVE_CHANGE_DELETE_FOLDER_LABEL -Value $CONFIG$ACTIVE_DIRECTORY_USER_REMOVE_CHANGE_DELETE_FOLDER_LABEL }
else{
Set-Variable -Name ACTIVE_DIRECTORY_USER_REMOVE_CHANGE_DELETE_FOLDER_LABEL -Value 'REMOVE/CHANGE/DELETE' 
}


if ((Get-Content "$TEMP_FILE_ONE" | Select-String -CaseSensitive "\b${ACTIVE_DIRECTORY_USER_REMOVE_CHANGE_DELETE_FOLDER_LABEL}\b" )){

$adUserRemoveIdOne = (Get-Content $TEMP_FILE_ONE | Select-String -SimpleMatch -CaseSensitive "${ACTIVE_DIRECTORY_USER_REMOVE_CHANGE_DELETE_FOLDER_LABEL}" -Context 1 | Select-Object -First 1 ) 

$adUserRemoveIdTwo = ($adUserRemoveIdOne -split '\n')[0]

$adUserRemoveIdThree = ( $adUserRemoveIdTwo | %{ $_.Split(':')[1];} )

$adUserRemoveId = $adUserRemoveIdThree.Trim()

$global:adUserRemoveId = $adUserRemoveId

}else{
Write-Output "Error: Cannot Create or Discover the Folder: ${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_USER_REMOVE_CHANGE_DELETE_FOLDER_LABEL}"
Remove-Item -Path $TEMP_FILE_ONE -Force
exit 1
}


Invoke-RestMethod -Uri $uri/apps/$adFolderId/children -Method GET -Headers $headers -UseBasicParsing > $TEMP_FILE_ONE

# Get the ACTIVE DIRECTORY | DELGATE | COMPUTER MANAGEMENT folder

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

Write-Output "FOLDER URI = $uri"


Invoke-RestMethod -Uri $uri/apps -Method GET -Headers $headers -UseBasicParsing > $TEMP_FILE_ONE


Get-Content $TEMP_FILE_ONE



# Get Home Folder

$rootFolderIdOne = (Get-Content $TEMP_FILE_ONE | Select-String -SimpleMatch -CaseSensitive 'Home Folder -' -Context 1 | Select-Object -First 1 ) 

$rootFolderIdTwo = ($rootFolderIdOne -split '\n')[0]

$rootFolderIdThree = ( $rootFolderIdTwo | %{ $_.Split(':')[1];} )

$rootFolderId = $rootFolderIdThree.Trim()

Remove-Item -Path $TEMP_FILE_ONE -Force

# Get Children of Home Folder

Write-Output "ROOT FOLDER ID: ${rootFolderId}"

Write-Output "Invoke-RestMethod -Uri $uri/apps/$rootFolderId/children -Method GET -Headers $headers -UseBasicParsing"

Invoke-RestMethod -Uri $uri/apps/$rootFolderId/children -Method GET -Headers $headers -UseBasicParsing > $TEMP_FILE_ONE

Write-Output "$TEMP_FILE_ONE"

# Invoke-RestMethod -Uri $uri/apps/$rootFolderId/children -Method GET -Headers $headers -UseBasicParsing

$CONFIG_IO="${PSScriptRoot}\config_reader.ps1"


. $CONFIG_IO


$CONFIG=(ReadFromConfigFile "${PSScriptRoot}\settings.cfg") 2>&1 | out-null

Set-Variable -Name ACTIVE_DIRECTORY_MAIN_FOLDER -Value 'ACTIVE DIRECTORY'

# See if the ACTIVE DIRECTORY folder exists, if not create it

Get-Content "$TEMP_FILE_ONE"



if ((Get-Content "$TEMP_FILE_ONE" | Select-String -CaseSensitive ": ${ACTIVE_DIRECTORY_MAIN_FOLDER}" )){
Write-Output ""
Write-Output "${ACTIVE_DIRECTORY_MAIN_FOLDER} Folder Exists"
}else{
Write-Output "${ACTIVE_DIRECTORY_MAIN_FOLDER} Folder Create"
CREATE_CIMITRA_FOLDER_ENTITY "${ACTIVE_DIRECTORY_MAIN_FOLDER}" "Cimitra Active Directory Main Folder." "$rootFolderId"
Invoke-RestMethod -Uri $uri/apps/$rootFolderId/children -Method GET -Headers $headers -UseBasicParsing > $TEMP_FILE_ONE
}


$adRootFolderIdOne = (Get-Content $TEMP_FILE_ONE | Select-String -SimpleMatch -CaseSensitive ": ${ACTIVE_DIRECTORY_MAIN_FOLDER}" -Context 1 | Select-Object -First 1 ) 

$adRootFolderIdTwo = ($adRootFolderIdOne -split '\n')[0]

$adRootFolderIdThree = ( $adRootFolderIdTwo | %{ $_.Split(':')[1];} )

$adRootFolderId = $adRootFolderIdThree.Trim()


# Discover the ACTIVE DIRECTORY folder children

Invoke-RestMethod -Uri $uri/apps/$adRootFolderId/children -Method GET -Headers $headers -UseBasicParsing > $TEMP_FILE_ONE

# Get or create the ACTIVE DIRECTORY | ADMIN folder

$CONFIRM_ADMIN_FOLDER=(ConfirmFromConfigFile "${PSScriptRoot}\settings.cfg" "ACTIVE_DIRECTORY_ADMIN_FOLDER_LABEL")

if ( $CONFIRM_ADMIN_FOLDER ) 
{ 
Set-Variable -Name ACTIVE_DIRECTORY_ADMIN_FOLDER_LABEL -Value $CONFIG$ACTIVE_DIRECTORY_ADMIN_FOLDER_LABEL }
else{
Set-Variable -Name ACTIVE_DIRECTORY_ADMIN_FOLDER_LABEL -Value 'ADMIN' 
}

if ((Get-Content "$TEMP_FILE_ONE" | Select-String -CaseSensitive ": ${ACTIVE_DIRECTORY_ADMIN_FOLDER_LABEL}" )){
Write-Output ""
Write-Output "${ACTIVE_DIRECTORY_ADMIN_FOLDER_LABEL} Folder Exists"
}else{
Write-Output ""
Write-Output "${ACTIVE_DIRECTORY_ADMIN_FOLDER_LABEL} Folder Create"
CREATE_CIMITRA_FOLDER_ENTITY "${ACTIVE_DIRECTORY_ADMIN_FOLDER_LABEL}" "Cimitra Active Directory Integration ${ACTIVE_DIRECTORY_ADMIN_FOLDER_LABEL} App Folder" "$adRootFolderId"
}

# Get or create the ACTIVE DIRECTORY | DELEGATE folder

$CONFIRM_DELEGATE_FOLDER=(ConfirmFromConfigFile "${PSScriptRoot}\settings.cfg" "ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL")

if ( $CONFIRM_DELEGATE_FOLDER ) 
{ 
Set-Variable -Name ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL -Value $CONFIG$ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL }
else{
Set-Variable -Name ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL -Value 'DELEGATE' 
}

if ((Get-Content "$TEMP_FILE_ONE" | Select-String -CaseSensitive "\b${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL}\b" )){
Write-Output ""
Write-Output "${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL} Folder Exists"
}else{
Write-Output ""
Write-Output "${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL} Folder Create"
CREATE_CIMITRA_FOLDER_ENTITY "${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL}" "Cimitra Active Directory Integration ${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL} App Delegation Folder" "$adRootFolderId"
}

# Get or create the ACTIVE DIRECTORY | EXCLUDE folder

$CONFIRM_EXCLUDE_FOLDER=(ConfirmFromConfigFile "${PSScriptRoot}\settings.cfg" "ACTIVE_DIRECTORY_EXCLUDED_FOLDER_LABEL")

if ( $CONFIRM_EXCLUDE_FOLDER ) 
{ 
Set-Variable -Name ACTIVE_DIRECTORY_EXCLUDED_FOLDER_LABEL -Value $CONFIG$ACTIVE_DIRECTORY_EXCLUDED_FOLDER_LABEL }
else{
Set-Variable -Name ACTIVE_DIRECTORY_EXCLUDED_FOLDER_LABEL -Value 'EXCLUDE' 
}

if ((Get-Content "$TEMP_FILE_ONE" | Select-String -CaseSensitive "\b${ACTIVE_DIRECTORY_EXCLUDED_FOLDER_LABEL}\b" )){
Write-Output ""
Write-Output "${ACTIVE_DIRECTORY_EXCLUDED_FOLDER_LABEL} Folder Exists"
}else{
Write-Output ""
Write-Output "${ACTIVE_DIRECTORY_EXCLUDED_FOLDER_LABEL} Folder Create"
CREATE_CIMITRA_FOLDER_ENTITY "${ACTIVE_DIRECTORY_EXCLUDED_FOLDER_LABEL}" "Cimitra Active Directory Integration Exclude Folder. Any Cimitra Apps placed into this folder will not be recreated in the folder named: ${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL}." "$adRootFolderId"
}


# Confirm the ACTIVE DIRECTORY | DELEGATE folder

Invoke-RestMethod -Uri $uri/apps/$adRootFolderId/children -Method GET -Headers $headers -UseBasicParsing > $TEMP_FILE_ONE

if ((Get-Content "$TEMP_FILE_ONE") -match ": ${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL}"){

$delegateFolderIdOne = (Get-Content $TEMP_FILE_ONE | Select-String -SimpleMatch -CaseSensitive ": ${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL}" -Context 1 | Select-Object -First 1 ) 

$delegateFolderIdTwo = ($delegateFolderIdOne -split '\n')[0]

$delegateFolderIdThree = ( $delegateFolderIdTwo | %{ $_.Split(':')[1];} )

$delegateFolderId = $delegateFolderIdThree.Trim()

Remove-Item -Path $TEMP_FILE_ONE -Force

}else{
Write-Output "Error: Cannot Create or Discover the Folder: ${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL}"
Remove-Item -Path $TEMP_FILE_ONE -Force
exit 1
}

# Get the ACTIVE DIRECTORY folder children

Invoke-RestMethod -Uri $uri/apps/$delegateFolderId/children -Method GET -Headers $headers -UseBasicParsing > $TEMP_FILE_ONE


# Confirm/Create the ACTIVE DIRECTORY | DELEGATE | USER MANAGEMENT folder

$CONFIRM_USER_FOLDER=(ConfirmFromConfigFile "${PSScriptRoot}\settings.cfg" "ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL")

if ( $CONFIRM_USER_FOLDER ) 
{ 
Set-Variable -Name ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL -Value $CONFIG$ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL }
else{
Set-Variable -Name ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL -Value 'USER MANAGEMENT' 
}

if ((Get-Content "$TEMP_FILE_ONE") -match ": ${ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL}"){
Write-Output ""
Write-Output "${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL} - Folder Exists"
}else{
Write-Output ""
Write-Output "${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL} - Folder Create"
CREATE_CIMITRA_FOLDER_ENTITY "${ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL}" "Cimitra Active Directory Integration ${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL} App Delegation Folder." "$delegateFolderId"
Invoke-RestMethod -Uri $uri/apps/$delegateFolderId/children -Method GET -Headers $headers -UseBasicParsing > $TEMP_FILE_ONE
}

# Get USER MANAGEMENT Folder Id

$userManagementFolderIdOne = (Get-Content $TEMP_FILE_ONE | Select-String -SimpleMatch -CaseSensitive ": ${ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL}" -Context 1 | Select-Object -First 1 ) 

$userManagementFolderIdTwo = ($userManagementFolderIdOne -split '\n')[0]

$userManagementFolderIdThree = ( $userManagementFolderIdTwo | %{ $_.Split(':')[1];} )

$userManagementFolderId = $userManagementFolderIdThree.Trim()

Invoke-RestMethod -Uri $uri/apps/$userManagementFolderId/children -Method GET -Headers $headers -UseBasicParsing > $TEMP_FILE_ONE


# Confirm/Create the ACTIVE DIRECTORY | DELEGATE | USER MANAGEMENT | USER ACCESS folder

$CONFIRM_USER_ACCESS_FOLDER=(ConfirmFromConfigFile "${PSScriptRoot}\settings.cfg" "ACTIVE_DIRECTORY_USER_ACCESS_FOLDER_LABEL")

if ( $CONFIRM_USER_ACCESS_FOLDER ) 
{ 
Set-Variable -Name ACTIVE_DIRECTORY_USER_ACCESS_FOLDER_LABE-Value $CONFIG$ACTIVE_DIRECTORY_USER_ACCESS_FOLDER_LABEL }
else{
Set-Variable -Name ACTIVE_DIRECTORY_USER_ACCESS_FOLDER_LABE -Value 'USER ACCESS' 
}

if ((Get-Content "$TEMP_FILE_ONE") -match ": ${ACTIVE_DIRECTORY_USER_ACCESS_FOLDER_LABEL}"){
Write-Output ""
Write-Output "${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_USER_ACCESS_FOLDER_LABEL} - Folder Exists"
}else{
Write-Output ""
Write-Output "${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_USER_ACCESS_FOLDER_LABEL} - Folder Create"
CREATE_CIMITRA_FOLDER_ENTITY "${ACTIVE_DIRECTORY_USER_ACCESS_FOLDER_LABEL}" "Cimitra Active Directory Integration ${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_USER_ACCESS_FOLDER_LABEL} App Delegation Folder." "$userManagementFolderId"
}



# Confirm/Create the ACTIVE DIRECTORY | DELEGATE | USER MANAGEMENT | USER CHANGES folder

$CONFIRM_USER_CHANGES_FOLDER=(ConfirmFromConfigFile "${PSScriptRoot}\settings.cfg" "ACTIVE_DIRECTORY_USER_CHANGES_FOLDER_LABEL")

if ( $CONFIRM_USER_CHANGES_FOLDER ) 
{ 
Set-Variable -Name ACTIVE_DIRECTORY_USER_CHANGES_FOLDER_LABE-Value $CONFIG$ACTIVE_DIRECTORY_USER_CHANGES_FOLDER_LABEL }
else{
Set-Variable -Name ACTIVE_DIRECTORY_USER_CHANGES_FOLDER_LABE -Value 'USER CHANGES' 
}

if ((Get-Content "$TEMP_FILE_ONE") -match ": ${ACTIVE_DIRECTORY_USER_CHANGES_FOLDER_LABEL}"){
Write-Output ""
Write-Output "${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_USER_CHANGES_FOLDER_LABEL} - Folder Exists"
}else{
Write-Output ""
Write-Output "${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_USER_CHANGES_FOLDER_LABEL} - Folder Create"
CREATE_CIMITRA_FOLDER_ENTITY "${ACTIVE_DIRECTORY_USER_CHANGES_FOLDER_LABEL}" "Cimitra Active Directory Integration ${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_USER_CHANGES_FOLDER_LABEL} App Delegation Folder." "$userManagementFolderId"
}

# Confirm/Create the ACTIVE DIRECTORY | DELEGATE | USER MANAGEMENT | USER REPORTS folder

$CONFIRM_USER_REPORTS_FOLDER=(ConfirmFromConfigFile "${PSScriptRoot}\settings.cfg" "ACTIVE_DIRECTORY_USER_REPORTS_FOLDER_LABEL")

if ( $CONFIRM_USER_REPORTS_FOLDER ) 
{ 
Set-Variable -Name ACTIVE_DIRECTORY_USER_REPORTS_FOLDER_LABEL -Value $CONFIG$ACTIVE_DIRECTORY_USER_REPORTS_FOLDER_LABEL }
else{
Set-Variable -Name ACTIVE_DIRECTORY_USER_REPORTS_FOLDER_LABEL -Value 'USER REPORTS' 
}

if ((Get-Content "$TEMP_FILE_ONE") -match ": ${ACTIVE_DIRECTORY_USER_REPORTS_FOLDER_LABEL}"){
Write-Output ""
Write-Output "${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_USER_REPORTS_FOLDER_LABEL} - Folder Exists"
}else{
Write-Output ""
Write-Output "${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_USER_REPORTS_FOLDER_LABEL} - Folder Create"
CREATE_CIMITRA_FOLDER_ENTITY "${ACTIVE_DIRECTORY_USER_REPORTS_FOLDER_LABEL}" "Cimitra Active Directory Integration ${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_USER_REPORTS_FOLDER_LABEL} App Delegation Folder." "$userManagementFolderId"
}

# Confirm/Create the ACTIVE DIRECTORY | DELEGATE | USER MANAGEMENT | CREATE folder

$CONFIRM_USER_CREATE_FOLDER=(ConfirmFromConfigFile "${PSScriptRoot}\settings.cfg" "ACTIVE_DIRECTORY_USER_CREATE_FOLDER_LABEL")

if ( $CONFIRM_USER_CREATE_FOLDER ) 
{ 
Set-Variable -Name ACTIVE_DIRECTORY_USER_CREATE_FOLDER_LABEL -Value $CONFIG$ACTIVE_DIRECTORY_USER_CREATE_FOLDER_LABEL }
else{
Set-Variable -Name ACTIVE_DIRECTORY_USER_CREATE_FOLDER_LABEL -Value 'USER CREATE' 
}

if ((Get-Content "$TEMP_FILE_ONE") -match ": ${ACTIVE_DIRECTORY_USER_CREATE_FOLDER_LABEL}"){
Write-Output ""
Write-Output "${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_USER_CREATE_FOLDER_LABEL} - Folder Exists"
}else{
Write-Output ""
Write-Output "${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_USER_CREATE_FOLDER_LABEL} - Folder Create"
CREATE_CIMITRA_FOLDER_ENTITY "${ACTIVE_DIRECTORY_USER_CREATE_FOLDER_LABEL}" "Cimitra Active Directory Integration ${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_USER_CREATE_FOLDER_LABEL} App Delegation Folder." "$userManagementFolderId"
}


$CONFIRM_USER_REMOVE_FOLDER=(ConfirmFromConfigFile "${PSScriptRoot}\settings.cfg" "ACTIVE_DIRECTORY_USER_REMOVE_CHANGE_DELETE_FOLDER_LABEL")

if ( $CONFIRM_USER_CREATE_FOLDER ) 
{ 
Set-Variable -Name ACTIVE_DIRECTORY_USER_REMOVE_CHANGE_DELETE_FOLDER_LABEL -Value $CONFIG$ACTIVE_DIRECTORY_USER_REMOVE_CHANGE_DELETE_FOLDER_LABEL }
else{
Set-Variable -Name ACTIVE_DIRECTORY_USER_REMOVE_CHANGE_DELETE_FOLDER_LABEL -Value 'REMOVE/CHANGE/DELETE' 
}

if ((Get-Content "$TEMP_FILE_ONE") -match ": ${ACTIVE_DIRECTORY_USER_REMOVE_CHANGE_DELETE_FOLDER_LABEL}"){
Write-Output ""
Write-Output "${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_USER_REMOVE_CHANGE_DELETE_FOLDER_LABEL} - Folder Exists"
}else{
Write-Output ""
Write-Output "${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_USER_REMOVE_CHANGE_DELETE_FOLDER_LABEL} - Folder Create"
CREATE_CIMITRA_FOLDER_ENTITY "${ACTIVE_DIRECTORY_USER_REMOVE_CHANGE_DELETE_FOLDER_LABEL}" "Cimitra Active Directory Integration ${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_USER_REMOVE_CHANGE_DELETE_FOLDER_LABEL} App Delegation Folder." "$userManagementFolderId"
}


Invoke-RestMethod -Uri $uri/apps/$delegateFolderId/children -Method GET -Headers $headers -UseBasicParsing > $TEMP_FILE_ONE

# Confirm/Create the ACTIVE DIRECTORY | DELEGATE | COMPUTER MANAGEMENT folder

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
CREATE_CIMITRA_FOLDER_ENTITY "${ACTIVE_DIRECTORY_COMPUTER_MANAGEMENT_FOLDER_LABEL}" "Cimitra Active Directory Integration ${ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL} | ${ACTIVE_DIRECTORY_COMPUTER_MANAGEMENT_FOLDER_LABEL} App Delegation Folder." "$delegateFolderId"
}

try{
Remove-Item -Path $TEMP_FILE_ONE -Force
}catch{}


}

function REGISTER_FOLDER_NAMES{

try{

$CONFIG_IO="${PSScriptRoot}\config_reader.ps1"

. $CONFIG_IO 2>&1 | out-null

$settingsFile = "${PSScriptRoot}\settings.cfg"

confirmConfigSetting "$settingsFile" "ACTIVE_DIRECTORY_ADMIN_FOLDER_LABEL" "ADMIN"

confirmConfigSetting "$settingsFile" "ACTIVE_DIRECTORY_DELEGATED_FOLDER_LABEL" "DELEGATE"

confirmConfigSetting "$settingsFile" "ACTIVE_DIRECTORY_EXCLUDED_FOLDER_LABEL" "EXCLUDE"

confirmConfigSetting "$settingsFile" "ACTIVE_DIRECTORY_USER_MANAGEMENT_FOLDER_LABEL" "USER MANAGEMENT"

confirmConfigSetting "$settingsFile" "ACTIVE_DIRECTORY_USER_ACCESS_FOLDER_LABEL" "USER ACCESS"

confirmConfigSetting "$settingsFile" "ACTIVE_DIRECTORY_USER_CHANGES_FOLDER_LABEL" "USER CHANGES"

confirmConfigSetting "$settingsFile" "ACTIVE_DIRECTORY_USER_REPORTS_FOLDER_LABEL" "USER REPORTS"

confirmConfigSetting "$settingsFile" "ACTIVE_DIRECTORY_USER_CREATE_FOLDER_LABEL" "CREATE"

confirmConfigSetting "$settingsFile" "ACTIVE_DIRECTORY_USER_REMOVE_CHANGE_DELETE_FOLDER_LABEL" "REMOVE/CHANGE/DELETE"

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



# CREATE_CIMITRA_LINK_ENTITY "LINK NAME" "LINK DESCRIPTION" "LINK URL" "PARENT FOLDER"

CREATE_CIMITRA_LINK_ENTITY "CIMITRA/ACTIVE DIRECTORY DOCS" "Cimitra Active Directory Integration Module Documentation" "https://www.cimitra.com/addocs" "${adRootFolderId}"

CREATE_CIMITRA_LINK_ENTITY "What is The ADMIN Folder For?" "Cimitra Active Directory Integration Module Documentation" "https://www.cimitra.com/addocs" "${adAdminFolderId}"

CREATE_CIMITRA_LINK_ENTITY "What is The EXCLUDE Folder For?" "Cimitra Active Directory Integration Module Documentation" "https://www.cimitra.com/addocs" "${adExcludeFolderId}"

###########################
###########################
#*****USER MANAGEMENT*****#
###########################
###########################

######################
# USER ACCESS Folder #
######################

$jsonFile = "{`"type`":1,`"status`":`"active`",`"platform`":`"win32`",`"interpreter`":`"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`",`"command`":`"${scriptRoot}\\ListUsers.ps1`",`"params`":`" -showErrors `",`"agentId`":`"${cimitraAgentId}`",`"name`":`"LIST USERS`",`"notes`":`"NOTE - Make sure that in the file 'settings.cfg' the 'AD_USER_CONTEXT' value is properly configured with the Active Directory Context where this script is supposed to be looking to.`",`"description`":`"List Computers in an Active Directory Context`",`"parentFolderId`":`"${adUserAccessId}`"}"
CREATE_CIMITRA_APP "LIST USERS" "ListUsers.ps1" "${adUserAccessId}" "${adExcludeFolderId}" "$jsonFile"

$jsonFile = "{`"type`":1,`"status`":`"active`",`"platform`":`"win32`",`"injectParams`":[{`"param`":`"-firstNameIn `",`"value`":`"`",`"label`":`"First Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Jane`"},{`"param`":`"-lastNameIn `",`"value`":`"`",`"label`":`"Last Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Doe`"}],`"interpreter`":`"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`",`"command`":`"${scriptRoot}\\GetUserInfo.ps1`",`"params`":`" -showErrors `",`"agentId`":`"${cimitraAgentId}`",`"name`":`"GET USER INFO`",`"notes`":`"NOTE - Make sure that in the file 'settings.cfg' the 'AD_USER_CONTEXT' value is properly configured with the Active Directory Context where this script is supposed to be looking to.`",`"description`":`"Get Information About a User's Account in Active Directory.`",`"parentFolderId`":`"${adUserAccessId}`"}"
CREATE_CIMITRA_APP "GET USER INFO" "GetUserInfo.ps1" "${adUserAccessId}" "${adExcludeFolderId}" "$jsonFile"

$jsonFile = "{`"type`":1,`"status`":`"active`",`"platform`":`"win32`",`"injectParams`":[{`"param`":`"-firstNameIn `",`"value`":`"`",`"label`":`"First Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Jane`"},{`"param`":`"-lastNameIn `",`"value`":`"`",`"label`":`"Last Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Doe`"},{`"param`":`"-passwordIn `",`"value`":`"`",`"label`":`"Password`",`"regex`":`"/^[0-9A-Za-z_+-=]+`$/`",`"placeholder`":`"p433w0r9_ch4ng3`",`"private`":true}],`"interpreter`":`"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`",`"command`":`"${scriptRoot}\\SetUserPassword.ps1`",`"params`":`" -showErrors `",`"agentId`":`"${cimitraAgentId}`",`"name`":`"CHANGE USER PASSWORD`",`"notes`":`"NOTE - Make sure that in the file 'settings.cfg' the 'AD_USER_CONTEXT' value is properly configured with the Active Directory Context where this script is supposed to be looking to.`",`"description`":`"Change a User Password in Active Directory`",`"parentFolderId`":`"${adUserAccessId}`"}"
CREATE_CIMITRA_APP "CHANGE USER PASSWORD" "SetUserPassword.ps1" "${adUserAccessId}" "${adExcludeFolderId}" "$jsonFile"

$jsonFile = "{`"type`":1,`"status`":`"active`",`"platform`":`"win32`",`"injectParams`":[{`"param`":`"-firstNameIn `",`"value`":`"`",`"label`":`"First Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Jane`"},{`"param`":`"-lastNameIn `",`"value`":`"`",`"label`":`"Last Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Doe`"}],`"interpreter`":`"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`",`"command`":`"${scriptRoot}\\CheckPasswordSetDate.ps1`",`"params`":`" -showErrors `",`"agentId`":`"${cimitraAgentId}`",`"name`":`"CHECK PASSWORD CHANGE DATE`",`"notes`":`"NOTE - Make sure that in the file 'settings.cfg' the 'AD_USER_CONTEXT' value is properly configured with the Active Directory Context where this script is supposed to be looking to.`",`"description`":`"Check When a User Password Was Last Changed in Active Directory`",`"parentFolderId`":`"${adUserAccessId}`"}"
CREATE_CIMITRA_APP "CHECK PASSWORD CHANGE DATE" "CheckPasswordSetDate.ps1" "${adUserAccessId}" "${adExcludeFolderId}" "$jsonFile"

$jsonFile = "{`"type`":1,`"status`":`"active`",`"platform`":`"win32`",`"injectParams`":[{`"param`":`"-firstNameIn `",`"value`":`"`",`"label`":`"First Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Jane`"},{`"param`":`"-lastNameIn `",`"value`":`"`",`"label`":`"Last Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Doe`"}],`"interpreter`":`"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`",`"command`":`"${scriptRoot}\\UnlockUser.ps1`",`"params`":`" -showErrors `",`"agentId`":`"${cimitraAgentId}`",`"name`":`"UNLOCK USER ACCOUNT`",`"notes`":`"NOTE - Make sure that in the file 'settings.cfg' the 'AD_USER_CONTEXT' value is properly configured with the Active Directory Context where this script is supposed to be looking to.`",`"description`":`"Unlock a user Active Directory account.`",`"parentFolderId`":`"${adUserAccessId}`"}"
CREATE_CIMITRA_APP "UNLOCK USER ACCOUNT" "UnlockUser.ps1" "${adUserAccessId}" "${adExcludeFolderId}" "$jsonFile"

$jsonFile = "{`"type`":1,`"status`":`"active`",`"platform`":`"win32`",`"interpreter`":`"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`",`"command`":`"${scriptRoot}\\ListUsersExpired.ps1`",`"params`":`" -showErrors `",`"agentId`":`"${cimitraAgentId}`",`"name`":`"LIST EXPIRED USERS`",`"notes`":`" `",`"description`":`"List All User Accounts Currently Expired`",`"parentFolderId`":`"${adUserAccessId}`"}"
CREATE_CIMITRA_APP "LIST EXPIRED USERS" "ListUsersExpired.ps1" "${adUserAccessId}" "${adExcludeFolderId}" "$jsonFile"
 
$jsonFile = "{`"type`":1,`"status`":`"active`",`"platform`":`"win32`",`"injectParams`":[{`"param`":`"-firstNameIn `",`"value`":`"`",`"label`":`"First Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Jane`"},{`"param`":`"-lastNameIn `",`"value`":`"`",`"label`":`"Last Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Doe`"},{`"param`":`"-expireDateIn `",`"value`":`"`",`"label`":`"Expire Date - Syntax: 2/2/2022`",`"regex`":`"/^[0-9\/]+$/`",`"placeholder`":`"2/2/2022`",`"private`":false}],`"interpreter`":`"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`",`"command`":`"${scriptRoot}\\SetUserExpireDate.ps1`",`"params`":`" -showErrors `",`"agentId`":`"${cimitraAgentId}`",`"name`":`"SET ACCOUNT EXPIRE DATE`",`"notes`":`"NOTE - Make sure that in the file 'settings.cfg' the 'AD_USER_CONTEXT' value is properly configured with the Active Directory Context where this script is supposed to be looking to.`",`"description`":`"Set User Account Expire Date in Active Directory`",`"parentFolderId`":`"${adUserAccessId}`"}"
CREATE_CIMITRA_APP "SET ACCOUNT EXPIRE DATE" "SetUserExpireDate.ps1" "${adUserAccessId}" "${adExcludeFolderId}" "$jsonFile"

$jsonFile = "{`"type`":1,`"status`":`"active`",`"platform`":`"win32`",`"injectParams`":[{`"param`":`"-firstNameIn `",`"value`":`"`",`"label`":`"First Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Jane`"},{`"param`":`"-lastNameIn `",`"value`":`"`",`"label`":`"Last Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Doe`"}],`"interpreter`":`"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`",`"command`":`"${scriptRoot}\\RemoveUserExpireDate.ps1`",`"params`":`" -showErrors `",`"agentId`":`"${cimitraAgentId}`",`"name`":`"REMOVE ACCOUNT EXPIRE DATE`",`"notes`":`"NOTE - Make sure that in the file 'settings.cfg' the 'AD_USER_CONTEXT' value is properly configured with the Active Directory Context where this script is supposed to be looking to.`",`"description`":`"Remove a User Account Expire Date.`",`"parentFolderId`":`"${adUserAccessId}`"}"
CREATE_CIMITRA_APP "REMOVE ACCOUNT EXPIRE DATE" "RemoveUserExpireDate.ps1" "${adUserAccessId}" "${adExcludeFolderId}" "$jsonFile"

$jsonFile = "{`"type`":1,`"status`":`"active`",`"platform`":`"win32`",`"interpreter`":`"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`",`"command`":`"${scriptRoot}\\ListUsersWithExpireDate.ps1`",`"params`":`" -showErrors `",`"agentId`":`"${cimitraAgentId}`",`"name`":`"LIST USERS WITH EXPIRE DATE`",`"notes`":`" `",`"description`":`"List All Users Who Have an Expire Date in Active Directory`",`"parentFolderId`":`"${adUserAccessId}`"}"
CREATE_CIMITRA_APP "LIST USERS WITH EXPIRE DATE" "ListUsersWithExpireDate.ps1" "${adUserAccessId}" "${adExcludeFolderId}" "$jsonFile"
 
$jsonFile = "{`"type`":1,`"status`":`"active`",`"platform`":`"win32`",`"injectParams`":[{`"param`":`"-firstNameIn `",`"value`":`"`",`"label`":`"First Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Jane`"},{`"param`":`"-lastNameIn `",`"value`":`"`",`"label`":`"Last Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Doe`"}],`"interpreter`":`"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`",`"command`":`"${scriptRoot}\\DisableUserAccount.ps1`",`"params`":`" -showErrors `",`"agentId`":`"${cimitraAgentId}`",`"name`":`"DISABLE USER ACCOUNT`",`"notes`":`"NOTE - Make sure that in the file 'settings.cfg' the 'AD_USER_CONTEXT' value is properly configured with the Active Directory Context where this script is supposed to be looking to.`",`"description`":`"Disable a User Active Directory account.`",`"parentFolderId`":`"${adUserAccessId}`"}"
CREATE_CIMITRA_APP "DISABLE USER ACCOUNT" "DisableUserAccount.ps1" "${adUserAccessId}" "${adExcludeFolderId}" "$jsonFile"

$jsonFile = "{`"type`":1,`"status`":`"active`",`"platform`":`"win32`",`"injectParams`":[{`"param`":`"-firstNameIn `",`"value`":`"`",`"label`":`"First Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Jane`"},{`"param`":`"-lastNameIn `",`"value`":`"`",`"label`":`"Last Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Doe`"}],`"interpreter`":`"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`",`"command`":`"${scriptRoot}\\EnableUserAccount.ps1`",`"params`":`" -showErrors `",`"agentId`":`"${cimitraAgentId}`",`"name`":`"ENABLE USER ACCOUNT`",`"notes`":`"NOTE - Make sure that in the file 'settings.cfg' the 'AD_USER_CONTEXT' value is properly configured with the Active Directory Context where this script is supposed to be looking to.`",`"description`":`"Enable a User Active Directory account.`",`"parentFolderId`":`"${adUserAccessId}`"}"
CREATE_CIMITRA_APP "ENABLE USER ACCOUNT" "EnableUserAccount.ps1" "${adUserAccessId}" "${adExcludeFolderId}" "$jsonFile"

$jsonFile = "{`"type`":1,`"status`":`"active`",`"platform`":`"win32`",`"interpreter`":`"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`",`"command`":`"${scriptRoot}\\ListUsersDisabled.ps1`",`"params`":`" -showErrors `",`"agentId`":`"${cimitraAgentId}`",`"name`":`"LIST DISABLED ACCOUNTS`",`"notes`":`" `",`"description`":`"List Disabled User Accounts in Active Directory`",`"parentFolderId`":`"${adUserAccessId}`"}"
CREATE_CIMITRA_APP "LIST DISABLED ACCOUNTS" "ListUsersDisabled.ps1" "${adUserAccessId}" "${adExcludeFolderId}" "$jsonFile"

#####################


#######################
# USER CHANGES Folder #
#######################

$jsonFile = "{`"type`":1,`"status`":`"active`",`"platform`":`"win32`",`"interpreter`":`"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`",`"command`":`"${scriptRoot}\\ListUsers.ps1`",`"params`":`" -showErrors `",`"agentId`":`"${cimitraAgentId}`",`"name`":`"LIST USERS`",`"notes`":`"NOTE - Make sure that in the file 'settings.cfg' the 'AD_USER_CONTEXT' value is properly configured with the Active Directory Context where this script is supposed to be looking to.`",`"description`":`"List Computers in an Active Directory Context`",`"parentFolderId`":`"${adUserChangesId}`"}"
CREATE_CIMITRA_APP "LIST USERS" "ListUsers.ps1" "${adUserChangesId}" "${adExcludeFolderId}" "$jsonFile"

$jsonFile = "{`"type`":1,`"status`":`"active`",`"platform`":`"win32`",`"injectParams`":[{`"param`":`"-firstNameIn `",`"value`":`"`",`"label`":`"First Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Jane`"},{`"param`":`"-lastNameIn `",`"value`":`"`",`"label`":`"Last Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Doe`"}],`"interpreter`":`"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`",`"command`":`"${scriptRoot}\\GetUserInfo.ps1`",`"params`":`" -showErrors `",`"agentId`":`"${cimitraAgentId}`",`"name`":`"GET USER INFO`",`"notes`":`"NOTE - Make sure that in the file 'settings.cfg' the 'AD_USER_CONTEXT' value is properly configured with the Active Directory Context where this script is supposed to be looking to.`",`"description`":`"Get Information About a User's Account in Active Directory.`",`"parentFolderId`":`"${adUserChangesId}`"}"
CREATE_CIMITRA_APP "GET USER INFO" "GetUserInfo.ps1" "${adUserChangesId}" "${adExcludeFolderId}" "$jsonFile"

$jsonFile = "{`"type`":1,`"status`":`"active`",`"platform`":`"win32`",`"injectParams`":[{`"param`":`"-firstNameIn `",`"value`":`"`",`"label`":`"First Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Jane`"},{`"param`":`"-lastNameIn `",`"value`":`"`",`"label`":`"Last Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Doe`"},{`"param`":`"-officePhoneIn `",`"value`":`"`",`"label`":`"Office Phone Number - Syntax: 801-555-1212`",`"regex`":`"/^[0-9-+ ]+$/`",`"placeholder`":`"801-555-1212`",`"private`":false}],`"interpreter`":`"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`",`"command`":`"${scriptRoot}\\SetUserOfficePhone.ps1`",`"params`":`" -showErrors `",`"agentId`":`"${cimitraAgentId}`",`"name`":`"SET USER OFFICE PHONE`",`"notes`":`"NOTE - Make sure that in the file 'settings.cfg' the 'AD_USER_CONTEXT' value is properly configured with the Active Directory Context where this script is supposed to be looking to.`",`"description`":`"Set User Office Phone Number in Active Directory`",`"parentFolderId`":`"${adUserChangesId}`"}"
CREATE_CIMITRA_APP "SET USER OFFICE PHONE" "SetUserOfficePhone.ps1" "${adUserChangesId}" "${adExcludeFolderId}" "$jsonFile"

$jsonFile = "{`"type`":1,`"status`":`"active`",`"platform`":`"win32`",`"injectParams`":[{`"param`":`"-firstNameIn `",`"value`":`"`",`"label`":`"First Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Jane`"},{`"param`":`"-lastNameIn `",`"value`":`"`",`"label`":`"Last Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Doe`"},{`"param`":`"-mobilePhoneIn `",`"value`":`"`",`"label`":`"Mobile Phone Number - Syntax: 801-555-1212`",`"regex`":`"/^[0-9-+ ]+$/`",`"placeholder`":`"801-555-1212`",`"private`":false}],`"interpreter`":`"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`",`"command`":`"${scriptRoot}\\SetUserMobilePhone.ps1`",`"params`":`" -showErrors `",`"agentId`":`"${cimitraAgentId}`",`"name`":`"SET USER MOBILE PHONE`",`"notes`":`"NOTE - Make sure that in the file 'settings.cfg' the 'AD_USER_CONTEXT' value is properly configured with the Active Directory Context where this script is supposed to be looking to.`",`"description`":`"Set User Mobile Phone Number in Active Directory`",`"parentFolderId`":`"${adUserChangesId}`"}"
CREATE_CIMITRA_APP "SET USER MOBILE PHONE" "SetUserMobilePhone.ps1" "${adUserChangesId}" "${adExcludeFolderId}" "$jsonFile"

$jsonFile = "{`"type`":1,`"status`":`"active`",`"platform`":`"win32`",`"injectParams`":[{`"param`":`"-firstNameIn `",`"value`":`"`",`"label`":`"First Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Jane`"},{`"param`":`"-lastNameIn `",`"value`":`"`",`"label`":`"Last Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Doe`"},{`"param`":`"-departmentIn `",`"value`":`"`",`"label`":`"Department Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+$/`",`"placeholder`":`"Finance`",`"private`":false}],`"interpreter`":`"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`",`"command`":`"${scriptRoot}\\SetUserDepartment.ps1`",`"params`":`" -showErrors `",`"agentId`":`"${cimitraAgentId}`",`"name`":`"SET USER DEPARTMENT`",`"notes`":`"NOTE - Make sure that in the file 'settings.cfg' the 'AD_USER_CONTEXT' value is properly configured with the Active Directory Context where this script is supposed to be looking to.`",`"description`":`"Set User Department in Active Directory`",`"parentFolderId`":`"${adUserChangesId}`"}"
CREATE_CIMITRA_APP "SET USER DEPARTMENT" "SetUserDepartment.ps1" "${adUserChangesId}" "${adExcludeFolderId}" "$jsonFile"

$jsonFile = "{`"type`":1,`"status`":`"active`",`"platform`":`"win32`",`"injectParams`":[{`"param`":`"-firstNameIn `",`"value`":`"`",`"label`":`"First Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Jane`"},{`"param`":`"-lastNameIn `",`"value`":`"`",`"label`":`"Last Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Doe`"},{`"param`":`"-titleIn `",`"value`":`"`",`"label`":`"Title`",`"regex`":`"/^[0-9A-Za-z_+-= ]+$/`",`"placeholder`":`"Auditor`",`"private`":false}],`"interpreter`":`"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`",`"command`":`"${scriptRoot}\\SetUserTitle.ps1`",`"params`":`" -showErrors `",`"agentId`":`"${cimitraAgentId}`",`"name`":`"SET USER TITLE`",`"notes`":`"NOTE - Make sure that in the file 'settings.cfg' the 'AD_USER_CONTEXT' value is properly configured with the Active Directory Context where this script is supposed to be looking to.`",`"description`":`"Set User Title in Active Directory`",`"parentFolderId`":`"${adUserChangesId}`"}"
CREATE_CIMITRA_APP "SET USER TITLE" "SetUserTitle.ps1" "${adUserChangesId}" "${adExcludeFolderId}" "$jsonFile"

$jsonFile = "{`"type`":1,`"status`":`"active`",`"platform`":`"win32`",`"injectParams`":[{`"param`":`"-firstNameIn `",`"value`":`"`",`"label`":`"First Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Jane`"},{`"param`":`"-lastNameIn `",`"value`":`"`",`"label`":`"Last Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Doe`"},{`"param`":`"-descriptionIn `",`"value`":`"`",`"label`":`"Title`",`"regex`":`"/^[0-9A-Za-z_+-= ]+$/`",`"placeholder`":`"Auditing Team Member`",`"private`":false}],`"interpreter`":`"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`",`"command`":`"${scriptRoot}\\SetUserDescription.ps1`",`"params`":`" -showErrors `",`"agentId`":`"${cimitraAgentId}`",`"name`":`"SET USER DESCRIPTION`",`"notes`":`"NOTE - Make sure that in the file 'settings.cfg' the 'AD_USER_CONTEXT' value is properly configured with the Active Directory Context where this script is supposed to be looking to.`",`"description`":`"Set User Description in Active Directory`",`"parentFolderId`":`"${adUserChangesId}`"}"
CREATE_CIMITRA_APP "SET USER DESCRIPTION" "SetUserDescription.ps1" "${adUserChangesId}" "${adExcludeFolderId}" "$jsonFile"

#####################


#####################
# USER REPORTS Folder
#####################

$jsonFile = "{`"type`":1,`"status`":`"active`",`"platform`":`"win32`",`"interpreter`":`"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`",`"command`":`"${scriptRoot}\\ListUsers.ps1`",`"params`":`" -showErrors `",`"agentId`":`"${cimitraAgentId}`",`"name`":`"LIST USERS`",`"notes`":`"NOTE - Make sure that in the file 'settings.cfg' the 'AD_USER_CONTEXT' value is properly configured with the Active Directory Context where this script is supposed to be looking to.`",`"description`":`"List Computers in an Active Directory Context`",`"parentFolderId`":`"${adUserReportsId}`"}"
CREATE_CIMITRA_APP "LIST USERS" "ListUsers.ps1" "${adUserReportsId}" "${adExcludeFolderId}" "$jsonFile"
 
$jsonFile = "{`"type`":1,`"status`":`"active`",`"platform`":`"win32`",`"interpreter`":`"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`",`"command`":`"${scriptRoot}\\ListUsersDistinguishedNames.ps1`",`"params`":`" -showErrors `",`"agentId`":`"${cimitraAgentId}`",`"name`":`"LIST ALL USERS IN AD TREE`",`"notes`":`" `",`"description`":`"List All Users in an Entire Active Directory Tree`",`"parentFolderId`":`"${adUserReportsId}`"}"
CREATE_CIMITRA_APP "LIST ALL USERS IN AD TREE" "ListUsersDistinguishedNames.ps1" "${adUserReportsId}" "${adExcludeFolderId}" "$jsonFile"

$jsonFile = "{`"type`":1,`"status`":`"active`",`"platform`":`"win32`",`"interpreter`":`"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`",`"command`":`"${scriptRoot}\\ListUsersNoLogon.ps1`",`"params`":`" -showErrors `",`"agentId`":`"${cimitraAgentId}`",`"name`":`"LIST NO LOGON ACCOUNTS`",`"notes`":`" `",`"description`":`"List User Accounts in Active Directory With No Logon Events`",`"parentFolderId`":`"${adUserReportsId}`"}"
CREATE_CIMITRA_APP "LIST NO LOGON ACCOUNTS" "ListUsersNoLogon.ps1" "${adUserReportsId}" "${adExcludeFolderId}" "$jsonFile"

#####################


#################
# CREATE Folder #
#################

$jsonFile = "{`"type`":1,`"status`":`"active`",`"platform`":`"win32`",`"interpreter`":`"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`",`"command`":`"${scriptRoot}\\ListUsers.ps1`",`"params`":`" -showErrors `",`"agentId`":`"${cimitraAgentId}`",`"name`":`"LIST USERS`",`"notes`":`"NOTE - Make sure that in the file 'settings.cfg' the 'AD_USER_CONTEXT' value is properly configured with the Active Directory Context where this script is supposed to be looking to.`",`"description`":`"List Computers in an Active Directory Context`",`"parentFolderId`":`"${adUserCreateId}`"}"
CREATE_CIMITRA_APP "LIST USERS" "ListUsers.ps1" "${adUserCreateId}" "${adExcludeFolderId}" "$jsonFile"

$jsonFile = "{`"type`":1,`"status`":`"active`",`"platform`":`"win32`",`"injectParams`":[{`"param`":`"-firstNameIn `",`"value`":`"`",`"label`":`"First Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Jane`"},{`"param`":`"-lastNameIn `",`"value`":`"`",`"label`":`"Last Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Doe`"}],`"interpreter`":`"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`",`"command`":`"${scriptRoot}\\GetUserInfo.ps1`",`"params`":`" -showErrors `",`"agentId`":`"${cimitraAgentId}`",`"name`":`"GET USER INFO`",`"notes`":`"NOTE - Make sure that in the file 'settings.cfg' the 'AD_USER_CONTEXT' value is properly configured with the Active Directory Context where this script is supposed to be looking to.`",`"description`":`"Get Information About a User's Account in Active Directory.`",`"parentFolderId`":`"${adUserCreateId}`"}"
CREATE_CIMITRA_APP "GET USER INFO" "GetUserInfo.ps1" "${adUserCreateId}" "${adExcludeFolderId}" "$jsonFile"

$jsonFile = "{`"type`":1,`"status`":`"active`",`"platform`":`"win32`",`"injectParams`":[{`"param`":`"-firstNameIn `",`"value`":`"`",`"label`":`"First Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Jane`"},{`"param`":`"-lastNameIn `",`"value`":`"`",`"label`":`"Last Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Doe`"},{`"param`":`"-passwordIn `",`"value`":`"`",`"label`":`"Password`",`"regex`":`"/^[0-9A-Za-z_+-=]+`$/`",`"placeholder`":`"p433w0r9_ch4ng3`",`"private`":true}],`"interpreter`":`"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`",`"command`":`"${scriptRoot}\\NewUser.ps1`",`"params`":`" -showErrors `",`"agentId`":`"${cimitraAgentId}`",`"name`":`"CREATE USER`",`"notes`":`"NOTE - Make sure that in the file 'settings.cfg' the 'AD_USER_CONTEXT' value is properly configured with the Active Directory Context where this script is supposed to be looking to.`",`"description`":`"Create a User in Active Directory`",`"parentFolderId`":`"${adUserCreateId}`"}"
CREATE_CIMITRA_APP "CREATE USER" "NewUser.ps1" "${adUserCreateId}" "${adExcludeFolderId}" "$jsonFile"

$jsonFile = "{`"type`":1,`"status`":`"active`",`"platform`":`"win32`",`"injectParams`":[{`"param`":`"-dayCountIn `",`"value`":`"`",`"label`":`"NUMBER OF DAYS AGO`",`"regex`":`"/^[0-9A]+`$/`",`"placeholder`":`"7`"}],`"interpreter`":`"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`",`"command`":`"${scriptRoot}\\UsersCreationDate.ps1`",`"params`":`" -showErrors `",`"agentId`":`"${cimitraAgentId}`",`"name`":`"RECENTLY CREATED USERS`",`"notes`":`"NOTE - Make sure that in the file 'settings.cfg' the 'AD_USER_CONTEXT' value is properly configured with the Active Directory Context where this script is supposed to be looking to.`",`"description`":`"Report Users Created Recently.`",`"parentFolderId`":`"${adUserCreateId}`"}"
CREATE_CIMITRA_APP "RECENTLY CREATED USERS" "UsersCreationDate.ps1" "${adUserCreateId}" "${adExcludeFolderId}" "$jsonFile"

#####################


###############################
# REMOVE/CHANGE/DELETE Folder #
###############################

$jsonFile = "{`"type`":1,`"status`":`"active`",`"platform`":`"win32`",`"interpreter`":`"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`",`"command`":`"${scriptRoot}\\ListUsers.ps1`",`"params`":`" -showErrors `",`"agentId`":`"${cimitraAgentId}`",`"name`":`"LIST USERS`",`"notes`":`"NOTE - Make sure that in the file 'settings.cfg' the 'AD_USER_CONTEXT' value is properly configured with the Active Directory Context where this script is supposed to be looking to.`",`"description`":`"List Computers in an Active Directory Context`",`"parentFolderId`":`"${adUserRemoveId}`"}"
CREATE_CIMITRA_APP "LIST USERS" "ListUsers.ps1" "${adUserRemoveId}" "${adExcludeFolderId}" "$jsonFile"

$jsonFile = "{`"type`":1,`"status`":`"active`",`"platform`":`"win32`",`"injectParams`":[{`"param`":`"-firstNameIn `",`"value`":`"`",`"label`":`"First Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Jane`"},{`"param`":`"-lastNameIn `",`"value`":`"`",`"label`":`"Last Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Doe`"}],`"interpreter`":`"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`",`"command`":`"${scriptRoot}\\GetUserInfo.ps1`",`"params`":`" -showErrors `",`"agentId`":`"${cimitraAgentId}`",`"name`":`"GET USER INFO`",`"notes`":`"NOTE - Make sure that in the file 'settings.cfg' the 'AD_USER_CONTEXT' value is properly configured with the Active Directory Context where this script is supposed to be looking to.`",`"description`":`"Get Information About a User's Account in Active Directory.`",`"parentFolderId`":`"${adUserRemoveId}`"}"
CREATE_CIMITRA_APP "GET USER INFO" "GetUserInfo.ps1" "${adUserRemoveId}" "${adExcludeFolderId}" "$jsonFile"

$jsonFile = "{`"type`":1,`"status`":`"active`",`"platform`":`"win32`",`"injectParams`":[{`"param`":`"-firstNameIn `",`"value`":`"`",`"label`":`"First Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Jane`"},{`"param`":`"-lastNameIn `",`"value`":`"`",`"label`":`"Last Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Doe`"},{`"param`":`"-newFirstNameIn `",`"value`":`"`",`"label`":`"New First Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Janey`"},{`"param`":`"-newSamNameIn `",`"value`":`"`",`"label`":`"New User ID (SamAccountName) | Note you can also specify the current User Id.`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"jdoe`",`"private`":false}],`"interpreter`":`"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`",`"command`":`"${scriptRoot}\\SetUserFirstName.ps1`",`"params`":`" -showErrors `",`"agentId`":`"${cimitraAgentId}`",`"name`":`"CHANGE USER FIRST NAME`",`"notes`":`"NOTE - Make sure that in the file 'settings.cfg' the 'AD_USER_CONTEXT' value is properly configured with the Active Directory Context where this script is supposed to be looking to.`",`"description`":`"Change a User First Name in Active Directory`",`"parentFolderId`":`"${adUserRemoveId}`"}"
CREATE_CIMITRA_APP "CHANGE USER FIRST NAME" "SetUserFirstName.ps1" "${adUserRemoveId}" "${adExcludeFolderId}" "$jsonFile"

$jsonFile = "{`"type`":1,`"status`":`"active`",`"platform`":`"win32`",`"injectParams`":[{`"param`":`"-firstNameIn `",`"value`":`"`",`"label`":`"First Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Jane`"},{`"param`":`"-lastNameIn `",`"value`":`"`",`"label`":`"Last Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Doe`"},{`"param`":`"-newLastNameIn `",`"value`":`"`",`"label`":`"New Last Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Smith`"},{`"param`":`"-newSamNameIn `",`"value`":`"`",`"label`":`"New User ID (SamAccountName) | Note you can also specify the current User Id.`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"jsmith`",`"private`":false}],`"interpreter`":`"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`",`"command`":`"${scriptRoot}\\SetUserLastName.ps1`",`"params`":`" -showErrors `",`"agentId`":`"${cimitraAgentId}`",`"name`":`"CHANGE USER LAST NAME`",`"notes`":`"NOTE - Make sure that in the file 'settings.cfg' the 'AD_USER_CONTEXT' value is properly configured with the Active Directory Context where this script is supposed to be looking to.`",`"description`":`"Change a User Last Name in Active Directory`",`"parentFolderId`":`"${adUserRemoveId}`"}"
CREATE_CIMITRA_APP "CHANGE USER LAST NAME" "SetUserLastName.ps1" "${adUserRemoveId}" "${adExcludeFolderId}" "$jsonFile"

$jsonFile = "{`"type`":1,`"status`":`"active`",`"platform`":`"win32`",`"injectParams`":[{`"param`":`"-firstNameIn `",`"value`":`"`",`"label`":`"First Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Jane`"},{`"param`":`"-lastNameIn `",`"value`":`"`",`"label`":`"Last Name`",`"regex`":`"/^[0-9A-Za-z_+-= ]+`$/`",`"placeholder`":`"Doe`"},{`"param`":`"-confirmWordIn `",`"value`":`"`",`"label`":`"YES = Confirm`",`"regex`":`"/^[YES]+`$/`",`"placeholder`":`"YES`",`"private`":false}],`"interpreter`":`"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`",`"command`":`"${scriptRoot}\\RemoveUserAndConfirm.ps1`",`"params`":`" -showErrors `",`"agentId`":`"${cimitraAgentId}`",`"name`":`"REMOVE USER`",`"notes`":`"NOTE - Make sure that in the file 'settings.cfg' the 'AD_USER_CONTEXT' value is properly configured with the Active Directory Context where this script is supposed to be looking to.`",`"description`":`"Remove a User From Active Directory`",`"parentFolderId`":`"${adUserRemoveId}`"}"
CREATE_CIMITRA_APP "REMOVE USER" "RemoveUserAndConfirm.ps1" "${adUserRemoveId}" "${adExcludeFolderId}" "$jsonFile"


###############################
###############################
#*****COMPUTER MANAGEMENT*****#
###############################
###############################

$jsonFile = "{`"type`":1,`"status`":`"active`",`"platform`":`"win32`",`"injectParams`":[{`"param`":`"-computerNameIn `",`"value`":`"`",`"label`":`"Computer Name`",`"regex`":`"/^[0-9A-Za-z_-]+`$/`",`"placeholder`":`"WIN_COMPUTER_ONE`"},{`"param`":`"-computerTypeIn `",`"value`":`"`",`"label`":`"Computer Type (Mac=1, Win=2, Linux=3, ChromeOS=4, Other=5)`",`"regex`":`"/^[1-5]+`$/`",`"placeholder`":`"2`"}],`"interpreter`":`"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`",`"command`":`"${scriptRoot}\\NewComputer.ps1`",`"params`":`" -showErrors `",`"agentId`":`"${cimitraAgentId}`",`"name`":`"CREATE COMPUTER`",`"notes`":`"NOTE - Make sure that in the file 'settings.cfg' the 'AD_COMPUTER_CONTEXT' value is properly configured with the Active Directory Context where this script is supposed to be looking to.`",`"description`":`"Create a Computer Object in Active Directory`",`"parentFolderId`":`"${adComputerFolderId}`"}"
CREATE_CIMITRA_APP "CREATE COMPUTER" "NewComputer.ps1" "${adComputerFolderId}" "${adExcludeFolderId}" "$jsonFile"

$jsonFile = "{`"type`":1,`"status`":`"active`",`"platform`":`"win32`",`"interpreter`":`"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`",`"command`":`"${scriptRoot}\\ListComputers.ps1`",`"params`":`" -showErrors `",`"agentId`":`"${cimitraAgentId}`",`"name`":`"LIST COMPUTERS`",`"notes`":`"NOTE - Make sure that in the file 'settings.cfg' the 'AD_COMPUTER_CONTEXT' value is properly configured with the Active Directory Context where this script is supposed to be looking to.`",`"description`":`"List Computers in an Active Directory Tree Context`",`"parentFolderId`":`"${adComputerFolderId}`"}"
CREATE_CIMITRA_APP "LIST COMPUTERS" "ListComputers.ps1" "${adComputerFolderId}" "${adExcludeFolderId}" "$jsonFile"

$jsonFile = "{`"type`":1,`"status`":`"active`",`"platform`":`"win32`",`"injectParams`":[{`"param`":`"-computerNameIn `",`"value`":`"`",`"label`":`"Current Computer Name`",`"regex`":`"/^[0-9A-Za-z_+-=]+`$/`",`"placeholder`":`"WIN_COMPUTER_ONE`"},{`"param`":`"-newComputerNameIn `",`"value`":`"`",`"label`":`"New Computer Name`",`"regex`":`"/^[0-9A-Za-z_+-=]+`$/`",`"placeholder`":`"WIN_COMPUTER_TWO`"}],`"interpreter`":`"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`",`"command`":`"${scriptRoot}\\RenameComputer.ps1`",`"params`":`" -showErrors `",`"agentId`":`"${cimitraAgentId}`",`"name`":`"RENAME COMPUTER`",`"notes`":`"NOTE - Make sure that in the file 'settings.cfg' the 'AD_COMPUTER_CONTEXT' value is properly configured with the Active Directory Context where this script is supposed to be looking to.`",`"description`":`"Rename a Computer Object in Active Directory`",`"parentFolderId`":`"${adComputerFolderId}`"}"
CREATE_CIMITRA_APP "RENAME COMPUTER" "RenameComputer.ps1" "${adComputerFolderId}" "${adExcludeFolderId}" "$jsonFile"

$jsonFile = "{`"type`":1,`"status`":`"active`",`"platform`":`"win32`",`"interpreter`":`"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`",`"command`":`"${scriptRoot}\\ListComputersDistinguishedNames.ps1`",`"params`":`" -showErrors `",`"agentId`":`"${cimitraAgentId}`",`"name`":`"LIST ALL COMPUTERS IN AD TREE`",`"notes`":`" `",`"description`":`"List All Computers in an Entire Active Directory Tree`",`"parentFolderId`":`"${adComputerFolderId}`"}"
CREATE_CIMITRA_APP "LIST ALL COMPUTERS IN AD TREE" "ListComputersDistinguishedNames.ps1" "${adComputerFolderId}" "${adExcludeFolderId}" "$jsonFile"

$jsonFile = "{`"type`":1,`"status`":`"active`",`"platform`":`"win32`",`"injectParams`":[{`"param`":`"-computerNameIn `",`"value`":`"`",`"label`":`"Computer Name`",`"regex`":`"/^[0-9A-Za-z_+-=]+`$/`",`"placeholder`":`"WIN_COMPUTER_ONE`"}],`"interpreter`":`"C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe`",`"command`":`"${scriptRoot}\\RemoveComputer.ps1`",`"params`":`" -showErrors `",`"agentId`":`"${cimitraAgentId}`",`"name`":`"REMOVE COMPUTER`",`"notes`":`"NOTE - Make sure that in the file 'settings.cfg' the 'AD_COMPUTER_CONTEXT' value is properly configured with the Active Directory Context where this script is supposed to be looking to.`",`"description`":`"Remove a Computer From Active Directory`",`"parentFolderId`":`"${adComputerFolderId}`"}"
CREATE_CIMITRA_APP "REMOVE COMPUTER" "RemoveComputer.ps1" "${adComputerFolderId}" "${adExcludeFolderId}" "$jsonFile"

# ACTIVE DIRECTORY
# adRootFolderId

#ADMIN
# adAdminFolderId

# DELEGATE
# $adUserFolderId

# EXCLUDE
# adExcludeFolderId

# USER ACCESS
# $adUserAccessId

# USER CHANGES
# $adUserChangesId

# USER REPORTS
# $adUserReportsId

# <USER> CREATE
# $adUserCreateId

# <USER> REMOVE/CHANGE/DELETE
# $adUserRemoveId

# COMPUTERS
# $adComputerFolderId


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
    Write-Host "[1] [CONFIGURE] Cimitra Integration Admin User"
    Write-Host "" 
    Write-Host "[2] [CHECK] Cimitra Integration Admin User Configuration"
    Write-Host "" 
    Write-Host "[3] [CONFIGURE] Active Directory Users Context"
    Write-Host "" 
    Write-Host "[4] [CONFIGURE] Active Directory Computers Context"
    Write-Host "" 
    Write-Host "[5] [INSTALL] Active Directory Integration Apps (scripts)"
    Write-Host "" 
    Write-Host "[6] [UPDATE] This Integration Module from GitHub"
    Write-Host "" 
    Write-Host "[7] [EXIT]"
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
         CHECK_CONNECTIVITY
    } '3' {
         PROMPT_FOR_AD_USER
    } '4' {
         PROMPT_FOR_AD_COMPUTER
    } '5' {
         CREATE_CIMITRA_APPS
    } '6' {
         UPDATE_SCRIPTS
    } '7' {
    exit 0
    }
    }
    pause
 }
 until ($selection -eq '7')