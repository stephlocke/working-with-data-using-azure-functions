@description('Workload environment prefix')
param prefix string

@description('Location for all resources.')
param location string

var storageAccountName = '${prefix}stor'

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'Storage'
}

output storageAccountName string = storageAccount.name
