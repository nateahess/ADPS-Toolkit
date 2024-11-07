<#

TITLE: AD-CheckUnresolvedSID
VERSION: 1.0
AUTHOR: nateahess
DATE: 11.7.2024
DESCRIPTION: Script to find info on an unresolved SID 


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

Write-Host "What SID do you need to resolve?: "
$sid = Read-Host "> "

try { 


    $object = Get-ADObject -Identity $sid 
    Write-Output "SID: $sid"
    Write-Output "Object Name: $($object.Name)"
    Write-Output "Object Type: $(object.ObjectClass)"

} catch { 


    Write-Output "SID $sid could not be resolved." 


}


pause 