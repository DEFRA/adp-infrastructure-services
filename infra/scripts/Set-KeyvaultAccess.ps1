<#
.SYNOPSIS
Set Keyvault Secrets Officer role to service connection for given keyvault

.DESCRIPTION
Set Keyvault Secrets Officer role to service connection for given keyvault to store the app reg secrets

.PARAMETER AppRegConnection
Mandatory. App registration connection name.
.PARAMETER SubscriptionId
Mandatory. SubscriptionId .
.PARAMETER ResourceGroupName
Mandatory. ResourceGroupName Name.
.PARAMETER Keyvault
Mandatory. Keyvault Name.

.EXAMPLE
.\Set-KeyvaultAccess.ps1 -AppRegConnection <AppRegConnection> -SubscriptionId <SubscriptionId> -ResourceGroupName <ResourceGroupName> -Keyvault <Keyvault>
#> 

[CmdletBinding()]
param(
    [Parameter(Mandatory)] 
    [string] $AppRegConnection,
    [Parameter(Mandatory)]
    [string] $SubscriptionId,
    [Parameter(Mandatory)]
    [string] $ResourceGroupName,
    [Parameter(Mandatory)]
    [string] $Keyvault
)

Set-StrictMode -Version 3.0

[string]$functionName = $MyInvocation.MyCommand
[datetime]$startTime = [datetime]::UtcNow

[int]$exitCode = -1
[bool]$setHostExitCode = (Test-Path -Path ENV:TF_BUILD) -and ($ENV:TF_BUILD -eq "true")
[bool]$enableDebug = (Test-Path -Path ENV:SYSTEM_DEBUG) -and ($ENV:SYSTEM_DEBUG -eq "true")

Set-Variable -Name ErrorActionPreference -Value Continue -scope global
Set-Variable -Name InformationPreference -Value Continue -Scope global

if ($enableDebug) {
    Set-Variable -Name VerbosePreference -Value Continue -Scope global
    Set-Variable -Name DebugPreference -Value Continue -Scope global
}

Write-Host "${functionName} started at $($startTime.ToString('u'))"
Write-Debug "${functionName}:AppRegConnection=$AppRegConnection"
Write-Debug "${functionName}:SubscriptionId=$SubscriptionId"
Write-Debug "${functionName}:ResourceGroupName=$ResourceGroupName"
Write-Debug "${functionName}:Keyvault=$Keyvault"

try {

    #$appId = az ad sp list --filter "displayname eq '$AppRegConnection'" --query "[].{appId:appId}" --output tsv
    az role assignment create --role "Key Vault Secrets Officer" --assignee $AppRegConnection --scope /subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.KeyVault/vaults/$Keyvault       
    $exitCode = 0
}
catch {
    $exitCode = -2
    Write-Error $_.Exception.ToString()
    throw $_.Exception
}
finally {
    [DateTime]$endTime = [DateTime]::UtcNow
    [Timespan]$duration = $endTime.Subtract($startTime)

    Write-Host "${functionName} finished at $($endTime.ToString('u')) (duration $($duration -f 'g')) with exit code $exitCode"
    if ($setHostExitCode) {
        Write-Debug "${functionName}:Setting host exit code"
        $host.SetShouldExit($exitCode)
    }
    exit $exitCode
}