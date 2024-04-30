using '../../../bicep-generic/cdn/application-domain.main.bicep'

param afdEndpointName = '#{{ environment_lower}}#{{ environmentId }}-adp-adocallbackapi'

param appEndpointName = 'ado-callback-api'

param originCustomHost = '#{{ callBackApiInternalHostName }}'

param usePrivateLink = false

param enabledState = 'Enabled'

param forwardingProtocol = 'HttpOnly'
