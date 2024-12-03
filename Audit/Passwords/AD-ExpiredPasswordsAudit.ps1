<#

TITLE: AD-ExpiredPasswordsAudit.ps1
VERSION: 1.0
AUTHOR: nateahess
DATE: 9/13/2024
DESCRIPTION: Script to find users with expired passwords 

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

Write-Host ".....Searching for users with expired passwords" 

#Get Users with expired passwords 
$users = Get-ADUser -Filter {Enabled -eq $true} -Properties Name, SamAccountName, Enabled, PasswordExpired, Description
$users | Where {$_.PasswordExpired -eq "True"} | 

#Select properties 
Select-Object Name, SamAccountName, Enabled, PasswordExpired, Description | 

#Export to CSV 
Export-Csv -Path "$PSScriptRoot\Users_With_Expired_Passwords_$date.csv" -NoTypeInformation 

Write-Host ".....Complete"

Pause 