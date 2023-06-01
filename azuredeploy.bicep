targetScope = 'subscription'

param resourceGroupName string = 'rg-sent-adv-hunting-1'
param location string = 'uksouth'
param sentinelWorkspaceName string = 'sent-adv-hunting'
param dataCollectionEndpointName string = 'sent-adv-hunting-dce'
param dataCollectionRuleName string = 'sent-adv-hunting-dcr'
param managedIdentityName string = 'sent-adv-hunting-dcr-managedId'



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
    managedIdentityName: managedIdentityName
  }
}



