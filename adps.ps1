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
    [string]$Script
    
    [Parameter(Mandatory=$false)]
    [Alias("h")]
    [switch]$Help
)

Import-Module ActiveDirectory 

Clear-Host 

if ($Help) {
    Write-Host "ADPS.ps1" -ForegroundColor Cyan
    Write-Host "Usage: .\adps.ps1 [options]" -ForegroundColor Green
    Write-Host "Options:" -ForegroundColor Cyan
    Write-Host "-Script or -s | Select what script you'd like to run (type -Script -H for a list of options)" -ForegroundColor Cyan
    Write-Host "  -Help    Show this help message" - ForegroundColor -Cyan
    exit

} elseif ($Script) { 

    Write-Host "....Loading initialization script" -ForegroundColor Cyan 
    ".\Supporting Files\Initialize.ps1"

    try { 
        
        $RunScript = $Scripts[$Script]
        & $RunScript

    } catch { 

        Write-Host "$Script does not appear to be a valid parameter for -Scripts, please try again." 
        exit 
    }

}

