<#

TITLE: AD-GroupMembershipUsers.ps1 
VERSION: 1.0 
DATE: 8.28.2024
AUTHOR: nateahess 
DESCRIPTION: Script to list enabled users in a specified group or groups and export them to a CSV file. 
             Note - This script will not show nested groups. To view all MemberTypes see AD-GroupMembershipAll.ps1 


TO USE: Add or change groups in the $groupNames variable that you wish yo get members for. 

VERSION NOTES 

> 1.0 | Initial Script creation and testing 

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

#Set group name(s) that you want to retrieve members for 
$groupNames = @("Domain Admins")

#Initialize an array to hold results 
$data = @()

#Loop through groups and get members 
foreach ($groupName in $groupNames) {
    #Get the group members, filtering only users users 
    $groupMembers = Get-ADGroupMember -Identity $groupName -Recursive | Where-Object {$_.objectClass -eq 'user'}

    foreach ($member in $groupMembers) 
        #Get detailed information about each member 
        $user = Get-ADUser -Identity $member.SamAccountName -Properties Enabled 

        #Filter only enabled accounts
        if ($user.Enabled) {
            #Add additional properties for exporting 
            $user | Add-Member -Force -MemberType NoteProperty -Name GroupName -Value $groupnName 
            $user | Add-Member -Force -MemberType NoteProperty -Name MemberType -Value "User" 

            #Add the user to the results table 
            $data += $user 
        }
    }
}


# Select desired properties and export to CSV 
$userTable = $data | Select-Object Name, SamAccountName, GroupName, MemberType, Enabled 
$userTable | Export-Csv -Path "$PSScriptRoot\..\GroupMemberships-Users.csv" -NoTypeInformation 






