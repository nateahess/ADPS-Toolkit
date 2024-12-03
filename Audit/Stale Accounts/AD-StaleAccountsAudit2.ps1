<#

TITLE: AD-StaleAccountsAudit2.ps1
VERSION: 1.0
AUTHOR: nateahess
DATE: 9/13/2024
DESCRIPTION: Script to find inactive accounts using the Search-ADAccount function 

VERSION NOTES: 

> 1.0 | Initial script creation and testing 

#> 

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

#Get current date for the filename 
$date = (Get-Date).ToString("yyyMMdd")

#Get filename 
Write-Host "Please enter a filename for the export" 
$filename = Read-Host "> "

Write-Host "....Looking for stale accounts"

#Search for inactive accounts 
Search-ADAccount -AccountInactive -UserOnly -TimeSpan 180:00:00:00 | Where-Object $_.Enabled -eq $true } | Select-Object Name, SamAccountName, LastLogonDate, PasswordExpired | Select-Object

Export-Csv -Path "$PSScriptRoot\$filename-$date.csv" -NoTypeInformation 

Write-Host ".......Complete" 

pause 