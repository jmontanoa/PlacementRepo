Connect-AzContainerRegistry -Name "${registry_name}" `
                            -UserName "${client_id}" `
                            -Password "${client_secret}"

Set-Location $PSScriptRoot\

docker login azure --client-id "${client_id}" `
                   --client-secret "${client_secret}" `
                   --tenant-id "${tenant_id}"

docker context create aci octopusdeploy --location "${location}" `
                                        --resource-group "${rg_name}" `
                                        --subscription-id "${subscription_id}"

docker context use octopusdeploy
docker compose up
docker ps
docker logs octopus1
docker logs octopus2

# Connect-AzContainerRegistry -Name "mipdevregistryops" `
#                             -UserName "" `
#                             -Password ""

# Set-Location $PSScriptRoot\

# docker login azure --client-id "" `
#                    --client-secret "" `
#                    --tenant-id ""

# docker context create aci octopusdeploy --location "eastus" `
#                                         --resource-group "dev.mip.com-eastus-devops" `
#                                         --subscription-id ""

# docker context use octopusdeploy
# docker compose up
# docker logs octopus1
# docker logs octopus2