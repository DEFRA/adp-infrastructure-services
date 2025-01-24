using '../../../bicep-generic/monitoring/log-alerts.main.bicep'

param logAlerts = #{{ logAlerts }}
param createLogAlerts = #{{ createLogAlerts }}
param service = '#{{ appEndpoint }}'
