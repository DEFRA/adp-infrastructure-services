using '../../../bicep-generic/cdn/application-domain.main.bicep'

param appEndpointName = 'portal'

param originCustomHost = 'portal.purpleplant-61657ddd.uksouth.azurecontainerapps.io'

param usePrivateLink = false

param enabledState = 'Enabled'
