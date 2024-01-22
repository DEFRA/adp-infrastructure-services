using '../../../bicep-generic/cdn/application-domain.main.bicep'

param afdEndpointName = '#{{ environment_lower}}#{{ environmentId }}-adp-portal'

param appEndpointName = '#{{ ssvResourceNamePrefix }}#{{ nc_resource_containerapps }}#{{ nc_shared_instance_regionid }}01'

param originCustomHost = az.getSecret('#{{ ssvSubscriptionId }}', '#{{ ssvSharedResourceGroup }}', '#{{ ssvPlatformKeyVaultName }}', 'PORTAL-APP-DEFAULT-URL')

param usePrivateLink = false

param enabledState = 'Enabled'
