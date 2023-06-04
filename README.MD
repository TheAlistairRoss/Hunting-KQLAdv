# Advanced Hunting Workshop

1. Create an App Registration with a secret. Note down the following
    1. Application Id
    1. Application Tenant Id
    1. Application Secret Value
    1. Enterprise Object Id of the Application


2. Deploy the following template to Azure. Ensure you enter all the parameters. If using any existing resources, ensure they are all in the same resource group, location and their names are entered in the paramter field.

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FTheAlistairRoss%2FHunting-KQLAdv%2Fmain%2Fazuredeploy.json
)

3. Once completed, get the following from the script output
    1. Data Collection Rule Immutable Id
    1. Data Collection Endpoint Uri

4. Update the following code with the relevant parameters already collection

```azurepowershell
$IngestAPT29DataToDataCollectionEndpointParams = @{
    DataSetUri = "https://raw.githubusercontent.com/OTRF/detection-hackathon-apt29/master/datasets/day1/apt29_evals_day1_manual.zip"
    DceURI = ""
    DcrImmutableId = ""
    appId = ""
    TenantId = ""
    appSecret = ""
}

$scriptUri = "https://raw.githubusercontent.com/TheAlistairRoss/Hunting-KQLAdv/main/Scripts/IngestAPT29DataToDataCollectionEndpoint.ps1"
$scriptName = "IngestAPT29DataToDataCollectionEndpoint.ps1"
Invoke-RestMethod -Uri $scriptUri | Out-File $scriptName

.\IngestAPT29DataToDataCollectionEndpoint.ps1 @IngestAPT29DataToDataCollectionEndpointParams -ShowProgressBar
```

5. The script should run automatically. It will take apporximatly an hour.