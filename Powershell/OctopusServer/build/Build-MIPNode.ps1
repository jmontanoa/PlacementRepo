## Credentials and Azure resources info:
#  LastPass => Octopus secrets
param(
    [ValidateSet(1, 2)]
    $nodeIndex = 1,
    $registryName,
    $clientId,
    $clientSecret,
    $rgName
)

Connect-AzContainerRegistry -Name $registryName `
                            -UserName $clientId `
                            -Password $clientSecret

Set-Location $PSScriptRoot\

$nodeTagName = "node$nodeIndex"

docker build . -file "dockerfile_node$nodeIndex" -t mipoctopusnode:$nodeTagName
docker image tag mipoctopusnode:$nodeTagName $registryName.azurecr.io/mipoctopusnode:$nodeTagName
docker image push $registryName.azurecr.io/mipoctopusnode:$nodeTagName


Get-AzContainerRegistry -ResourceGroupName $rgName `
                        -Name $registryName `
                        -IncludeDetail