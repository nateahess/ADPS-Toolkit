<#

TITLE: Entra-DismissRiskyUsers.ps1
VERSION: 1.0
AUTHOR: nateahess
DATE: 12.3.2024
DESCRIPTION: Script to remove users from the Risky Users list in bulk 

VERSION NOTES: 

1.0 | Initial script creation and testing 

#> 

#Connect to Microsoft Graph API 
Connect-MgGraph 

##################### DEFINE FUNCTIONS #######################

#Define function to browse and load a CSV file 

function Browse-FIleName($initialDirectory) {

    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null


    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.Title = "....Select CSV file to process."
    $OpenFileDialog.filter = "CSV (*.csv)| *.csv"
    $rc = $OpenFileDialog.ShowDialog()

    if ($rc -eq [System.Windows.Forms.DialogResult]::OK)  { 

        $filenamepath = $OpenFileDialog.filename
        return $filenamepath

    } else { 

        return $null 
    }

}


##################### MAIN SCRIPT ########################

#Use Brose-FileName function to get the CSV file 
$csvFile = Browse-FIleName("$PSScriptRoot\..")
$users = Import-Csv $csvFile

foreach ($user in $users){ 

    $userid = $user.UserID
    $AccountUpn = $user.username

        Invoke-MgDismissRiskyUser -UserIDs $userid 
        Write-Host "....$AccountUpn dismissed from the Risky Users list"
}


Write-Host "....Complete"
pause 