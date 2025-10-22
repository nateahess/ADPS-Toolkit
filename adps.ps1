<#

TITLE: ADPS.ps1
VERSION: 1.1
DATE: 10/22/2025
AUTHOR: nateahess
DESCRIPTION: Main script to launch any of the functions of other ADPS scripts

Usage: .\adps.ps1 -Script <ScriptName>
Examples:
  .\adps.ps1 -Script AuditGroupMembershipUsers
  .\adps.ps1 -s BulkDisableAccounts
  .\adps.ps1 -ShowScripts
Help: .\adps.ps1 -Help

VERSION NOTES

> 1.0 | Initial Script creation and testing
> 1.1 | Code review fixes: improved validation, error handling, and user experience

#> 

[CmdletBinding()]
param(

    [Parameter(Mandatory=$false)]
    [Alias("s")]
    [string]$Script,
    
    [Parameter(Mandatory=$false)]
    [Alias("h")]
    [switch]$Help,

    [Parameter(Mandatory=$false)]
    [Alias("ss")]
    [switch]$ShowScripts

)

# Function to display ASCII banner
function Show-Banner {
    Write-Host "

    ___    ____  ____  _____             ___
   /   |  / __ \/ __ \/ ___/  ____  ____<  /
  / /| | / / / / /_/ /\__ \  / __ \/ ___/ /
 / ___ |/ /_/ / ____/___/ / / /_/ (__  ) /
/_/  |_/_____/_/    /____(_) .___/____/_/
                          /_/

    " -ForegroundColor Green
}

#Hashtable for scripts 
$Scripts = @{

"AuditGroupMembershipUsers" = "Audit\Group Memberships\AD-GetGroupMembershipUsers.ps1"
"AuditGroupMembershipAll" = "Audit\Group Memberships\AD-GetGroupMembershipAll.ps1"
"AuditGroupMembershipNests" = "Audit\Group Memberships\AD-GroupMembershipNests.ps1"
"AuditOUMembershipAll" = "Audit\OU Memberships\AD-GetOUMembersAll.ps1"
"AuditExpiredPasswords" =  "Audit\Passwords\AD-ExpiredPasswordsAudit.ps1"
"AuditPasswordNotRequired" = "Audit\Passwords\AD-PasswordNotRequiredAudit.ps1"
"AuditStaleAccounts" = "Audit\Stale Accounts\AD-StaleAccountsAudit2.ps1"
"Audit365Licenses" = "Entra\ENTRA-GetUserLicenses.ps1"
"Audit365ProxyAddress" = "Entra\Entra-GetUserProxyAddresses.ps1"
"EntraBulkCloudGroupAdd" = "Entra\Entra-BulkCloudGroupAdd.ps1"
"PasswordChangeLogs" = "Forensics\AD-PasswordChange-Initiated-Audit.ps1"
"BulkDisableAccounts" = "Incident Response\AD-BulkDisable.ps1"
"BulkPasswordReset" = "Incident Response\AD-BulkPasswordReset.ps1"
"GetSAMfromUPN" = "Incident Response\AD-GetSAMfromUPNlist.ps1"
"CheckUnresolvedSID" = "Miscellaneous\AD-CheckUnresolvedSID.ps1"
"GenerateRandomPassword" = "Miscellaneous\PasswordGenerator.ps1"


}

if ($Help) {
    Show-Banner
    Write-Host "" 
    Write-Host "ADPS.ps1" -ForegroundColor Cyan
    Write-Host "Usage: .\adps.ps1 -Script <ScriptName>" -ForegroundColor Green
    Write-Host "" 
    Write-Host "Options:" -ForegroundColor Cyan
    Write-Host "  -Script or -s      | Select what script you'd like to run" -ForegroundColor Cyan
    Write-Host "  -ShowScripts or -ss| Display all available scripts" -ForegroundColor Cyan
    Write-Host "  -Help or -h        | Show this help message" -ForegroundColor Cyan
    Write-Host ""
    exit 0

} elseif ($ShowScripts) {
    Show-Banner
    Write-Host "Here is a list of available scripts: " 
    Write-Host ""
    Write-Host "Auditing" -ForegroundColor Cyan
    Write-Host "..... AuditGroupMembershipAll   | Looks for all objects that are members of a group" -ForegroundColor Cyan
    Write-Host "..... AuditGroupMembershipUsers | Looks for all users in a group" -ForegroundColor Cyan
    Write-Host "..... AuditGroupMembershipNests | Looks for nested groups within a single group" -ForegroundColor Cyan
    Write-Host "..... AuditOUMembershipAll      | Looks for all objects that are members of an OU" -ForegroundColor Cyan
    Write-Host "..... AuditExpiredPasswords     | Lists accounts with expired passwords" -ForegroundColor Cyan
    Write-Host "..... AuditPasswordNotRequired  | Finds accounts that do not require a password" -ForegroundColor Cyan
    Write-Host "..... AuditStaleAccounts        | Reports on inactive AD accounts" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Entra" -ForegroundColor Cyan
    Write-Host "..... Audit365Licenses          | Exports assigned Microsoft 365 licenses" -ForegroundColor Cyan
    Write-Host "..... Audit365ProxyAddress      | Collects Entra ID proxy addresses" -ForegroundColor Cyan
    Write-Host "..... EntraBulkCloudGroupAdd    | Bulk adds users to Entra cloud groups" -ForegroundColor Cyan
    Write-Host "" 
    Write-Host "Forensics" -ForegroundColor Cyan
    Write-Host "..... PasswordChangeLogs        | Audits password change events" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Incident Response" -ForegroundColor Cyan
    Write-Host "..... BulkDisableAccounts       | Disables a list of accounts" -ForegroundColor Cyan
    Write-Host "..... BulkPasswordReset         | Performs bulk password resets" -ForegroundColor Cyan
    Write-Host "..... GetSAMfromUPN             | Converts UPN list to SAMAccountNames" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Miscellaneous" -ForegroundColor Cyan
    Write-Host "..... CheckUnresolvedSID        | Looks for unresolved SIDs in ACLs" -ForegroundColor Cyan
    Write-Host "..... GenerateRandomPassword    | Creates a strong random password" -ForegroundColor Cyan
    Write-Host ""

} elseif ($Script) {
    # Check if the script key exists in the hashtable
    if ($Scripts.ContainsKey($Script)) {
        $RunScript = $Scripts[$Script]

        # Verify the script file exists before executing
        if (Test-Path $RunScript) {
            try {
                & $RunScript
            } catch {
                Write-Host "Error executing script: $($_.Exception.Message)" -ForegroundColor Red
                exit 1
            }
        } else {
            Write-Host "Script file not found: $RunScript" -ForegroundColor Red
            Write-Host "Please verify the script exists in the expected location." -ForegroundColor Yellow
            exit 1
        }
    } else {
        Write-Host "'$Script' is not a valid script name." -ForegroundColor Red
        Write-Host "Use -ShowScripts to see all available scripts." -ForegroundColor Yellow
        exit 1
    }

} else {
    # No parameters provided - show help
    Show-Banner
    Write-Host ""
    Write-Host "No parameters provided. Please specify an option." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Usage: .\adps.ps1 -Script <ScriptName>" -ForegroundColor Green
    Write-Host ""
    Write-Host "Quick Options:" -ForegroundColor Cyan
    Write-Host "  -Help        | Display help information" -ForegroundColor Cyan
    Write-Host "  -ShowScripts | List all available scripts" -ForegroundColor Cyan
    Write-Host ""
    exit 1
}
