<#

TITLE: Entra-BulkCloudGroupAdd.ps1
VERSION: 1.0
AUTHOR: nateahess
DATE: 10/21/2025
DESCRIPTION: Script to add a list of users to a cloud group in Entra from a CSV list 

VERSION NOTES: 

1.0 | Initial script creation and testing

#> 

#function to browse and load a CSV file 
function Open-Files($initialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.Title = "....Select CSV file to process."
    $OpenFileDialog.filter = "CSV (*.csv)| *.csv"
    $rc = $OpenFileDialog.ShowDialog() 
    
    if($rc -eq [System.Windows.Forms.DialogResult]::OK) 
    {
        #$OpenFileDialog.filename

        $filenamepath = $OpenFileDialog.filename
        return $filenamepath

    } else {

        return $null

    }

}

#Connect to Microsoft Graph from the proper scopes 
Connect-MgGraph -Scopes "User.ReadWrite.All", "Group.ReadWrite.All"

#Get group ID from a prompt 
Write-Host "Please enter the group ID for the group you want to add users to" -ForegroundColor Green
$groupId = Read-Host "> "

#Use Open-Files function to get the CSV file. 
$usersCSV = Open-Files("$PSScriptRoot\..")
$users = Import-Csv -Path $usersCSV

#Loop through each user in the CSV file and add them to the group 
foreach ($user in $users) { 

    try{ 

        $upn = $user.UPN
        $mgUser = Get-MgUser -UserId $upn

        if ($mgUser) { 

            New-MgGroupMember -GroupId $groupID -DirectoryObjectId $mgUser.Id
            Write-Host "Added: $upn" -ForegroundColor Green

        } else { 

            Write-Host "User not found: $upn" -ForegroundColor Yellow

        }
    } catch { 

        Write-Host "Error adding $upn : $_" -ForegroundColor Red
    }
    
}

Disconnect-Graph
Write-Host "Complete!" -ForegroundColor Green
