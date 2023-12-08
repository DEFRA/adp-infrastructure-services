@description('Required. The name of the security policy')
param name string

param profileName string

param wafPolicyName string

param customDomainName string

resource profile 'Microsoft.Cdn/profiles@2023-05-01' existing = {
  name: profileName

  resource custom_domain 'customDomains@2023-05-01' existing = {
    name: customDomainName
  }
}

module getExistingDomains '.bicep/getdomains/main.bicep' = {
  name: 'getDomains'
  params: {
    profileName: profileName
    securityPolicyName: name
  }
}

module security_policy '.bicep/associatedomain/main.bicep' = {
  name: 'associateomains'
  params: {
    profileName: profileName
    wafPolicyName: wafPolicyName
    name: name    
    domainlist: union(getExistingDomains.outputs.customdomainlist,array(profile::custom_domain.id))
  }
  dependsOn: [
    getExistingDomains
  ]
}
