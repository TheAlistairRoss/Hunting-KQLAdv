targetScope = 'subscription'

param resourceGroupName string = 'rg-sent-adv-hunting'
param location string = 'uksouth'
param sentinelWorkspaceName string = 'sent-adv-hunting'
param dataCollectionEndpointName string = 'sent-adv-hunting-dce'
param dataCollectionRuleName string = 'sent-adv-hunting-dcr'

param applicationId string 
param tenantId string 
@secure()
param applicationSecret string
@description('This is the Object id of the Entperpise Application associated with the App Registration')
param applicationEnterpriseObjectId string

param ingestAPT29Logs bool = true

var dataSetUri = 'https://raw.githubusercontent.com/OTRF/detection-hackathon-apt29/master/datasets/day1/apt29_evals_day1_manual.zip'
var dataSetIngestionScriptUri = 'https://raw.githubusercontent.com/TheAlistairRoss/Hunting-KQLAdv/main/Scripts/IngestAPT29DataToDataCollectionEndpoint.ps1'
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

module ingestAPT29LogsDeployment 'Bicep_Modules/ingestAPT29Logs.bicep' = if (ingestAPT29Logs == true) {
  scope: resourceGroup(resourceGroupName)
  name: 'ingestAPT29Logs'
  params: {
    location:location
    dataSetUri: dataSetUri
    dataCollectionRuleImmutableId: dataCollectionDeployment.outputs.dataCollectionRuleImmutableId
    dataCollectionEndpointURI: dataCollectionDeployment.outputs.dataCollectionEndpointURI
    dataSetIngestionScriptUri: dataSetIngestionScriptUri
    applicationId: applicationId
    applicationSecret: applicationSecret
    tenantId: tenantId
  }
}

