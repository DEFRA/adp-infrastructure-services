using '../../../bicep-generic/cdn/application-domain.main.bicep'

param appEndpointName = 'ffc-demo-web'

param enabledState = 'Enabled'

param ruleSets = [
    {
        name: "ResponseHeaderRuleSet"
        rules: [
            {
                name: AppendStrictTransportSecurityHeader
                order: 0
                actions: [
                    {
                        "name": "ModifyResponseHeader",
                        "parameters": {
                            "typeName": "DeliveryRuleHeaderActionParameters",
                            "headerAction": "Append",
                            "headerName": "Strict-Transport-Security",
                            "value": "max-age=31536000; includeSubDomains"
                        }
                    }
                ]
            }
        ]
    }
]
