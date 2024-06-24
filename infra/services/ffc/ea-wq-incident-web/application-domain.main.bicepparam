using '../../../bicep-generic/cdn/application-domain.main.bicep'

param appEndpointName = '#{{ appEndpointName }}'

param enabledState = 'Enabled'

param wafName = '#{{ wafPolicyName }}'
