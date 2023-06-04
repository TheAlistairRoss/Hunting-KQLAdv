param workspaceName string

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-08-01' existing = {
  name: workspaceName
}

resource windowEventFunction 'Microsoft.OperationalInsights/workspaces/savedSearches@2020-08-01' = {
  parent: logAnalyticsWorkspace
  name: 'fWindowsEvent'
  properties: {
    etag: '*'
    category: 'SentAdvHunting'
    displayName: 'fWindowsEvent'
    version: 2
    functionAlias: 'fWindowsEvent'
    query: 'WindowsEvent | extend _timestamp_ = todatetime(EventData.[\'@timestamp\']) | project-rename TimeIngested = TimeGenerated, TimeGenerated = _timestamp_'
  }
}

