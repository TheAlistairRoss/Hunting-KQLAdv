param location string
param managedIdentityName string
param dataSetUri string 
param dataCollectionRuleImmutableId string 
param dataCollectionEndpointURI string 
param dataSetIngestionScriptUri string 

var scriptName = 'deployAPT29Logs'
var scriptArguements = '-DataSetUri "${dataSetUri}" -DcrImmutableId "${dataCollectionRuleImmutableId} -DceURI "${dataCollectionEndpointURI}'

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2022-01-31-preview' existing = {
  name: managedIdentityName
}

resource dataIngestionScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: scriptName
  location: location
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  properties: {
    azPowerShellVersion: '5.0'
    primaryScriptUri: dataSetIngestionScriptUri
    arguments: scriptArguements
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
    timeout: 'PT6H'
  }
}
