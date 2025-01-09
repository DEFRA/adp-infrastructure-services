//Bicep File for Action Groups 
@description('A sample parameter for demonstration purposes')
param actionGroups object = {}

module actionGroup 'br/public:avm/res/insights/action-group:0.4.0' = [for actionGroup in items(actionGroups): if (!empty(actionGroups)){
  name: actionGroup.value.name
  params: {
    // Required parameters
    groupShortName: actionGroup.value.groupShortName
    name: actionGroup.value.name
    // Non-required parameters
    location: 'global'
  }
}]
