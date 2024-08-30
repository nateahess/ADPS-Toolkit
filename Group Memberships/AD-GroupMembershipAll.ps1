<#

TITLE: AD-GroupMembershipAll.ps1 
VERSION: 1.0 
DATE: 8.28.2024
AUTHOR: nateahess 
DESCRIPTION: Script to list all members of a group (enabled users, disabled users, and nested groups included) 

TO USE: Add or change groups in the $groupNames variable that you wish yo get members for. 

VERSION NOTES 

> 1.0 | Initial Script creation and testing 
> 1.1 | Switched to objects for holding member data so the output is cleaner

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

#Change execution policy 
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine 

#Get current date for the filename 
$date = (Get-Date).ToString("yyyMMdd")

#Set group name(s) that you want to retrieve members for 
Write-Host "Please enter the group or groups you would like to retreive members for. (If more than one group, separate by comma)." 
$userInput = Read-Host "> "
$groupNames = $userInput -split ","

#Get iput and set variable for file name 
$filename = Read-Host "Please enter a name for the report (date is added automatically): "

#Initialize an array to hold results 
$data = @()

Write-Host " " 
Write-Host "Looping through the group(s) $groupNames to retreive member information" 
Write-Host "............................"

#Loop through groups and get user members 
foreach ($groupName in $groupNames) {

    try { 

        Write-Host ".....Retrieving data from $groupName" 
        $groupMembers = Get-ADGroupMember -Identity $groupName 

    } cath { 

        Write-Host ".....Retreiving data from $groupName"
        $groupMembers = Get-ADGroupMember -Identity $groupName 

    }

    $groupMembers = Get-ADGroupMember -Identity $groupNames

    #Loop through groups and get user members 
    foreach ($member in $groupMembers) { 

        if ($member.objectClass -eq 'user') {

                #Get information on each user 
                $user = Get-ADUser -Identity $member.SamAccountName -Properties Name, SamAccountName, Enabled, Title, Department, Manager, Description

                #Filter only enabled accounts 
                if ($user.Enabled) { 

                    #Create a custom object with additional properties 
                    $userObject = [PSCustomObject]@{
                        Name           = $user.name 
                        SamAccountName = $user.SamAccountName
                        GroupName      = $Groupname 
                        MemberType     = "User"
                        Enabled        = $user.Enabled 
                        Title          = $user.title
                        Department     = $useer.department 
                        Manager        = $user.manager 
                        Description    = $user.description 
                    }

                    #Add the user to the results table 
                    $data += $userObject 
                } 

        } elseif ($member.objectClass -eq 'group') { 

            $group = Get-ADObject -Identity $member.distinguishedName 

            #Create a custom object with additional properites 
            $groupObject = [PSCustomObject]@{
                Name            = $group.name 
                SamAccountName  = "N/A"
                GroupName       = $GroupName      
                MemberType      = "Group"
                Enabled         = "N/A"
                Title           = "N/A"
                Department      = "N/A"
                Manager         = "N/A"
                Description     = $group.description 
            }

            #Add the user to the results table 
            $data += $groupObject

       } else { 

            Write-Host "$member is not of the object class 'user' or 'group'" 
            Write-Host "Skipping to the next user" 

       }
    }
}
 

#Select desired properites and export to CSV 
$userTable = $data | Select-Object Name, SamAccountName, GroupName, MemberType, Enabled, Title, Department, Manager, Description 
$userTable | Export-Csv -Path "$PSScriptRoot\$filename-$date.csv" -NoTypeInformation 

Write-Host "Complete" 
Write-Host "Report can be found at $PSScriptRoot\$filename-$date.csv" 

pause 
