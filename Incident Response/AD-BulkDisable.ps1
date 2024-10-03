<#

TITLE: AD-BulkDisable.ps1
VERSION: 1.0
AUTHOR: nateahess
DATE: 9.4.2024
DESCRIPTION: Script to disable accounts in bulk - input from a CSV using SamAccountName 
             (Typiaclly used for IR, not for Identity Lifecycle processes) 


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

