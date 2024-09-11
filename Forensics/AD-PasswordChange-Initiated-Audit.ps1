<#

TITLE: Ad-PasswordChange-Initiated-Audit.ps1
VERSION: 1.0
AUTHOR: Nathan Hess
DATE: 9/11/2024
DESCRIPTION: Script to check which admin changed a user's password recently. 

VERSION NOTES 

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


#Get domain controller to check 
Write-Host "Enter hostname to get event logs from"
$computer = Read-Host "> "

$eventIDs = 4723, 4724

Get-EventLog -LogName Security -ComputerName $computer -InstanceID $eventIDs -Message "*user*" | Select-Object TimeGenerated, Message | Format-List

Write-Host "Complete"
Pause 