@description('Name prefix for resources')
param namePrefix string = 'my'

@description('Location for all resources')
param location string = resourceGroup().location

// create a storage resource to hold function stuff
resource storage 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: '${namePrefix}storage'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    supportsHttpsTrafficOnly: true
  }
}

// create an app insights instance for observability
resource appInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: '${namePrefix}appinsights'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

// create an app service plan for hosting the function app
resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: '${namePrefix}appserviceplan'
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
    size: 'Y1'
    family: 'Y'
    capacity: 0
  }
  kind: 'functionapp'
  properties: {
    perSiteScaling: false
    reserved: false
    isSpot: false
    maximumElasticWorkerCount: 1
    targetWorkerCount: 0
    targetWorkerSizeId: 0
  }
}

// create an azure function that uses the storage and app insights resources
resource functionApp 'Microsoft.Web/sites@2020-06-01' = {
  name: '${namePrefix}functionapp'
  location: location
  kind: 'functionapp'
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: storage.properties.primaryEndpoints.blob
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
      ]
    }
  }
}
