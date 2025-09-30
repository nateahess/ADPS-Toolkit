
Import-Module ActiveDirectory

$currentDate = Get-Date -Format "yyymmdd"
Get-ADComputer -Filter {Enabled -eq $true} -Properties Name, DistinguishedName, DNSHostname, Enabled, OperatingSystemVersion, SamAccountName, LastLogonTimestamp |
Select-Object Name, DistinguishedName, DNSHostname, Enabled, OperatingSystemVersion, SamAccountName, @{Name="LastLogonTimestamp";Expression={[DateTime]::FromFileTime($_.LastLogonTimestamp)}} |
Export-Csv -Path "$PSScriptRoot\$domain-$currentDate-ActiveComputers.csv" -NoTypeInformation
