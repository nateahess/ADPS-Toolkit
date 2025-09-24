<#

TITLE: ADPS.ps1
VERSION: 1.0 
DATE: 9/19/2025
AUTHOR: nateahess 
DESCRIPTION: Main script to launch any of the functions of other ADPS scripts 

Usage: .\adps.ps1 -Domain corp.example -Script "Audit/Group Memberships/AD-Group-MembershipUsers.ps1" -ScriptParameters @{GroupNames='Tier1'}
Help: .\adps.ps1 -h or -Help

VERSION NOTES 

> 1.0 | Initial Script creation and testing

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

#Hashtable for scripts 
$Scripts = @{

"AuditGroupMembershipUsers" = "Audit\Group Memberships\AD-GetGroupMembershipUsers.ps1"
"AuditGroupMembershipAll" = "Audit\Group Memberships\AD-GetGroupMembershipAll.ps1"
"AuditGroupMembershipNests" = "Audit\Group Memberships\AD-GroupMembershipNests.ps1"
"AuditOUMembershipAll" = "Audit\OU Memberships\AD-GetOUMembersAll.ps1"
"AuditExpiredPasswords" =  "Audit\Passwords\AD-ExpiredPasswordsAudit.ps1"
"AuditPasswordNotRequired" = "Audit\Passwords\AD-PasswordNotRequiredAudit.ps1"
"AuditStaleAccounts" = "Audit\Stale Accounts\AD-StaleAccountsAudit"
"Audit365Licenses" = "Entra\ENTRA-GetUserLicenses.ps1"
"Audit365ProxyAddress" = "Entra\Entra-GetUserProxyAddresses.ps1"
"PasswordChangeLogs" = "Forensics\AD-PasswordChange-Initiated-Audit.ps1"
"BulkDisableAccounts" = "Incident Response\AD-BulkDisable.ps1"
"BulkPasswordReset" = "Incident Response\AD-BulkPasswordReset.ps1"
"GetSAMfromUPN" = "Incident Response\AD-GetSAMfromUPNlist.ps1"
"CheckUnresolvedSID" = "Miscellaneous\AD-CheckUnresolvedSID.ps1"
"GenerateRandomPassword" = "Miscellaneous\PasswordGenerator.ps1"



}

if ($Help) {
    Write-Host " 
    
    ___    ____  ____  _____             ___
   /   |  / __ \/ __ \/ ___/  ____  ____<  /
  / /| | / / / / /_/ /\__ \  / __ \/ ___/ / 
 / ___ |/ /_/ / ____/___/ / / /_/ (__  ) /  
/_/  |_/_____/_/    /____(_) .___/____/_/   
                          /_/               
    
    " -ForegroundColor Green

    Write-Host "" 
    Write-Host "ADPS.ps1" -ForegroundColor Cyan
    Write-Host "Usage: .\adps.ps1 -Script <ScriptName>" -ForegroundColor Green
    Write-Host "" 
    Write-Host "Options:" -ForegroundColor Cyan
    Write-Host "-Script or -s | Select what script you'd like to run (type -Script -H for a list of options)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "For a list of available scripts, type -ShowScripts" 
    Write-Host "  -Help    Show this help message" - ForegroundColor -Cyan
    exit

} elseif ($ShowScripts) { 

    Write-Host " 
    
    ___    ____  ____  _____             ___
   /   |  / __ \/ __ \/ ___/  ____  ____<  /
  / /| | / / / / /_/ /\__ \  / __ \/ ___/ / 
 / ___ |/ /_/ / ____/___/ / / /_/ (__  ) /  
/_/  |_/_____/_/    /____(_) .___/____/_/   
                          /_/               
    
    " -ForegroundColor Green

    Write-Host "Here is a list of available scripts: " 
    Write-Host ""
    Write-Host "Auditing" -ForegroundColor Cyan
    Write-Host "..... AuditGroupMembershipAll   | Looks for all objects that are members of a group" -ForegroundColor Cyan
    Write-Host "..... AuditGroupMembershipUsers | Looks for all users in a group" -ForegroundColor Cyan
    Write-Host "..... AuditGroupMembershipNests | Looks for nested groups within a single group" -ForegroundColor Cyan
    Write-Host "..... AuditOUMembershipAll      | Looks for all objects that are members of an OU" -ForegroundColor Cyan
    Write-Host ""

} elseif ($Script) { 

    try { 

        $RunScript = $Scripts[$Script]
        & $RunScript  

    } catch { 

        Write-Host "$Script does not appear to be a valid parameter for -Scripts, please try again." -ForegroundColor Red
        exit 
    }

} else { 

    Write-Host "Invalid parameter, please try again" -ForegroundColor Red 

}
