<#

TITLE: AD-GetOUMembersAll.ps1
VERSION 1.0
AUTHOR: nateahess
DATE: 9.3.2024
DESCRIPTION: Script to list all members of an OU

VERSION NOTES 

> 1.0 | Initial script creation and testing

#> 

#Check for ActiveDirectory Module 

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


#Get OU to search through 
Write-Host "Enter an OU to retreive members from (format example - OU=Users,OU=All Users,DC=mydomain,DC=com)"
$searchBase = Read-Host "> " 

#Write-Host "Enabled users? (y/n)"
$enabled = Read-Host "> "

if ($enabled -eq 'y') {

    $enabledChoice = $true

} else { 

    $enabledChoice = $false 

}

Write-Host "Using $searchBase to find list of users. Enabled = $enabledChoice"

#Get users and properties from the OU 
Get-ADUser -Filter {enabled -eq $enabledChoice} -searchbase $searchBase -Properties LastLogonTimeStamp, EmployeeID, EmailAddress, Name, UserPrincipalName, Title, Department, Manager, Description, enabled | 

Select-Object EmployeeID, Name, EmailAddress, UserPrincipalName, Title, Department, manager, Description, Enabled, @{Name="LastLogonTimeStamp"; Expression={[DateTime]}::FromFileTime($_.LastLogonTimeStamp).ToString('g')}} |

Export-Csv -Path "$PSScriptRoot\$filename-$date.csv" -notypeinformation 

Write-Host "....Complete"
Write-Host "....File can be found at $PSScriptRoot\$filename-$date.csv"
Write-Host "...."

pause 






