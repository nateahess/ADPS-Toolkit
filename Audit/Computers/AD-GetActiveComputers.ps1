<#
.SYNOPSIS
    Exports all enabled Active Directory computers to a CSV file.

.DESCRIPTION
    This script retrieves all enabled computer accounts from Active Directory and exports
    their details to a CSV file. The exported information includes computer name,
    distinguished name, DNS hostname, enabled status, operating system version,
    SAM account name, and last logon timestamp.

    The output file is automatically named with the current date in the format:
    YYYYMMDD-ActiveComputers.csv

.EXAMPLE
    .\AD-GetActiveComputers.ps1

    Exports all enabled AD computers to a CSV file in the script's directory.

.NOTES
    Requires the ActiveDirectory PowerShell module.
    Must be run with permissions to query Active Directory.

    Author: ADPS-Toolkit
    Version: 1.1
#>

#Requires -Modules ActiveDirectory

try {
    Write-Verbose "Starting Active Directory computer query..."

    # Generate filename with current date
    $currentDate = Get-Date -Format "yyyyMMdd"
    $outputPath = "$PSScriptRoot\$currentDate-ActiveComputers.csv"

    Write-Verbose "Querying Active Directory for enabled computers..."

    # Retrieve enabled computers from Active Directory
    $computers = Get-ADComputer -Filter {Enabled -eq $true} -Properties Name, DistinguishedName, DNSHostname, Enabled, OperatingSystemVersion, SamAccountName, LastLogonTimestamp -ErrorAction Stop

    Write-Verbose "Found $($computers.Count) enabled computer(s)"

    # Process and export computer data
    Write-Verbose "Processing computer data and exporting to CSV..."

    $computers |
        Select-Object Name, DistinguishedName, DNSHostname, Enabled, OperatingSystemVersion, SamAccountName, @{Name="LastLogonTimestamp";Expression={if ($_.LastLogonTimestamp) {[DateTime]::FromFileTime($_.LastLogonTimestamp)} else {$null}}} |
        Export-Csv -Path $outputPath -NoTypeInformation -ErrorAction Stop

    Write-Host "Successfully exported computer data to: $outputPath" -ForegroundColor Green
}
catch [Microsoft.ActiveDirectory.Management.ADServerDownException] {
    Write-Error "Unable to connect to Active Directory server. Please verify the domain controller is reachable."
    exit 1
}
catch [System.UnauthorizedAccessException] {
    Write-Error "Access denied. Please ensure you have sufficient permissions to query Active Directory."
    exit 1
}
catch [System.IO.IOException] {
    Write-Error "Unable to write to output file. Please verify the script directory is writable and not locked."
    exit 1
}
catch {
    Write-Error "An unexpected error occurred: $($_.Exception.Message)"
    Write-Error "Error details: $($_.Exception.GetType().FullName)"
    exit 1
}
