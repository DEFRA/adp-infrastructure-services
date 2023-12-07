using '../../../bicep-generic/cdn/application-domain.main.bicep'

param appEndpointName = 'portal'

param originCustomHost = az.getSecret('#{{ ssvSubscriptionId }}', '#{{ ssvSharedResourceGroup }}', '#{{ ssvPlatformKeyVaultName }}', 'PORTAL-APP-DEFAULT-URL')

param usePrivateLink = false

param enabledState = 'Enabled'
