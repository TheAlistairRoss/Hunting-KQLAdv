param workspaceName string
param location string

param dataCollectionEndpointName string
param dataCollectionRuleName string
param managedIdentityName string

var monitoringMetricsPublisherRoleId = resourceId('microsoft.authorization/roleDefinitions','3913510d-42f4-4e42-8a64-420c390055eb')
var roleAssignmentName = guid(managedIdentity.name, monitoringMetricsPublisherRoleId, resourceGroup().id)

var windowsEventTableName = 'WindowsEvent_CL'
var windowsEventTableSchema = [
  {
    name: 'TimeGenerated'
    type: 'datetime'
  }
  {
    name: 'OperationName'
    type: 'string'
  }
  {
    name: 'Category'
    type: 'string'
  }
  {
    name: 'ResultType'
    type: 'string'
  }
  {
    name: 'ResultDescription'
    type: 'string'
  }
  {
    name: 'CorrelationId'
    type: 'string'
  }
  {
    name: 'Identity'
    type: 'string'
  }
  {
    name: 'Level'
    type: 'string'
  }
  {
    name: 'Location'
    type: 'string'
  }
  {
    name: 'AppDisplayName'
    type: 'string'
  }
  {
    name: 'AppId'
    type: 'string'
  }
  {
    name: 'ClientAppUsed'
    type: 'string'
  }
  {
    name: 'ConditionalAccessStatus'
    type: 'string'
  }
  {
    name: 'DeviceDetail'
    type: 'dynamic'
  }
  {
    name: 'IPAddress'
    type: 'string'
  }
  {
    name: 'LocationDetails'
    type: 'dynamic'
  }
  {
    name: 'ResourceDisplayName'
    type: 'string'
  }
  {
    name: 'Status'
    type: 'dynamic'
  }
  {
    name: 'UserDisplayName'
    type: 'string'
  }
  {
    name: 'UserPrincipalName'
    type: 'string'
  }
  {
    name: 'UserType'
    type: 'string'
  }
]

var windowsEventFunctionProperties = {
  category: 'SentAdvHunting'
  displayName: 'fWindowsEvent'
  version: 2
  functionAlias: 'fWindowsEvent'
  query: 'WindowsEvent_Cl'
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: workspaceName
}

resource windowsEventTable 'Microsoft.OperationalInsights/workspaces/tables@2022-10-01' = {
  parent: logAnalyticsWorkspace
  name: windowsEventTableName
  properties: {
    schema: {
      name: windowsEventTableName
      columns: windowsEventTableSchema
    }
  }
}

resource windowEventFunction 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  parent: logAnalyticsWorkspace
  dependsOn: [
    windowsEventTable
  ]
  name: windowsEventFunctionProperties.functionAlias
  properties: windowsEventFunctionProperties
}

resource dataCollectionEndpoint 'Microsoft.Insights/dataCollectionEndpoints@2021-09-01-preview' = {
  name: dataCollectionEndpointName
  location: location
  properties: {
    networkAcls: {
      publicNetworkAccess: 'Enabled'
    }
  }
}

resource dataCollectionRule 'Microsoft.Insights/dataCollectionRules@2021-09-01-preview' = {
  name: dataCollectionRuleName
  dependsOn: [
    windowsEventTable
  ]
  location: location
  properties: {
    dataCollectionEndpointId: dataCollectionEndpoint.id
    dataFlows: [
      {
        streams: [
          'Custom-${windowsEventTableName}'
        ]
        destinations: [
          'workspaceStream'
        ]
        transformKql: 'source'
        outputStream: 'Custom-${windowsEventTableName}'
      }
    ]
    description: 'string'
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: logAnalyticsWorkspace.id
          name: 'workspaceStream'
        }
      ]
    }

    streamDeclarations: {
      'Custom-${windowsEventTableName}': {
        columns: windowsEventTableSchema
      }
    }
  }
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' = {
  name: managedIdentityName
  location: location
}

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  scope: dataCollectionEndpoint
  name: roleAssignmentName
  properties: {
    roleDefinitionId: monitoringMetricsPublisherRoleId
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}
