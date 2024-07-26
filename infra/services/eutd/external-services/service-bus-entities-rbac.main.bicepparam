using '../../../bicep-generic/service-bus/service-bus-entities-rbac.main.bicep'

param principalId = '#{{ serviceBusEntitiesRbacPrincipalId }}'

param topicsRoleAssignments = [
  {
    entityName: 'eutd-trade-exports-core-plingestion'
    roleDefinitionName: 'Azure Service Bus Data Sender'
  }
]
