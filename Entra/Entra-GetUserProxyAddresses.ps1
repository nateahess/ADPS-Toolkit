<#

TITLE: ENTRA-GetUserProxyAddresses.ps1
VERSION: 1.0
AUTHOR: nateahess
DATE: 9.18.2024
DESCRIPTION: Script to get a list of proxyaddresses for a user 
             Helpful for troubleshooting when errors around duplicates show up 


VERSION NOTES: 

1.0 | Initial script creation and testing. 

#> 

#Check for ActiveDirectory Module 
Write-Host "Loading Microsoft.Graph Module." 
$mgmodule = Get-Module -ListAvailable | Where-Object {$_.Name -eq "Microsoft.Graph"}

if ($mgmodule -eq $null) {

    try {

        Install-Module -Name Microsoft.Graph

    } catch {

        $errmsg = $_.ErrorMessage
        Write-Error "Microsoft.Graph module is required for this script."
        Write-Error "Please run PowerShell as Administrator and execute: Install-Module -Name Microsoft.Graph then try again."
        Write-Error $errmsg 
        return 
    }

}


Import-Module Microsoft.Graph

Clear-Host 

#Connect Microsoft Graph Module (Will prompt for sign in)
Connect-MgGraph 

Write-Host "Please enter a user's UPN (user@domain.com" 
$user = Read-Host "> " 

try { 

    Get-MgUser -UserID $user -Property ProxyAddresses | Select-Object -ExpandProperty ProxyAddresses 

} catch { 


    Write-Host "Error occured, could not find $user in Entra. Please try again" 

}

Write-Host "....Complete"
pause 





