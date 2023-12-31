
@description('Required. The name of the rule set.')
param name string

@description('Required. The name of the CDN profile.')
param profileName string

@description('Optinal. The rules to apply to the rule set.')
param rules array = []


resource profile 'Microsoft.Cdn/profiles@2023-05-01' existing = {
  name: profileName
}

resource rule_set 'Microsoft.Cdn/profiles/ruleSets@2023-05-01' = {
  name: name
  parent: profile
}

module rule 'rule/main.bicep' = [for (rule, index) in rules: {
  name: '${uniqueString(deployment().name)}-RuleSet-Rule-${rule.name}-${index}'
  params: {
    profileName: profileName
    ruleSetName: name
    name: rule.name
    order: rule.order
    actions: rule.actions
    conditions: contains(rule, 'conditions') ? rule.conditions : []
    matchProcessingBehavior: contains(rule, 'matchProcessingBehavior') ? rule.matchProcessingBehavior : 'Continue'
  }
}]

@description('The name of the rule set.')
output name string = rule_set.name

@description('The resource id of the rule set.')
output resourceId string = rule_set.id

@description('The name of the resource group the custom domain was created in.')
output resourceGroupName string = resourceGroup().name
