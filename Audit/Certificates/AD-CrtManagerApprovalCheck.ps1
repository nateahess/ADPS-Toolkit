
<#

Title: AD-CrtManagerApprovalCheck.ps1
Description: Script to check if a certificate template has manager approval enabled 
Author: Nathan Hess 
Last Updated: 8/1/2025

Usage: 

    Example: .\AD-CrtManagerApprovalCheck.ps1 -TemplateName "TemplateName" -domain "domain.org"

#>
#PARAMETER TemplateName - The name of the template to check (case-sensitive)

param (

    [Parameter(Mandatory=$true)]
    [string]$templateName,
    [string]$domain

)

try { 

    #Get configuration naming context (path to where certificate templates are stored in AD)
    $configNC = (Get-ADRootDSE -Server $domain).configurationNamingContext 
    #Build full path to the Certificate Templates container in AD (default path where templates are stored)
    $templateContainer = "CN=Certificate Templates,CN=Public Key Services,CN=Services,$configNC"

    #Search for template 
    #Request msPKI-Enrollment-Flag property, which contains enrollment settings for the template 
    $template = Get-ADObject -SearchBase $templateContainer -Filter "name -eq '$templateName'" -Properties msPKI-Enrollment-Flag -Server $domain

    if (-not $template) { 

        Write-Host "Template '$templateName' not found" -ForegroundColor Red 
        Write-Host "Make sure the template name is spelled correctly and exists in AD" -ForegroundColor Yellow
        exit 1

    }

    # Extract the enrollment flags from the template
    $enrollmentFlags = $template.'msPKI-Enrollment-Flag'

    #Check if the manager approval bit is set. 
    $managerApprovalRequired = ($enrollmentFlags -band 0x00000002) -ne 0

    #Check if template is publisehd by looking for it in any CA's certificateTemplates Attribute
    $CAContainer = "CN=Enrollment Services,CN=Public Key Services,CN=Services,$configNC"
    $CAs = Get-ADObject -SearchBase $CAContainer -Filter "objectClass -eq 'pKIEnrollmentService'" -Properties certificateTemplates
    $IsPublished = $CAs | Where-Object { $_.certificateTemplates -contains $template.displayName} | Measure-Object | Select-Object -ExpandProperty Count
    $IsPublished = $IsPublished -gt 0

    Write-Host "Template: $templateName" -ForegroundColor Magenta
    Write-Host "Published to CAs: $IsPublished" -ForegroundColor $(if($IsPublished){"Magenta"}else{"Red"})
    Write-Host "Manager Approval Required: $managerApprovalRequired" -ForegroundColor $(if($managerApprovalRequired){"Green"}else{"Red"})

    return $managerApprovalRequired

} catch { 

    Write-Error "Error checking template: $($_.Exception.Message)"
   
}
