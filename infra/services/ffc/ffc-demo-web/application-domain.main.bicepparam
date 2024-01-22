using '../../../bicep-generic/cdn/application-domain.main.bicep'

param appEndpointName = 'ffc-demo-web'

param enabledState = 'Enabled'

param ruleSets = [
      {
        name: 'DummyRuleSet2'
        rules: [
          {
            actions: [
              {
                name: 'ModifyResponseHeader'
                parameters: {
                  typeName: 'DeliveryRuleHeaderActionParameters',
                  headerAction: 'Append',
                  headerName: 'X-Rule2-version',
                  value: 'v2'
                }
              }
            ]
            name: 'Rule2'
            order: 1
          }
        ]
      }
    ]