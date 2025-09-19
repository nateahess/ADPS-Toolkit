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
    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$Domain,

    [Parameter()]
    [ValidateNotNullOrEmpty()]
    [string]$Script,

    [Parameter()]
    [hashtable]$ScriptParameters,

    [switch]$ListAvailable
)

$scriptRoot = $PSScriptRoot
$allScripts = Get-ChildItem -Path $scriptRoot -Recurse -Filter '*.ps1' -File |
    Where-Object { $_.FullName -ne $PSCommandPath }

if ($ListAvailable) {
    Write-Host "Available scripts:" -ForegroundColor Cyan
    foreach ($item in $allScripts | Sort-Object FullName) {
        $relativePath = $item.FullName.Substring($scriptRoot.Length).TrimStart('\\','/')
        Write-Host " - $relativePath"
    }

    if (-not $Script) {
        return
    }
}

if (-not $ListAvailable) {
    if ([string]::IsNullOrWhiteSpace($Domain)) {
        throw "Parameter -Domain is required when launching a script."
    }
}

if ([string]::IsNullOrWhiteSpace($Script)) {
    throw "Specify the script to launch using -Script or use -ListAvailable to see options."
}

$normalizedInput = $Script.Replace('/', [System.IO.Path]::DirectorySeparatorChar)
$resolvedPath = $null

if (Test-Path -LiteralPath $normalizedInput) {
    $resolvedPath = (Resolve-Path -LiteralPath $normalizedInput).Path
} else {
    $candidatePath = Join-Path -Path $scriptRoot -ChildPath $normalizedInput
    if (Test-Path -LiteralPath $candidatePath) {
        $resolvedPath = (Resolve-Path -LiteralPath $candidatePath).Path
    }
}

if (-not $resolvedPath) {
    $matchingScripts = $allScripts | Where-Object {
        $_.Name -eq $Script -or $_.BaseName -eq $Script
    }

    if ($matchingScripts.Count -eq 1) {
        $resolvedPath = $matchingScripts[0].FullName
    } elseif ($matchingScripts.Count -gt 1) {
        $matches = $matchingScripts | ForEach-Object { $_.FullName.Substring($scriptRoot.Length).TrimStart('\\','/') }
        throw "Multiple scripts found matching '$Script'. Be more specific: `n$($matches -join "`n")"
    }
}

if (-not $resolvedPath) {
    throw "Unable to locate a script for input '$Script'. Use -ListAvailable to review valid options."
}

$launchArguments = @()
if (-not $ScriptParameters -or -not $ScriptParameters.ContainsKey('Domain')) {
    if ([string]::IsNullOrWhiteSpace($Domain)) {
        throw "Parameter -Domain is required unless it is passed via -ScriptParameters."
    }
    $launchArguments += '-Domain'
    $launchArguments += $Domain
}

if ($ScriptParameters) {
    foreach ($key in $ScriptParameters.Keys) {
        $launchArguments += "-$key"
        $value = $ScriptParameters[$key]

        if ($null -eq $value) {
            continue
        }

        if ($value -is [System.Collections.IEnumerable] -and -not ($value -is [string])) {
            foreach ($item in $value) {
                $launchArguments += $item
            }
        } else {
            $launchArguments += $value
        }
    }
}

$relativeLaunchPath = $resolvedPath.Substring($scriptRoot.Length).TrimStart('\\','/')
Write-Host "Launching $relativeLaunchPath with arguments: $($launchArguments -join ' ')" -ForegroundColor Green

try {
    & $resolvedPath @launchArguments
} catch {
    throw "Failed to execute '$relativeLaunchPath': $($_.Exception.Message)"
}
