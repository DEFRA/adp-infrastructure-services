using '../../../bicep-generic/monitoring/alerts.main.bicep'

param actionGroups = #{{ actionGroups }}
param createActionGroups = #{{ createActionGroups }}
param logAlerts = #{{ logAlerts }}
param createLogAlerts = #{{ createLogAlerts }}
param service = '#{{ appEndpoint }}'
