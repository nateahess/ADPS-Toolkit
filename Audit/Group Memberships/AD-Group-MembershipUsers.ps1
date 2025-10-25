<#

TITLE: AD-GroupMembershipUsers.ps1 
VERSION: 1.0 
DATE: 8.28.2024
AUTHOR: nateahess 
DESCRIPTION: Script to list enabled users in a specified group or groups and export them to a CSV file. 
             Note - This script will not show nested groups. To view all MemberTypes see AD-GroupMembershipAll.ps1 

VERSION NOTES 

> 1.0 | Initial Script creation and testing 
> 1.1 | Copied updates from AD-GroupMembershipAll.ps1

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

#Get current date for the filename 
$date = (Get-Date).ToString("yyyyMMdd")

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

    } catch {

        Write-Host ".....Retreiving data from $groupName"
        $groupMembers = Get-ADGroupMember -Identity $groupName

    }

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
                        GroupName      = $groupName
                        MemberType     = "User"
                        Enabled        = $user.Enabled
                        Title          = $user.title
                        Department     = $user.department
                        Manager        = $user.manager
                        Description    = $user.description
                    }

                    #Add the user to the results table 
                    $data += $userObject 
                } 

        }  else { 

            Write-Host "$member is not of the object class 'user'" 
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





