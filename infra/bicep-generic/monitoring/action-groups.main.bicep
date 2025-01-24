//Bicep File for Action Groups 
@description('A sample parameter for demonstration purposes')
param actionGroups object = {}
param createActionGroups bool = false
param service string = ''

module actionGroup 'br/public:avm/res/insights/action-group:0.4.0' = [for actionGroup in items(actionGroups): if (createActionGroups) {
  name: actionGroup.value.name
  params: {
    // Required parameters
    groupShortName: actionGroup.value.groupShortName
    name: '${service}-${actionGroup.value.name}'
    // Non-required parameters
    location: 'global'
    emailReceivers: actionGroup.value.emailReceivers
  }
}]

output actionGroupName array = [for actiongroup in items(actionGroups): {
  name: '${service}-${actiongroup.value.name}'
}]

