targetScope = 'subscription'

param resourceGroupName string = 'rg-sent-adv-hunting'
param location string = 'uksouth'
param sentinelWorkspaceName string = 'sent-adv-hunting'
param dataCollectionEndpointName string = 'sent-adv-hunting-dce'
param dataCollectionRuleName string = 'sent-adv-hunting-dcr'

@description('This is the Object id of the Entperpise Application associated with the App Registration')
param applicationEnterpriseObjectId string

module resourceGroupDeployment 'Bicep_Modules/resourceGroup.bicep' = {
  name: 'resourceGroupDeployment'
  params:{
    resourceGroupName: resourceGroupName
    location: location
  }
}

module sentinelWorkspaceDeployment 'Bicep_Modules/sentinelWorkspace.bicep' = {
  dependsOn: [
    resourceGroupDeployment
  ]
  scope: resourceGroup(resourceGroupName)
  name: 'sentinelWorkspaceDeployment'
  params:{
    sentinelWorkspaceName: sentinelWorkspaceName
    location: location
  }
}

module dataCollectionDeployment 'Bicep_Modules/dataCollection.bicep' ={
  dependsOn: [
    sentinelWorkspaceDeployment
  ]
  scope: resourceGroup(resourceGroupName)
  name: 'dataCollectionDeployment'
  params: {
    workspaceName: sentinelWorkspaceName
    location: location
    dataCollectionEndpointName: dataCollectionEndpointName
    dataCollectionRuleName: dataCollectionRuleName
    applicationObjectId: applicationEnterpriseObjectId
  }
}

module contentDeployment 'Bicep_Modules/sentinelContent.bicep' ={
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    dataCollectionDeployment
  ]
  name: 'sentinelContentDeployment'
  params:{
    workspaceName: sentinelWorkspaceName
  }
}

output dataCollectionRuleImmutableId string = dataCollectionDeployment.outputs.dataCollectionRuleImmutableId
output dataCollectionEndpointUri string = dataCollectionDeployment.outputs.dataCollectionEndpointURI

