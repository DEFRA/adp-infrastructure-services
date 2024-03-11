@description('Required. The name of the custom domain.')
param name string

@description('Required. The name of the CDN profile.')
param profileName string

@description('Required. The name of the AFD endpoint.')
param afdEndpointName string

@description('Required. The host name of the domain. Must be a domain name.')
param hostName string

@description('Optonal. Resource reference to the Azure DNS zone.')
param azureDnsZoneResourceId string = ''

@description('Optional. Key-Value pair representing migration properties for domains.')
param extendedProperties object = {}

@description('Optional. Resource reference to the Azure resource where custom domain ownership was prevalidated.')
param preValidatedCustomDomainResourceId string = ''

@allowed([
  'CustomerCertificate'
  'ManagedCertificate'
])
@description('Required. The type of the certificate used for secure delivery.')
param certificateType string

@allowed([
  'TLS12'
])
@description('Optional. The minimum TLS version required for the custom domain. Default value: TLS12.')
param minimumTlsVersion string = 'TLS12'

@description('Optional. The name of the secret. ie. subs/rg/profile/secret.')
param secretName string = ''

param dnsZoneName string

param dnsZoneResourceGroup string


resource profile 'Microsoft.Cdn/profiles@2023-05-01' existing = {
  name: profileName

  resource profile_secrect 'secrets@2023-05-01' existing = if (!empty(secretName)) {
    name: secretName
  }

  resource afd_endpoint 'afdEndpoints@2023-05-01' existing = {
    name: afdEndpointName
  }
}

resource publicip 'Microsoft.Network/publicIPAddresses@2021-05-01' existing = {
  name: 'portal-gw-publicip'
  scope: resourceGroup('container-rg')
}

resource profile_custom_domain 'Microsoft.Cdn/profiles/customDomains@2023-05-01' = {
  name: name
  parent: profile
  properties: {
    azureDnsZone: !empty(azureDnsZoneResourceId) ? {
      id: azureDnsZoneResourceId
    } : null
    extendedProperties: !empty(extendedProperties) ? extendedProperties : null
    hostName: publicip.properties.ipAddress
    preValidatedCustomDomainResourceId: !empty(preValidatedCustomDomainResourceId) ? {
      id: preValidatedCustomDomainResourceId
    } : null
    tlsSettings: {
      certificateType: certificateType
      minimumTlsVersion: minimumTlsVersion
      secret: !(empty(secretName)) ? {
        id: profile::profile_secrect.id
      } : null
    }
  }
}

module dns_zone '../dns/main.bicep' = {
  name: '${uniqueString(deployment().name)}-Dns-Zone'
  scope: resourceGroup(dnsZoneResourceGroup)
  params: {
    dnsRecodName: name
    dnsZoneName: dnsZoneName
    endpointHostName: profile::afd_endpoint.properties.hostName
    txtValidationToken: profile_custom_domain.properties.validationProperties.validationToken
  }
}


@description('The name of the custom domain.')
output name string = profile_custom_domain.name

@description('The resource id of the custom domain.')
output resourceId string = profile_custom_domain.id

@description('The name of the resource group the custom domain was created in.')
output resourceGroupName string = resourceGroup().name

@description('The host name of the domain.!!!!!!!!!')
output ip string  = publicip.properties.ipAddress
