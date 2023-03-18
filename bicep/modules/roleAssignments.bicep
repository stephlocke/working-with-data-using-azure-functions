param principalId string

param roleDefinitionIds array

var roleAssignmentsToCreate = [for roleDefinitionId in roleDefinitionIds: {
  name: guid(principalId, roleDefinitionId)
  roleDefinitionId: roleDefinitionId
}]

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for roleAssignmentToCreate in roleAssignmentsToCreate: {
  name: roleAssignmentToCreate.name
  scope: resourceGroup()
  properties: {
    description: roleAssignmentToCreate.name
    principalId: principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleAssignmentToCreate.roleDefinitionId)
    principalType: 'ServicePrincipal'
  }
}]
