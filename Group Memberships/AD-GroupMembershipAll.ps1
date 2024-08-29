<#

TITLE: AD-GroupMembershipAll.ps1 
VERSION: 1.0 
DATE: 8.28.2024
AUTHOR: nateahess 
DESCRIPTION: Script to list all members of a group (enabled users, disabled users, and nested groups included) 

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

#Loop through groups and get user members 
foreach ($groupName in $groupNames) {

    #Get the group members, filtering only users 
    $userMembers = Get-ADGroupMember -Identity $groupName -Recursive | Where-Object {$_.objectClass -eq 'user'}

    foreach ($member in $userMembers) 
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


#Loop through groups and get group members 
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
$userTable = $data | Select-Object Name, ObjectClass, GroupCategory, SamAccountName, GroupName, MemberType, Enabled 
$userTable | Export-Csv -Path "$PSScriptRoot\..\ADAudit\GroupMembers\GroupMemberships-All.csv" -NoTypeInformation 



