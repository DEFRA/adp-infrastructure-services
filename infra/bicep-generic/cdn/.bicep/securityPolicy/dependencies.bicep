@description('Required. The name of the CDN profile.')
param profileName string

@description('Required. The name of the security policy')
param securityPolicyName string

@description('Required. The name of the custom domain.')
param customDomainName string

resource profile 'Microsoft.Cdn/profiles@2023-05-01' existing = {
  name: profileName

  resource custom_domain 'customDomains@2023-05-01' existing = {
    name: customDomainName
  }
  resource security_policy 'securityPolicies@2023-05-01' existing = {
    name: securityPolicyName
  }
}

output domains array = union(map(profile::security_policy.properties.parameters.associations[0].domains, (domain) => domain.id), [profile::custom_domain.id] )
