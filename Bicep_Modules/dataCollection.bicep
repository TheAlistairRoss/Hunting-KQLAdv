param workspaceName string
param location string

param dataCollectionEndpointName string
param dataCollectionRuleName string
param managedIdentityName string

var monitoringMetricsPublisherRoleId = resourceId('microsoft.authorization/roleDefinitions', '3913510d-42f4-4e42-8a64-420c390055eb')
var roleAssignmentName = guid(managedIdentity.name, monitoringMetricsPublisherRoleId, resourceGroup().id)


resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: workspaceName
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
  location: location
  properties: {
    dataCollectionEndpointId: dataCollectionEndpoint.id
    dataFlows: [
      {
        streams: [
          'Custom-WindowsEvent'
        ]
        destinations: [
          workspaceName
        ]
        transformKql: 'source | extend EventData = parse_json(RawEventData) | extend Channel=tostring(EventData.Channel),Computer=tostring(EventData.Hostname),EventID=toint(EventData.EventID),EventLevel=toint(EventData.Level),Provider=tostring(EventData.SourceName),Task=toint(EventData.Task),Type=\'WindowsEvent\'| project TimeGenerated,Channel,Computer,EventData,EventID,EventLevel,Provider,Task,Type'
        outputStream: 'Microsoft-WindowsEvent'
      }
    ]
    description: 'string'
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: logAnalyticsWorkspace.id
          name: workspaceName
        }
      ]
    }

    streamDeclarations: {
      'Custom-WindowsEvent': {
        columns: [
          {
            name: 'TimeGenerated'
            type: 'datetime'
          }
          {
            name: 'RawEventData'
            type: 'string'
          }
        ]
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

output dataCollectionRuleImmutableId string = dataCollectionRule.properties.immutableId

output dataCollectionEndpointURI string = dataCollectionEndpoint.properties.logsIngestion.endpoint
