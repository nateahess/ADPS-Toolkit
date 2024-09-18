<#

TITLE: ENTRA-GetUserLicenses.ps1
VERSION: 1.0
AUTHOR: nateahess
DATE: 9.18.2024
DESCRIPTION: Script to get a list of licenses for a user 


VERSION NOTES: 

1.0 | Initial script creation and testing. 

#> 

#Check for ActiveDirectory Module 
Write-Host "Loading Microsoft.Graph Module." 
$mgmodule = Get-Module -ListAvailable | Where-Object {$_.Name -eq "Microsoft.Graph"}

if ($mgmodule -eq $null) {

    try {

        Install-Module -Name Microsoft.Graph

    } catch {

        $errmsg = $_.ErrorMessage
        Write-Error "Microsoft.Graph module is required for this script."
        Write-Error "Please run PowerShell as Administrator and execute: Install-Module -Name Microsoft.Graph then try again."
        Write-Error $errmsg 
        return 
    }

}


Import-Module Microsoft.Graph

Clear-Host 

#Connect Microsoft Graph Module (Will prompt for sign in)
Connect-MgGraph 

#Get current date for the filename 
$date = (Get-Date).ToString("yyyMMdd")

#Get filename 
Write-Host "Please enter a filename for the export" 
$filename = Read-Host "> "


Write-Host ".....Getting list of users and assigned licenses"


#Get users and license information 
Get-MgUser -Filter 'accountEnabled eq true' -All -Property AccountEnabled, DisplayName, Mail, UserPrincipalName, Assignedlicenses |

select AccountEnabled, DisplayName, Mail, UserPrincipalName, Assignedlicenses | Export-Csv -Path "$PSScriptRoot\$filename-$date.csv" -NoTypeInformation 

Write-Host ".....Complete"
Write-Host ".....File can be found at '$PSScriptRoot\$filename-$date.csv'"

pause 
