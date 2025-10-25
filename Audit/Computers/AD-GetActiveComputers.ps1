
Import-Module ActiveDirectory

$currentDate = Get-Date -Format "yyyyMMdd"
Get-ADComputer -Filter {Enabled -eq $true} -Properties Name, DistinguishedName, DNSHostname, Enabled, OperatingSystemVersion, SamAccountName, LastLogonTimestamp |
Select-Object Name, DistinguishedName, DNSHostname, Enabled, OperatingSystemVersion, SamAccountName, @{Name="LastLogonTimestamp";Expression={if ($_.LastLogonTimestamp) {[DateTime]::FromFileTime($_.LastLogonTimestamp)} else {$null}}} |
Export-Csv -Path "$PSScriptRoot\$currentDate-ActiveComputers.csv" -NoTypeInformation
