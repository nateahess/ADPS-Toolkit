<#

TITLE: AD-PasswordNotRequiredCheck.ps1
VERSION: 1.0
AUTHOR: nateahess
DATE: 9.4.2024
DESCRIPTION: Script to locate accounts that do not require a password 


VERSION NOTES: 

1.0 | Initial script creation and testing. 

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

Write-Host "....Looking for accounts where PasswordNotRequired is set to True"

#Get list of accounts from AD 
Get-ADUser -Filter {PasswordNotRequired -eq $true} -Properties Name, PasswordNotRequired, SamAccountName, Enabled, PasswordExpired, PasswordLastSet, Title, Department, Manager, Description  | 

Select-Object Name, PasswordNotRequired, SamAccountName, Enabled, PasswordExpired, PasswordLastSet, Title, Department, Manager, Description 

Export-Csv -Path "$PSScriptRoot\$filename-$date.csv" -NoTypeInformation 

Write-Host "....Complete"
Write-Host "....CSV can be found at $PSScriptRoot\$filename-$date.csv" 

pause 

