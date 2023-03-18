@description('Workload environment prefix')
param prefix string

@description('Location for all resources.')
param location string

var applicationInsightsName = '${prefix}-ai'

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: applicationInsightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}

output instrumentationKey string = applicationInsights.properties.InstrumentationKey
