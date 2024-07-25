[CmdletBinding()]
param(
    [Parameter(Mandatory)] 
    [string]$ServiceBusAccessTo,    
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
Write-Debug "${functionName}:ServiceBusAccessTo=$ServiceBusAccessTo"
Write-Debug "${functionName}:ServiceBusNamespace=$ServiceBusNamespace"
Write-Debug "${functionName}:ServiceBusRgName=$ServiceBusRgName"

try {
    $serviceBusAccessToList = ConvertFrom-Json $ServiceBusAccessTo

    foreach ($serviceBusAccessToObj in $serviceBusAccessToList) {

        Write-Debug "${functionName}:serviceBusAccessToObj=$serviceBusAccessToObj"
        $servicePrincipal = Get-AzADServicePrincipal -DisplayName $serviceBusAccessToObj.servicePrincipalName

        if ($servicePrincipal) {
            
            if ($serviceBusAccessToObj.entityType -eq "Queues") {
                $entity = Get-AzServiceBusQueue -Name $serviceBusAccessToObj.entityName -ResourceGroupName $ServiceBusRgName -NamespaceName $ServiceBusNamespace 
            }
            else {
                $entity = Get-AzServiceBusTopic -Name $serviceBusAccessToObj.entityName -ResourceGroupName $ServiceBusRgName -NamespaceName  $ServiceBusNamespace
            }

            if (-not $entity) {
                throw "$($serviceBusAccessToObj.entityType) : '$($serviceBusAccessToObj.entityName)' not found"
            }

            Write-Debug "${functionName}:Scope=$($entity.Id)"

            $roleDefinition = Get-AzRoleDefinition -Name $serviceBusAccessToObj.roleDefinitionName
            if ($roleDefinition) {
                $roleAssignment = Get-AzRoleAssignment -ObjectId $servicePrincipal.Id -Scope $entity.Id -RoleDefinitionName $roleDefinition.Name -ErrorAction SilentlyContinue

                if (-not $roleAssignment) {
                    Write-Host "Assigning role '$($serviceBusAccessToObj.roleDefinitionName)' to service principal '$($serviceBusAccessToObj.servicePrincipalName)'"
                    New-AzRoleAssignment -ObjectId $servicePrincipal.Id -Scope $entity.Id -RoleDefinitionName $roleDefinition.Name
                }
                else {
                    Write-Host "Role assignment '$($roleDefinition.Name)' already exists for service principal '$($serviceBusAccessToObj.servicePrincipalName)'"
                }
            }
            else {
                throw "Role definition '$($serviceBusAccessToObj.roleDefinitionName)' not found"
            }
        }
        else {
            throw "Service Principal '$($serviceBusAccessToObj.servicePrincipalName)'  not found"
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
