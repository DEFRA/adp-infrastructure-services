using '../../../bicep-generic/cdn/application-domain.main.bicep'

param afdEndpointName = '#{{ environment_lower}}#{{ environmentId }}-adp-containerapps'

param appEndpointName = 'portal3'

//param originCustomHost = az.getSecret('#{{ ssvSubscriptionId }}', '#{{ ssvSharedResourceGroup }}', '#{{ ssvPlatformKeyVaultName }}', 'PORTAL-APP-DEFAULT-URL')

// This value comes from pre-deployment powershell task
param originCustomHost = '#{{ AppGatewayPublicIP }}'

param usePrivateLink = false

param enabledState = 'Enabled'

param forwardingProtocol = 'HttpOnly'
