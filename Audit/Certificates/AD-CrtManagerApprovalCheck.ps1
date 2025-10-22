
<#

Title: AD-CrtManagerApprovalCheck.ps1
Description: Script to check if a certificate template has manager approval enabled
Author: Nathan Hess
Last Updated: 10/22/2025

Usage:

    Example: .\AD-CrtManagerApprovalCheck.ps1 -TemplateName "TemplateName" -Domain "domain.org"

Parameters:
    -TemplateName: The name of the certificate template to check (case-sensitive)
    -Domain: The Active Directory domain to query (optional, uses current domain if not specified)

#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$TemplateName,

    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$Domain
)

try {
    # Get configuration naming context (path to where certificate templates are stored in AD)
    $getRootDSEParams = @{
        ErrorAction = 'Stop'
    }
    if ($Domain) {
        $getRootDSEParams['Server'] = $Domain
    }

    $configNC = (Get-ADRootDSE @getRootDSEParams).configurationNamingContext

    # Build full path to the Certificate Templates container in AD (default path where templates are stored)
    $templateContainer = "CN=Certificate Templates,CN=Public Key Services,CN=Services,$configNC"

    Write-Verbose "Searching for template '$TemplateName' in $templateContainer"

    # Search for template
    # Escape special LDAP characters to prevent injection
    $escapedTemplateName = $TemplateName -replace '\\', '\5c' -replace '\*', '\2a' -replace '\(', '\28' -replace '\)', '\29' -replace '\0', '\00'

    # Request msPKI-Enrollment-Flag and displayName properties
    $getADObjectParams = @{
        SearchBase  = $templateContainer
        Filter      = "name -eq '$escapedTemplateName'"
        Properties  = @('msPKI-Enrollment-Flag', 'displayName')
        ErrorAction = 'Stop'
    }
    if ($Domain) {
        $getADObjectParams['Server'] = $Domain
    }

    $template = Get-ADObject @getADObjectParams

    if (-not $template) {
        Write-Warning "Template '$TemplateName' not found"
        Write-Warning "Make sure the template name is spelled correctly and exists in AD"
        exit 1
    }

    Write-Verbose "Found template: $($template.Name)"

    # Extract the enrollment flags from the template
    $enrollmentFlags = $template.'msPKI-Enrollment-Flag'

    # Check if the manager approval bit is set
    # Bit flag 0x00000002 = CT_FLAG_PEND_ALL_REQUESTS (manager approval required)
    $managerApprovalRequired = ($enrollmentFlags -band 0x00000002) -ne 0

    Write-Verbose "Enrollment flags value: $enrollmentFlags"

    # Check if template is published by looking for it in any CA's certificateTemplates attribute
    $CAContainer = "CN=Enrollment Services,CN=Public Key Services,CN=Services,$configNC"

    $getCAParams = @{
        SearchBase  = $CAContainer
        Filter      = "objectClass -eq 'pKIEnrollmentService'"
        Properties  = 'certificateTemplates'
        ErrorAction = 'Stop'
    }
    if ($Domain) {
        $getCAParams['Server'] = $Domain
    }

    $CAs = Get-ADObject @getCAParams

    # Use the Name property (which we know exists) instead of displayName for comparison
    $publishedCAs = $CAs | Where-Object { $_.certificateTemplates -contains $template.Name }
    $isPublished = ($publishedCAs | Measure-Object).Count -gt 0

    Write-Verbose "Template is published to $($publishedCAs.Count) CA(s)"

    # Output results
    Write-Output ""
    Write-Output "Template: $TemplateName"
    Write-Output "Published to CAs: $isPublished"
    Write-Output "Manager Approval Required: $managerApprovalRequired"
    Write-Output ""

    if (-not $isPublished) {
        Write-Warning "Template is not published to any Certificate Authorities"
    }

    if (-not $managerApprovalRequired) {
        Write-Warning "Manager approval is NOT required for this template"
    }

    # Return the manager approval status for programmatic use
    return $managerApprovalRequired

} catch {
    Write-Error "Error checking template: $($_.Exception.Message)"
    Write-Verbose $_.ScriptStackTrace
    exit 1
}
