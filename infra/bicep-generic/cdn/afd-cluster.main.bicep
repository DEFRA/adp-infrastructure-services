@description('Required. The name of the service.')
param serviceName string ='ffc-demo1'

@allowed([
  'Disabled'
  'Enabled'
])
@description('Required. The state of the route.')
param enabledState string = 'Enabled'

@description('Required. The rules to apply to the route.')
param ruleSets array = []

var dnsZoneName = '#{{ publicDnsZoneName }}'
var dnsZoneResourceGroup  = '#{{ dnsResourceGroup }}'

var profileName = '#{{ infraResourceNamePrefix }}#{{ nc_resource_frontdoor }}#{{ nc_instance_regionid }}01'
var endpointName = '#{{ cdnProfileName }}'
var loadBalancerPlsName = '#{{ aksLoadBalancerPlsName }}'
var loadBalancerPlsResourceGroup = '#{{ aksResourceGroup }}-Managed'

var hostName = '${serviceName}.${dnsZoneName}'

var customDomainConfig = {
  name: '${serviceName}-custom-domain'
  hostName: hostName
  certificateType: 'ManagedCertificate'
}

var originGroupConfig = {
  healthProbeSettings: {}
  loadBalancingSettings: {
    additionalLatencyInMilliseconds: 0
    sampleSize: 4
    successfulSamplesRequired: 2
  }
  sessionAffinityState: 'Disabled'
}

module profile_custom_domain '.bicep/customdomain/main.bicep' = {
  name: '${uniqueString(deployment().name)}-CustomDomain'
  params: {
    name: customDomainConfig.name
    profileName: profileName
    afdEndpointName: endpointName
    dnsZoneName: dnsZoneName
    dnsZoneResourceGroup: dnsZoneResourceGroup
    hostName: customDomainConfig.hostName
    certificateType: customDomainConfig.certificateType
  }
}

resource aks_loadbalancer_pls 'Microsoft.Network/privateLinkServices@2023-05-01' existing = {
  name: loadBalancerPlsName
  scope: resourceGroup(loadBalancerPlsResourceGroup)
}

module profile_origionGroup '.bicep/origingroup/main.bicep' = {
  name: '${uniqueString(deployment().name)}-Profile-OrigionGroup'
  dependsOn: [
    profile_custom_domain
  ]
  params: {
    name: serviceName
    profileName: profileName
    healthProbeSettings: originGroupConfig.healthProbeSettings
    loadBalancingSettings: originGroupConfig.loadBalancingSettings
    sessionAffinityState: originGroupConfig.sessionAffinityState
    origins: map(range(0,1), i => {
        name: serviceName
        hostName: aks_loadbalancer_pls.properties.alias
        sharedPrivateLinkResource: {
          privateLink: {
            id: aks_loadbalancer_pls.id
          }
          privateLinkLocation: aks_loadbalancer_pls.location
          requestMessage: serviceName
        }
        originHostHeader: hostName
      })
  }
}

module profile_ruleSet '.bicep/ruleset/main.bicep' = [for (ruleSet, index) in ruleSets: {
  name: '${uniqueString(deployment().name)}-Profile-RuleSet-${index}'
  params: {
    name: ruleSet.name
    profileName: profileName
    rules: ruleSet.rules
  }
}]

module afd_endpoint_route '.bicep/route/main.bicep' = {
  name: '${uniqueString(deployment().name)}-Profile-AfdEndpoint-Route'
  dependsOn: [
    profile_custom_domain
    profile_origionGroup
    profile_ruleSet
  ]
  params: {
    name: serviceName
    profileName: profileName
    afdEndpointName: endpointName
    customDomainName: customDomainConfig.name
    enabledState: enabledState
    forwardingProtocol: 'HttpOnly'
    httpsRedirect: 'Enabled'
    linkToDefaultDomain: 'Disabled'
    originGroupName: profile_origionGroup.outputs.name
    originPath: ''
    patternsToMatch: []
    ruleSets: []
    supportedProtocols: []
  }
}

module security_policy '.bicep/securitypolicy/main.bicep' = {
  name: '${uniqueString(deployment().name)}-Security-Policy'
  dependsOn: [
    profile_custom_domain
  ]
  params: {
    name: 'default'
    profileName: profileName
    customDomainName: customDomainConfig.name
    wafPolicyName: 'test'
  }
}
