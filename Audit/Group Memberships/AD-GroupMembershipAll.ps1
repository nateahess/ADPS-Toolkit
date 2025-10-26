<#
.SYNOPSIS
    Lists all members of one or more Active Directory groups including nested groups.

.DESCRIPTION
    Script to list all members of a group (enabled users and nested groups included).
    Recursively expands nested group memberships and exports results to CSV.

.PARAMETER GroupNames
    Array of group names to retrieve members for. If not specified, prompts interactively.

.PARAMETER FileName
    Base name for the report file. Date is appended automatically. If not specified, prompts interactively.

.PARAMETER Interactive
    Forces interactive mode even if parameters are provided.

.EXAMPLE
    .\AD-GroupMembershipAll.ps1
    Runs in interactive mode, prompting for group names and filename.

.EXAMPLE
    .\AD-GroupMembershipAll.ps1 -GroupNames "Domain Admins","Enterprise Admins" -FileName "AdminReport"
    Generates a report for the specified groups with the given filename.

.NOTES
    TITLE: AD-GroupMembershipAll.ps1
    VERSION: 1.2
    DATE: 10.26.2025
    AUTHOR: nateahess

    VERSION NOTES
    > 1.0 | Initial Script creation and testing
    > 1.1 | Switched to objects for holding member data so the output is cleaner
    > 1.2 | Bug fixes: corrected logic errors, improved error handling, added recursive group expansion,
            performance improvements, parameter support, and comprehensive help documentation

#>

[CmdletBinding()]
param(
    [Parameter(ValueFromPipeline = $true)]
    [string[]]$GroupNames,

    [Parameter()]
    [string]$FileName,

    [Parameter()]
    [switch]$Interactive
)

# Check for ActiveDirectory Module
Write-Host "Loading Active Directory Module."
$admodule = Get-Module -ListAvailable | Where-Object {$_.Name -eq "ActiveDirectory"}

if ($null -eq $admodule) {

    try {

        Install-Module -Name ActiveDirectory

    } catch {

        $errmsg = $_.Exception.Message
        Write-Error "ActiveDirectory module is required for this script."
        Write-Error "Please run PowerShell as Administrator and execute: Install-Module -Name ActiveDirectory then try again."
        Write-Error $errmsg
        return
    }

}

Import-Module ActiveDirectory

# Only clear host in interactive mode
if ($Interactive -or -not $PSBoundParameters.ContainsKey('GroupNames')) {
    Clear-Host
}

# Get current date for the filename
$date = (Get-Date).ToString("yyyyMMdd")

# Get group names if not provided as parameter
if (-not $GroupNames -or $Interactive) {
    Write-Host "Please enter the group or groups you would like to retrieve members for. (If more than one group, separate by comma)."
    $userInput = Read-Host "> "

    # Validate input
    if ([string]::IsNullOrWhiteSpace($userInput)) {
        Write-Error "No group names provided. Exiting."
        return
    }

    # Split and trim whitespace from group names
    $GroupNames = $userInput -split "," | ForEach-Object { $_.Trim() } | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
}

# Get input and set variable for file name
if (-not $FileName -or $Interactive) {
    $FileName = Read-Host "Please enter a name for the report (date is added automatically)"

    # Validate filename
    if ([string]::IsNullOrWhiteSpace($FileName)) {
        Write-Error "No filename provided. Exiting."
        return
    }
}

# Initialize an ArrayList to hold results (better performance than array concatenation)
$data = New-Object System.Collections.ArrayList

Write-Host " "
Write-Host "Looping through the group(s) $($GroupNames -join ', ') to retrieve member information"
Write-Host "............................"

# Function to recursively get group members
function Get-GroupMembersRecursive {
    param(
        [string]$GroupName,
        [System.Collections.ArrayList]$DataCollection
    )

    try {
        Write-Host ".....Retrieving data from $GroupName"
        $groupMembers = Get-ADGroupMember -Identity $GroupName -ErrorAction Stop

    } catch {
        Write-Warning "Failed to retrieve members from group '$GroupName': $($_.Exception.Message)"
        return
    }

    # Loop through group members
    foreach ($member in $groupMembers) {

        if ($member.objectClass -eq 'user') {

            try {
                # Get information on each user
                $user = Get-ADUser -Identity $member.SamAccountName -Properties Name, SamAccountName, Enabled, PasswordExpired, PasswordLastSet, Title, Department, Manager, Description -ErrorAction Stop

                # Filter only enabled accounts
                if ($user.Enabled) {

                    # Create a custom object with additional properties
                    $userObject = [PSCustomObject]@{
                        Name           = $user.Name
                        SamAccountName = $user.SamAccountName
                        GroupName      = $GroupName
                        MemberType     = "User"
                        Enabled        = $user.Enabled
                        Title          = $user.Title
                        Department     = $user.Department
                        Manager        = $user.Manager
                        Description    = $user.Description
                        Expired        = $user.PasswordExpired
                        LastSet        = $user.PasswordLastSet
                    }

                    # Add the user to the results table
                    [void]$DataCollection.Add($userObject)
                }
            } catch {
                Write-Warning "Failed to retrieve user information for '$($member.SamAccountName)': $($_.Exception.Message)"
            }

        } elseif ($member.objectClass -eq 'group') {

            try {
                $group = Get-ADGroup -Identity $member.DistinguishedName -Properties Description -ErrorAction Stop

                # Create a custom object with additional properties
                $groupObject = [PSCustomObject]@{
                    Name            = $group.Name
                    SamAccountName  = "N/A"
                    GroupName       = $GroupName
                    MemberType      = "Group"
                    Enabled         = "N/A"
                    Title           = "N/A"
                    Department      = "N/A"
                    Manager         = "N/A"
                    Description     = $group.Description
                    Expired         = "N/A"
                    LastSet         = "N/A"
                }

                # Add the group to the results table
                [void]$DataCollection.Add($groupObject)

                # Recursively process nested group
                Write-Host ".....Processing nested group: $($group.Name)"
                Get-GroupMembersRecursive -GroupName $group.Name -DataCollection $DataCollection

            } catch {
                Write-Warning "Failed to retrieve group information for '$($member.DistinguishedName)': $($_.Exception.Message)"
            }

        } else {

            Write-Host "$($member.Name) is not of the object class 'user' or 'group'"
            Write-Host "Skipping to the next member"

        }
    }
}

# Loop through groups and get user members
foreach ($GroupName in $GroupNames) {
    Get-GroupMembersRecursive -GroupName $GroupName -DataCollection $data
}

# Select desired properties and export to CSV
$userTable = $data | Select-Object Name, SamAccountName, GroupName, MemberType, Enabled, Expired, LastSet, Title, Department, Manager, Description
$userTable | Export-Csv -Path "$PSScriptRoot\$FileName-$date.csv" -NoTypeInformation

Write-Host "Complete"
Write-Host "Report can be found at $PSScriptRoot\$FileName-$date.csv"

# Only pause in interactive mode
if ($Interactive -or -not $PSBoundParameters.ContainsKey('GroupNames')) {
    pause
}
