
<#
.SYNOPSIS
    Script to add Active Directory user information to CSV
.DESCRIPTION
    Imports a CSV file of users (by UPN), looks up each user in Active Directory, and adds
    properties including LastLogonDate, Enabled status, and name fields
.NOTES
    Author: Corrected Version
    Date: 2025-11-07
    Requires: ActiveDirectory PowerShell Module
#>


#Get date for filename 
$date = (Get-Date).ToString("yyyyMMdd")

#Define function to browse and load a CSV file 
Function Open-Files($initialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.Title = "....Select CSV file to process."
    $OpenFileDialog.filter = "CSV (*.csv)| *.csv"
    $rc = $OpenFileDialog.ShowDialog() 
    
    if($rc -eq [System.Windows.Forms.DialogResult]::OK) 
    {
        $filenamepath = $OpenFileDialog.filename
        return $filenamepath
    } else {
        return $null
    }
}

try {

    $CSVPath = Open-Files("$PSScriptRoot\")
    
    if (-not $CSVPath) {
        Write-Host "No file selected. Exiting." -ForegroundColor Yellow
        exit
    }
    
    $OutputPath = "$PSScriptRoot\Updated-Users-File-$date.csv"
    $IdentifierColumn = "UserPrincipalName"  # Change to match your CSV column name

    # Import the CSV with error handling
    Write-Host "=== Importing CSV ===" -ForegroundColor Cyan
    $users = Import-Csv -Path $CSVPath -ErrorAction Stop
    
    if (-not $users) {

        throw "CSV file is empty or could not be read"

    }
    
    # Validate identifier column exists
    $csvColumns = $users[0].PSObject.Properties.Name

    if ($IdentifierColumn -notin $csvColumns) {

        Write-Host "`nAvailable columns in CSV:" -ForegroundColor Yellow
        $csvColumns | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }
        throw "Column '$IdentifierColumn' not found in CSV"

    }
    
    Write-Host "Found $($users.Count) users in CSV" -ForegroundColor Green

    Write-Host "Using identifier column: $IdentifierColumn`n" -ForegroundColor Green

    Write-Host "========  Processing CSV =======" -ForegroundColor Cyan 

    # Process each user with progress indicator
    $i = 0

    $results = foreach ($user in $users) {
        $i++
        Write-Progress -Activity "Processing Users" `
                       -Status "Processing $i of $($users.Count)" `
                       -PercentComplete (($i / $users.Count) * 100)
        
        $identifier = $user.$IdentifierColumn
        
        # Validate identifier is not empty
        if ([string]::IsNullOrWhiteSpace($identifier)) {
            Write-Warning "Skipping row $i - empty identifier"
            $user | Add-Member -NotePropertyName "Enabled" -NotePropertyValue "" -Force
            $user | Add-Member -NotePropertyName "LastLogonDate" -NotePropertyValue "" -Force
            $user | Add-Member -NotePropertyName "Surname" -NotePropertyValue "" -Force
            $user | Add-Member -NotePropertyName "GivenName" -NotePropertyValue "" -Force
            $user | Add-Member -NotePropertyName "SamAccountName" -NotePropertyValue "" -Force
            $user | Add-Member -NotePropertyName "Description" -NotePropertyValue "" -Force
            $user | Add-Member -NotePropertyName "Status" -NotePropertyValue "Empty Identifier" -Force
            $user
            continue
        }

        try {

            # Get user from AD - FIXED: Using $identifier variable correctly
            # Using script block syntax for filter (more reliable)
            $adUser = Get-ADUser -Filter {UserPrincipalName -eq $identifier} `
                                 -Properties Enabled, LastLogonDate, Surname, GivenName, SamAccountName, Description `
                                 -ErrorAction Stop

            if (-not $adUser) {
                throw "User not found in Active Directory"
            }

            # Write output
            Write-Host "Processing $identifier" -ForegroundColor Green
            
            # Add properties to the user object - FIXED: Surname spelling
            $user | Add-Member -NotePropertyName "Enabled" -NotePropertyValue $adUser.Enabled -Force
            $user | Add-Member -NotePropertyName "LastLogonDate" -NotePropertyValue $adUser.LastLogonDate -Force
            $user | Add-Member -NotePropertyName "Surname" -NotePropertyValue $adUser.Surname -Force  # FIXED: was SurName
            $user | Add-Member -NotePropertyName "GivenName" -NotePropertyValue $adUser.GivenName -Force
            $user | Add-Member -NotePropertyName "SamAccountName" -NotePropertyValue $adUser.SamAccountName -Force
            $user | Add-Member -NotePropertyName "Description" -NotePropertyValue $adUser.Description -Force
            $user | Add-Member -NotePropertyName "Status" -NotePropertyValue "Success" -Force
            
        } catch {

            # If user not found, add empty values for ALL properties (FIXED: was only adding LastLogonDate)
            $user | Add-Member -NotePropertyName "Enabled" -NotePropertyValue "" -Force
            $user | Add-Member -NotePropertyName "LastLogonDate" -NotePropertyValue "" -Force
            $user | Add-Member -NotePropertyName "Surname" -NotePropertyValue "" -Force
            $user | Add-Member -NotePropertyName "GivenName" -NotePropertyValue "" -Force
            $user | Add-Member -NotePropertyName "SamAccountName" -NotePropertyValue "" -Force
            $user | Add-Member -NotePropertyName "Description" -NotePropertyValue "" -Force
            $user | Add-Member -NotePropertyName "Status" -NotePropertyValue "Not Found: $($_.Exception.Message)" -Force
            Write-Warning "User not found: $identifier - $($_.Exception.Message)"

        }
        
        # Return the updated user object
        $user

    }
    
    # Clear progress bar
    Write-Progress -Activity "Processing Users" -Completed

    # Export the results
    Write-Host "`n========  Exporting Results =======" -ForegroundColor Cyan
    $results | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8

    Write-Host "`nCompleted! Output saved to: $OutputPath" -ForegroundColor Green
    
    # Display summary statistics
    $successCount = ($results | Where-Object { $_.Status -eq "Success" }).Count
    $notFoundCount = ($results | Where-Object { $_.Status -like "Not Found*" }).Count
    $emptyCount = ($results | Where-Object { $_.Status -eq "Empty Identifier" }).Count
    
    Write-Host "`n=== Processing Summary ===" -ForegroundColor Cyan
    Write-Host "Total Rows:          $($users.Count)" -ForegroundColor White
    Write-Host "Successfully Found:  $successCount" -ForegroundColor Green
    Write-Host "Not Found in AD:     $notFoundCount" -ForegroundColor Red
    Write-Host "Empty Identifiers:   $emptyCount" -ForegroundColor Yellow
    
    # Show any failed lookups
    if ($notFoundCount -gt 0) {
        Write-Host "`n=== Users Not Found in AD ===" -ForegroundColor Red
        $results | Where-Object { $_.Status -like "Not Found*" } | 
            Select-Object $IdentifierColumn, Status |
            Format-Table -AutoSize
    }
    
    # Offer to open the file
    Write-Host "`nWould you like to open the output file? y or n?" -ForegroundColor Cyan
    $response = Read-Host
    if ($response -eq 'Y' -or $response -eq 'y') {
        Start-Process $OutputPath
    }

} catch {

    Write-Error "`n========  Script Error ======="
    Write-Error "Error: $_"
    Write-Error $_.Exception.Message

    if ($_.Exception.InnerException) {

        Write-Error "Inner Exception: $($_.Exception.InnerExcecption.Message)"

    }

} finally {

    Write-Host "`nScript execution completed" -ForegroundColor Gray

}
