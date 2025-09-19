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

#Check for ActiveDirectory Module 
Write-Host "Loading Active Directory Module." 
$admodule = Get-Module -ListAvailable | Where-Object {$_.Name -eq "ActiveDirectory"}

if ($admodule -eq $null) {

    try {

        Install-Module -Name ActiveDirectory

    } catch {

        $errmsg = $_.ErrorMessage
        Write-Error "ActiveDirectory module is required for this script."
        Write-Error "Please run PowerShell as Administrator and execute: Install-Module -Name ActiveDirectory then try again."
        Write-Error $errmsg 
        return 
    }

}

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

    .\SupportingFiles\Initialize.ps1 
    $RunScript = "$" + "$Script"

    try { 
        
        $RunScript

    } catch { 

        Write-Host "Not a valid function for -Script or -s. Please try again."
    }

}

