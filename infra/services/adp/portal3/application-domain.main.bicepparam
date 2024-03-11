using '../../../bicep-generic/cdn/application-domain.main.bicep'

param afdEndpointName = '#{{ environment_lower}}#{{ environmentId }}-adp-containerapps'

param appEndpointName = 'portal3'

//param originCustomHost = az.getSecret('#{{ ssvSubscriptionId }}', '#{{ ssvSharedResourceGroup }}', '#{{ ssvPlatformKeyVaultName }}', 'PORTAL-APP-DEFAULT-URL')

param originCustomHost = '4.159.32.00'

param usePrivateLink = false

param enabledState = 'Enabled'

param forwardingProtocol = 'HttpOnly'

param gatewayFrontend = {
  resourcePublicIP: 'portal-gw-publicip'
  resourceGroup: 'container-rg'
  subscriptionID: '7dc5bbdf-72d7-42ca-ac23-eb5eea3764b4'
}
