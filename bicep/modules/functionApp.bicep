@description('Workload environment prefix')
param prefix string

@description('Location for all resources.')
param location string

@description('Storage account name')
param storageAccountName string

@description('Application Insights instrumentation key')
param instrumentationKey string

@description('Cosmos DB account name')
param databaseAccountName string

@description('SQL server name')
param sqlServerName string

@description('SQL database name')
param sqlDatabaseName string

@description('Event Hub Namespace name')
param eventHubNamespaceName string

@secure()
@description('Authentication provider client id')
param authProviderClientId string

@secure()
@description('Authentication provider secret')
param authProviderSecret string

@description('Active Directory admin tenant')
param adAdminTenant string

var functionAppName = '${prefix}-func'
var hostingPlanName = '${prefix}-asp'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' existing = {
  name: storageAccountName
}

resource databaseAccount 'Microsoft.DocumentDB/databaseAccounts@2021-04-15' existing = {
  name: databaseAccountName
}

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' existing = {
  name: sqlServerName
}

resource hostingPlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: hostingPlanName
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
  properties: {}
}

resource functionApp 'Microsoft.Web/sites@2021-03-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage__accountname'
          value: storageAccountName
        }
        // TODO: Move to Key Vault ref? 
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccount.listKeys().keys[0].value}'
        }
        {
          name: 'CorpDB__accountEndpoint'
          value: databaseAccount.properties.documentEndpoint
        }
        {
          name: 'SQLConnection'
          value: 'Server=${sqlServer.properties.fullyQualifiedDomainName}; Authentication=Active Directory Managed Identity; Database=${sqlDatabaseName}'
        }
        {
          name: 'EventHubConnection__fullyQualifiedNamespace'
          value: '${eventHubNamespaceName}.servicebus.windows.net'
        }
        {
          name: 'MICROSOFT_PROVIDER_AUTHENTICATION_SECRET'
          value: authProviderSecret
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(functionAppName)
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: instrumentationKey
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
      ]
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
    }
    httpsOnly: true
  }
}


resource authSettings 'Microsoft.Web/sites/config@2022-03-01' = {
  name: 'authsettingsV2'
  parent: functionApp
  properties: {
    globalValidation: {
      requireAuthentication: true
      unauthenticatedClientAction: 'Return401'
    }
    httpSettings: {
      requireHttps: true
      routes: {
        apiPrefix: '/.auth'
      }
      forwardProxy: {
        convention: 'NoProxy'
      }
    }
    identityProviders: {
      azureActiveDirectory: {
        enabled: true
        isAutoProvisioned: false
        login: {
          disableWWWAuthenticate: false
        }
        registration: {
          openIdIssuer: 'https://sts.windows.net/${adAdminTenant}/v2.0'
          clientId: authProviderClientId
          clientSecretSettingName: 'MICROSOFT_PROVIDER_AUTHENTICATION_SECRET'
        }
        validation: {
          allowedAudiences: [
            'api://${authProviderClientId}'
          ]
        }
      }
    }
    login: {
      cookieExpiration: {
        convention: 'FixedTime'
        timeToExpiration: '08:00:00'
      }
      nonce: {
        nonceExpirationInterval: '00:05:00'
        validateNonce: true
      }
      preserveUrlFragmentsForLogins: false
      tokenStore: {
        enabled: true
        tokenRefreshExtensionHours: 72
      }
    }
    platform: {
      enabled: true
      runtimeVersion: '~1'
    }
  }
}

module roleAssignments 'roleAssignments.bicep' = {
  name: 'roleAssignments'
  params: {
    principalId: functionApp.identity.principalId
    roleDefinitionIds: [
      'b7e6dc6d-f1e8-4753-8033-0f276bb0955b' // Storage Blob Data Owner
      'f526a384-b230-433a-b45c-95f59c4a2dec' // Azure Event Hubs Data Owner 
    ]
  }
}

resource roleDefinition 'Microsoft.DocumentDB/databaseAccounts/sqlRoleDefinitions@2021-04-15' existing = {
  parent: databaseAccount
  name: '00000000-0000-0000-0000-000000000002'
}

resource cosmosRoleAssignment 'Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments@2021-04-15' = {
  parent: databaseAccount
  name: guid('sql-role-definition-', functionApp.id, databaseAccount.id)
  properties: {
    roleDefinitionId: roleDefinition.id
    principalId: functionApp.identity.principalId
    scope: databaseAccount.id
  }
}
