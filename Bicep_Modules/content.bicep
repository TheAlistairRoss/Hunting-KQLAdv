param workspaceName string

var windowsEventFunctionProperties = {
  category: 'SentAdvHunting'
  displayName: 'fWindowsEvent'
  version: 2
  functionAlias: 'fWindowsEvent'
  query: 'WindowsEvent | extend _timestamp_ = todatetime(EventData.[\'@timestamp\']) | project-rename TimeIngested = TimeGenerated, TimeGenerated = _timestamp_'
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = {
  name: workspaceName
}

resource windowEventFunction 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  parent: logAnalyticsWorkspace
  name: windowsEventFunctionProperties.functionAlias
  properties: windowsEventFunctionProperties
}
