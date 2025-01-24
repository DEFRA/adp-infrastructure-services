//Bicep File for Log Alerts (https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/resource-manager-alerts-log?tabs=bicep#template-for-all-resource-types-from-version-2021-08-01)

@description('The logAlerts object is used to create log alerts in Azure Monitor.')
param logAlerts object = {}
param createLogAlerts bool = false
param service string = ''

module scheduledQueryRule 'br/public:avm/res/insights/scheduled-query-rule:<version>' = [for logAlert in items(logAlerts): if (createLogAlerts) {
  name: logAlert.value.name
  params: {
    // Required parameters
    criterias: logAlert.value.criterias
    name: '${service}-${logAlert.value.name}'
    scopes: [
      logAlert.value.logAnalyticsWorkspaceResourceId
    ]
    // Non-required parameters
    evaluationFrequency: 'PT5M'
    location: logAlert.value.location
    windowSize: 'PT5M'
    actions: [
      logAlert.value.actionGroup
    ]
  }
}]
