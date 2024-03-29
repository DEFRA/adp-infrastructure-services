
@description('Required. The name of the route.')
param name string

@description('Required. The name of the parent CDN profile.')
param profileName string

@description('Required. The name of the AFD endpoint.')
param afdEndpointName string

@description('Optional. The caching configuration for this route. To disable caching, do not provide a cacheConfiguration object.')
param cacheConfiguration object = {}

@description('Optional. The name of the custom domain. The custom domain must be defined in the profile customDomains.')
param customDomainName string

@allowed([
  'HttpOnly'
  'HttpsOnly'
  'MatchRequest'
])
@description('Optional. The protocol this rule will use when forwarding traffic to backends.')
param forwardingProtocol string = 'MatchRequest'

@allowed([
  'Disabled'
  'Enabled'
])
@description('Optional. Whether this route is enabled.')
param enabledState string = 'Enabled'

@allowed([
  'Disabled'
  'Enabled'
])
@description('Optional. Whether to automatically redirect HTTP traffic to HTTPS traffic.')
param httpsRedirect string = 'Enabled'

@allowed([
  'Disabled'
  'Enabled'
])
@description('Optional. Whether this route will be linked to the default endpoint domain.')
param linkToDefaultDomain string = 'Enabled'

@description('Required. The name of the origin group. The origin group must be defined in the profile originGroups.')
param originGroupName string = ''

@description('Optional. A directory path on the origin that AzureFrontDoor can use to retrieve content from, e.g. contoso.cloudapp.net/originpath.')
param originPath string = ''

@description('Optional. The route patterns of the rule.')
param patternsToMatch array = []

@description('Optional. The rule sets of the rule. The rule sets must be defined in the profile ruleSets.')
param ruleSets array = []

@description('Optional. The global rule sets of the rules that will be associated with every route.')
param globalRuleSets array = []

@allowed([ 'Http', 'Https' ])
@description('Optional. The supported protocols of the rule.')
param supportedProtocols array = []

var mergedRuleSets = concat(ruleSets, globalRuleSets)


resource profile 'Microsoft.Cdn/profiles@2023-05-01' existing = {
  name: profileName

  resource afd_endpoint 'afdEndpoints@2023-05-01' existing = {
    name: afdEndpointName
  }

  resource custom_domain 'customDomains@2023-05-01' existing = if (!empty(customDomainName)) {
    name: customDomainName
  }

  resource originGroup 'originGroups@2023-05-01' existing = {
    name: originGroupName
  }

  resource rule_set 'ruleSets@2023-05-01' existing = [for ruleSet in mergedRuleSets: {
    name: ruleSet.name
  }]
}

resource afd_endpoint_route 'Microsoft.Cdn/profiles/afdEndpoints/routes@2023-05-01' = {
  name: name
  parent: profile::afd_endpoint
  properties: {
    cacheConfiguration: !empty(cacheConfiguration) ? cacheConfiguration : null
    customDomains: !empty(customDomainName) ? [ {
        id: profile::custom_domain.id
      } ] : []
    enabledState: enabledState
    forwardingProtocol: forwardingProtocol
    httpsRedirect: httpsRedirect
    linkToDefaultDomain: linkToDefaultDomain
    originGroup: {
      id: profile::originGroup.id
    }
    originPath: !empty(originPath) ? originPath : null
    patternsToMatch: patternsToMatch
    ruleSets: [for (item, index) in mergedRuleSets: {
      id: profile::rule_set[index].id
    }]
    supportedProtocols: !empty(supportedProtocols) ? supportedProtocols : null
  }
}

@description('The name of the route.')
output name string = afd_endpoint_route.name

@description('The ID of the route.')
output resourceId string = afd_endpoint_route.id

@description('The name of the resource group the route was created in.')
output resourceGroupName string = resourceGroup().name
