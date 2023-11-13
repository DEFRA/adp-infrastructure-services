@description('Required. The name of the CDN profile.')
param profileName string

@description('Required. The name of the security policy')
param securityPolicyName string

resource profile 'Microsoft.Cdn/profiles@2023-05-01' existing = {
  name: profileName

  resource security_policy 'securityPolicies@2023-05-01' existing = {
    name: securityPolicyName
  }
}

output domains array = profile::security_policy.properties.parameters.associations[0].domains
