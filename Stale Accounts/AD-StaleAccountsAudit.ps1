<#

TITLE: AD-StaleAccountsAudit.ps1
VERSION: 1.1
AUTHOR: nateahess
DATE: 9.4.2024
DESCRIPTION: Script to locate stale accounts (Based on LastLogonTimeStamp) 


VERSION NOTES: 

1.0 | Initial script creation and testing. Script currently pulls all users, not just inactive accounts. 
      Working on formatting for LastLogonTimestamp prior to any further filtering. 

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

Write-Host "....Looking for stale accounts"

#Look for enabled users only 
$users = Get-ADUser -Filter {enabled -eq $true} -Properties EmployeeID, SamAccountName, UserPrincipalName, EmailAddress, DistinguishedName, WhenCreated, LastLogonTimestamp, Description, PasswordLastSet

#Format the timestamp 
$usersWithFormattedTimestamp = foreach ($user in $users) { 

        $usersWithFormattedTimestamp = if ($user.LastLogonTimestamp) { 

                [DateTime]::FromFileTIime($user.LastLogonTimestamp).ToString("yyy-MM-dd HH:mm:ss")

        } else { 

                Write-Host ".....LastLogonTimestamp for $user is blank. Record will still be added to the report..."

        }


        [PSCustomObject]@{

            Name = $user.Name 
            EmployeeID = $user.EmployeeID
            SamAccountName = $user.SamAccountName
            UserPrincipalName = $user.UserPrincipalName
            EmailAddress = $user.EmailAddress
            DistinguishedName = $user.DistinguishedName
            WhenCreated = $user.WhenCreated
            PasswordLastSet = $user.PasswordLastSet
            LastLogonTimestamp = $user.LastLogonTimestamp
            Description = $user.Description

        }

}

#Export objects to CSV 
$usersWithFormattedTimestamp | Export-Csv -Path "$PSScriptRoot\$filename-$date.csv" -NoTypeInformation

Write-Host "......."
Write-Host " "
Write-Host "Complete. Results can be found at $PSScriptRoot\$filename-$date.csv" 

pause 

