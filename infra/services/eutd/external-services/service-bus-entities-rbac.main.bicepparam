using '../../../bicep-generic/service-bus/service-bus-entities-rbac.main.bicep'

param principalId = '36d9c2f0-4e58-4b7a-9f70-3363e88c9b9d' 

//'#{{ serviceBusEntitiesRbacPrincipalId }}'

param topicsRoleAssignments = [
  {
    entityName: 'eutd-trade-exports-core-plingestion'
    roleDefinitionName: 'Azure Service Bus Data Sender'
  }
]
