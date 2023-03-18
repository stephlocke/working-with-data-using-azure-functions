@description('Workload environment prefix')
param prefix string

@description('Location for all resources.')
param location string

@description('Active Directory admin login')
param adAdminLogin string

@description('Active Directory admin SID')
param adAdminSID string

@description('Active Directory admin tenant')
param adAdminTenant string

var sqlServerName = '${prefix}-sqlserver'
var sqlDatabaseName = '${prefix}-sqldb'

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    administratorLogin: 'sqladmin'
    administratorLoginPassword: guid(resourceGroup().id, 'sqladmin')
  }
}

resource admin 'Microsoft.Sql/servers/administrators@2022-05-01-preview' = {
  name: 'ActiveDirectory'
  parent: sqlServer
  properties: {
    administratorType: 'ActiveDirectory'
    login: adAdminLogin
    sid: adAdminSID
    tenantId: adAdminTenant
  }
}

// WARNING: DON'T DO THIS IN PRODUCTION
// TODO: Remove this
resource symbolicname 'Microsoft.Sql/servers/firewallRules@2022-05-01-preview' = {
  name: 'Allow'
  parent: sqlServer
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255'
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  parent: sqlServer
  name: sqlDatabaseName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
}

output sqlServerName string = sqlServer.name
output sqlDatabaseName string = sqlDatabase.name
