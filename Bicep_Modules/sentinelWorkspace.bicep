param sentinelWorkspaceName string
param location string = resourceGroup().location

var sentinelSolutionName = 'SecurityInsights(${sentinelWorkspaceName})'

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: sentinelWorkspaceName
  location: location
}

resource sentinelSolution 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = {
  name: sentinelSolutionName
  location: location
  plan: {
    name: sentinelSolutionName
    publisher: 'Microsoft'
    promotionCode: ''
    product: 'OMSGallery/SecurityInsights'
  }
  properties: {
    workspaceResourceId: logAnalyticsWorkspace.id
  }
}
