@description('Required. The name of the security policy')
param name string

@description('Required. The name of the profile.')
param profileName string

@description('Required. The name of the WAF policy.')
param wafPolicyName string

@description('Required. The name of the custom domain.')
param customDomainName string

resource profile 'Microsoft.Cdn/profiles@2023-05-01' existing = {
  name: profileName

  resource custom_domain 'customDomains@2023-05-01' existing = {
    name: customDomainName
  }
}

resource waf_policy 'Microsoft.Network/FrontDoorWebApplicationFirewallPolicies@2022-05-01' existing = {
  name: wafPolicyName
}

module security_policy_module 'dependencies.bicep' = {
  name: '${uniqueString(deployment().name)}-security_policy_module'
  params: {
    profileName: profileName
    securityPolicyName: name
  }
}

resource security_policy 'Microsoft.Cdn/profiles/securityPolicies@2023-05-01' = {
  name: name
  parent: profile
  properties: {
    parameters: {
      type: 'WebApplicationFirewall'
      wafPolicy: {
        id: waf_policy.id
      }
      associations: [
        {
          domains: union(security_policy_module.outputs.domains, [ { isActive: true, id: profile::custom_domain.id } ])
          patternsToMatch: [
            '/*'
          ]
        }
      ]
    }
  }
}
