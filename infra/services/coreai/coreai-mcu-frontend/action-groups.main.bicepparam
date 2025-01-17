using '../../../bicep-generic/monitoring/action-groups.main.bicep'

param actionGroups = json('#{{ actionGroups }}')
param createActionGroups = #{{ createActionGroups }}
param service = '#{{ appEndpoint }}'
