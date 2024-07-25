[CmdletBinding()]
param(
    [Parameter(Mandatory)] 
    [string]$ServiceBusAccessTo,
    [Parameter(Mandatory)] 
    [string]$ServiceBusSubscriptionId,
    [Parameter(Mandatory)] 
    [string]$ServiceBusNamespace,
    [Parameter(Mandatory)] 
    [string]$ServiceBusRgName
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
Write-Debug "${functionName}:ServiceBusNamespace=$ServiceBusNamespace"

try {

    $serviceBusAccessToList = ConvertFrom-Json $ServiceBusAccessTo

    foreach ($serviceBusAccessToObj in $serviceBusAccessToList) {

        $servicePrincipal = Get-AzADServicePrincipal -DisplayName $serviceBusAccessToObj.servicePrincipalName

        if ($null -ne $servicePrincipal) {

            if ($serviceBusAccessToObj.entityType = 'Topics') {
                $scope ="/subscriptions/$ServiceBusSubscriptionId/resourceGroups/$ServiceBusRgName/providers/Microsoft.ServiceBus/namespaces/$ServiceBusNamespace/topics/${serviceBusAccessToObj.entityName}"
            }
            else {
                $scope ="/subscriptions/$ServiceBusSubscriptionId/resourceGroups/$ServiceBusRgName/providers/Microsoft.ServiceBus/namespaces/$ServiceBusNamespace/queues/${serviceBusAccessToObj.entityName}"
            }

            Write-Host "Scope: $scope"

            $roleDefinition = Get-AzRoleDefinition -Name $serviceBusAccessToObj.roleDefinitionName
            if ($null -ne $roleDefinition) {
                
                $roleAssignment = Get-AzRoleAssignment -ObjectId $servicePrincipal.Id -Scope $scope -RoleDefinitionName $serviceBusAccessToObj.roleDefinitionName -ErrorAction SilentlyContinue
                if ($null -eq $roleAssignment) {
                    New-AzRoleAssignment -ObjectId $servicePrincipal.Id -Scope $scope -RoleDefinitionName $serviceBusAccessToObj.roleDefinitionName
                    
                    New-AzRoleAssignment -RoleDefinitionName $roleName -ObjectId $miObjectID  -Scope $clientSecretResourceID
       
                }
                else {
                    Write-Host "Role Assignment exists"
                }
            }
        }
        else {
            Write-Host "Service Principal does not exist"
        }
    }

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
