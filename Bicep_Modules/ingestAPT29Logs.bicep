param location string
param dataSetUri string 
param dataCollectionRuleImmutableId string 
param dataCollectionEndpointURI string 
param dataSetIngestionScriptUri string
param forceUpdateTag string = utcNow() 

param applicationId string 
param tenantId string 
@secure()
param applicationSecret string

var scriptName = 'deployAPT29Logs'
var scriptArguements = '-appId "${applicationId}" -TenantId "${tenantId}" -DataSetUri "${dataSetUri}" -DcrImmutableId "${dataCollectionRuleImmutableId} -DceURI "${dataCollectionEndpointURI}'


resource dataIngestionScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: scriptName
  location: location
  kind: 'AzurePowerShell'
  properties: {
    azPowerShellVersion: '5.0'
    primaryScriptUri: dataSetIngestionScriptUri
    arguments: scriptArguements
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
    timeout: 'PT6H'
    forceUpdateTag: forceUpdateTag
    environmentVariables:[
      {
        name: 'appSecret'
        secureValue: applicationSecret
      }
    ]
  }

}
