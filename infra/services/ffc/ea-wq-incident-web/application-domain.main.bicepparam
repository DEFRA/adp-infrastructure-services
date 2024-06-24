using '../../../bicep-generic/cdn/application-domain.main.bicep'

param appEndpointName = '#{{ appEndpoint }}'

param enabledState = 'Enabled'

param wafName = '#{{ wafPolicyName }}'
