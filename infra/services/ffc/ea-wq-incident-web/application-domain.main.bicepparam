using '../../../bicep-generic/cdn/application-domain.main.bicep'

param appEndpointName = 'ea-wq-incident-web'

param enabledState = 'Enabled'

param ingressType = 'external'

param wafName = '#{{ wafPolicyName }}'


