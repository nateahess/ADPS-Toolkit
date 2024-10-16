
<#

TITLE: AD-BulkPasswordReset.ps1
VERSION: 1.0
AUTHOR: nateahess
DATE: 9.4.2024
DESCRIPTION: Script to reset passwords in bulk - input from a CSV using SamAccountName 


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
        #$OpenFileDialog.filename

        $filenamepath = $OpenFileDialog.filename 
        return $filenamepath 

    } else { 

        return $null 
    }

}


#Function to generate a random password 
function Generate-Password { 

    $length = 10 
    $chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%&*'
    $password = -join ((1..length)) | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)]}

    return $password 

}

############### MAIN SCRIPT #################

#Use Browse-Filename Function to get the CSV file 
$usersCSV = Browse-Filename("$PSScriptRoot\..")
$users = Import-Csv $usersCSV 


if ($users[0].PsObject.Properties.Name[0] -eq "SamAccountName") { 

    Write-Host "....SamAccountName detected as the first column in the CSV" 
    foreach($user in $users) { 

        $SamAccountName = $user.SamAccountName
        $newPassword = Generate-Password 

        try { 

            #Set a new password for the user 
            Set-ADAccountPassword -Identity $SamAccountName -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $newPassword -Force)

            #Force password reset on next login 
            Set-ADUser -Identity $SamAccountName -ChangePasswordAtLogon $true 

            Write-Host "....Password for user $SamAccountName has been changed to: $newPassword" -ForegroundColor Green 

        } catch { 

            Write-Host "....Password for user $SamAccountName could not be changed." -ForegroundColor Red 

        }

    }


} elseif ($users[0].PsObject.Properties.Name[0] -eq "AccountUpn") { 

    Write-Host "....AccountUpn detected as the first column in the CSV" 

    #Iterate through list of users and change passwords 
    foreach ($user in $users) { 

        $AccountUpn = $user.AccountUpn
        $newPassword = Generate-Password 

        try { 

            #Set a new password for the user 
            Set-ADAccountPassword -Identity $AccountUpn -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $newPassword -Force) 

            #Force password reset on next logon 
            Set-ADUser -Identity $AccountUpn -ChangePasswordAtLogon $true 

            Write-Host "....Password for user $SamAccountName has been changed to: $newPassword" -ForegroundColor Green 


        } catch { 

            Write-Host "....Password for user $SamAccountName could not be changed." -ForegroundColor Red 

        }

    }

} else { 

    Write-Host "....CSV is not in the correct format, please verify that the first colun header is AccountUpn or SamAccountName" -ForegroundColor Red 

}


Write-Host ".....Complete" 

pause 
