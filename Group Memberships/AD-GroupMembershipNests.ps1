<#

TITLE: AD-GroupMembershipNests.ps1 
VERSION: 1.0 
DATE: 8.28.2024
AUTHOR: nateahess 
DESCRIPTION: Script to list enabled users in a specified group or groups and export them to a CSV file. 
             Note - This script will only show nested groups. To view all MemberTypes see AD-GroupMembershipAll.ps1 

VERSION NOTES 

> 1.0 | Initial Script creation and testing 

#> 

#Check for ActiveDirectory Module 
Write-Host "Loading Active Directory Module." 
$admodule = Get-Module -ListAvailable | Where-Object {$_.Name -eq "ActiveDirectory"}
if {$admodule -eq $null} {
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
    #Get the group members, filtering only groups 
    $groupMembers = Get-ADGroupMember -Identity $groupName -Recursive | Where-Object {$_.objectClass -eq 'group'}

    foreach ($member in $groupMembers) {
        #get group info 
        $nestedGroup = Get-ADGroup $member 

        #Add the group to our data array 
        $data += $nestedGroup   

    } 
}


# Select desired properties and export to CSV 
$groupTable = $data | Select-Object Name, ObjectClass, GroupCategory 
$groupTable | Export-Csv -Path "$PSScriptRoot\..\ADAudit\GroupMembers\GroupMemberships-Nested.csv" -NoTypeInformation 



