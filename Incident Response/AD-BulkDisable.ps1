<#

TITLE: AD-BulkDisable.ps1
VERSION: 1.0
AUTHOR: nateahess
DATE: 9.4.2024
DESCRIPTION: Script to disable accounts in bulk - input from a CSV using SamAccountName 
             (Typiaclly used for IR, not for Identity Lifecycle processes) 


VERSION NOTES: 

1.0 | Initial script creation and testing. 

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

############### DEFINE FUNCTIONS #################

#Define function to browse and load a CSV file 
Function Browse-FileName($initialDirectory) { 

    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDiaglog.Title "....Select CSV file to process."
    $OpenFileDialog.filter = "CSV (*.csv)| *.csv"
    $rc = $OpenFileDialog.ShowDialog()

    if($rc -eq [System.Windows.Forms.DialogResult]::OK){
       
        $filenamepath = $OpenFileDialog.filename 
        return $filenamepath 

    } else { 

        return $null 
    }

}

############### MAIN SCRIPT #################

#Use Browse-Filename Function to get the CSV file 
$usersCSV = Browse-Filename("$PSScriptRoot\..")
$users = Import-Csv $usersCSV 

foreach ($user in $users) { 

    $SamAccountName = $user.SamAccountName

    try { 

        $adUser = Get-ADUser -Identity $SamAccountName 

        try { 

            Disable-ADAccount -Identity $adUser 
            Write-Host "....$adUser Disabled" -ForegroundColor Green 

        } catch { 

            Write-Host "....Error: Could not disable user $adUser" -ForegroundColor Red 

        }

    }

}

Write-Host ".....Complete" 

pause 
