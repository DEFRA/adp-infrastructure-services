//Bicep File for Action Groups 
@description('The actionGroups object defines the action groups to be created')
param actionGroups object = {}
param createActionGroups bool = false
param service string = ''

@description('The logAlerts object is used to create log alerts in Azure Monitor.')
param logAlerts object = {}
param createLogAlerts bool = false


module actionGroup 'br/public:avm/res/insights/action-group:0.4.0' = [for actionGroup in items(actionGroups): if (createActionGroups) {
  name: '${actionGroup.value.name}-action-group'
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

module scheduledQueryRule 'br/public:avm/res/insights/scheduled-query-rule:0.3.0' = [for logAlert in items(logAlerts): if (createLogAlerts) {
  name: '${logAlert.value.name}-log-alert'
  params: {
    // Required parameters
    criterias: logAlert.value.criterias
    name: '${service}-${logAlert.value.name}'
    scopes: [
      logAlert.value.logAnalyticsWorkspaceResourceId
    ]
    // Non-required parameters
    evaluationFrequency: logAlert.value.evaluationFrequency != '' ? logAlert.value.evaluationFrequency : 'PT5M'
    location: logAlert.value.location
    alertDescription: logAlert.value.description
    windowSize: logAlert.value.windowSize != '' ? logAlert.value.windowSize : 'PT5M'
    actions: [
      logAlert.value.actionGroup
    ]
  }
}]
