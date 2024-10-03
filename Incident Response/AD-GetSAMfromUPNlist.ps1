<#

TITLE: AD-GetSAMfromUPNlist.ps1
VERSION: 1.0
AUTHOR: nateahess
DATE: 9.4.2024
DESCRIPTION: Script that takes a list of UPNs (in csv format) and creates a new CSV with the SAM account names inlcuded. 
             I used this in IR scenarios when the SIEM or output from Audit logs only provided a UPN, making it harder to manipulate accounts 
             on a larger scale. 


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