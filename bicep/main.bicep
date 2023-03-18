@description('The name of the function app that you wish to create.')
param prefix string = uniqueString(resourceGroup().id)

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Active Directory admin login')
param adAdminLogin string

@description('Active Directory admin SID')
param adAdminSID string

@description('Active Directory admin tenant')
param adAdminTenant string

@secure()
@description('Authentication provider client id')
param authProviderClientId string

@secure()
@description('Authentication provider secret')
param authProviderSecret string

module storageAccount 'modules/storageAccount.bicep' = {
  name: 'storageAccount'
  params: {
    prefix: prefix
    location: location
  }
}

module appInsights 'modules/appInsights.bicep' = {
  name: 'appInsights'
  params: {
    prefix: prefix
    location: location
  }
}

module cosmosDB 'modules/cosmosDB.bicep' = {
  name: 'cosmosDB'
  params: {
    prefix: prefix
    location: location
  }
}

module azureSQL 'modules/azureSQL.bicep' = {
  name: 'azureSQL'
  params: {
    prefix: prefix
    location: location
    adAdminLogin: adAdminLogin
    adAdminSID: adAdminSID
    adAdminTenant: adAdminTenant
  }
}

module eventHub 'modules/eventHub.bicep' = {
  name: 'eventHub'
  params: {
    prefix: prefix
    location: location
  }
}

module functionApp 'modules/functionApp.bicep' = {
  name: 'functionApp'
  params: {
    prefix: prefix
    location: location
    storageAccountName: storageAccount.outputs.storageAccountName
    instrumentationKey: appInsights.outputs.instrumentationKey
    databaseAccountName: cosmosDB.outputs.databaseAccountName
    sqlServerName: azureSQL.outputs.sqlServerName
    sqlDatabaseName: azureSQL.outputs.sqlDatabaseName
    eventHubNamespaceName: eventHub.outputs.eventHubNamespaceName
    adAdminTenant: adAdminTenant
    authProviderClientId: authProviderClientId
    authProviderSecret: authProviderSecret
  }
}
