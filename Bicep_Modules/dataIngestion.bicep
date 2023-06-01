param location string
param managedIdentityName string

var scriptName = 'deployAPT29Logs'
var scriptLocation = ''
var dataLocation = 'https://raw.githubusercontent.com/OTRF/detection-hackathon-apt29/master/datasets/day1/apt29_evals_day1_manual.zip'
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
    primaryScriptUri: scriptLocation
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
    timeout: 'PT6H'
  }
}
