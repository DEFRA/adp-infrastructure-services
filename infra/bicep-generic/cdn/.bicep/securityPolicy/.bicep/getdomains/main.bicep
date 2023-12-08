param profileName string
param securityPolicyName string
param utcValue string = utcNow()
param location string = resourceGroup().location

resource runPowerShellInlineWithOutput 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'runPowerShellInlineWithOutput'
  location: location
  kind: 'AzurePowerShell'
  properties: {
    forceUpdateTag: utcValue
    azPowerShellVersion: '9.0'
    scriptContent: '''
      param([string] $RGName, [string] $ProfileName, [string] $SecurityPolicyName)
      $SecurityPolicy = Get-AzFrontDoorCdnSecurityPolicy -ResourceGroupName $RGName -ProfileName $ProfileName -Name $SecurityPolicyName
      if($null -ne $SecurityPolicy){
        $output = $SecurityPolicy.Parameter.Association.domain | select id
      }else{
        $output = null
      }
      Write-Output $output
      $DeploymentScriptOutputs = @{}
      $DeploymentScriptOutputs["customdomainlist"] = $output
    '''
    arguments: '-RGName ${resourceGroup().name} -ProfileName ${profileName} -SecurityPolicyName ${securityPolicyName}'
    timeout: 'PT10M'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}


output customdomainlist array = runPowerShellInlineWithOutput.properties.outputs.customdomainlist

