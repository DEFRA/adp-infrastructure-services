using '../../../bicep-generic/cdn/application-domain.main.bicep'

param appEndpointName = 'portal'

param originCustomHost = az.getSecret('#{{ ssvSubscriptionId }}', '#{{ portalResourceGroup }}', '#{{ ssvPortalKeyVaultName }}', 'APP-DEFAULT-URL')

param usePrivateLink = false

param enabledState = 'Enabled'
