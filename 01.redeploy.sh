#!/bin/bash
# Deploy a new Batch cluster with Ubuntu 

poolid=ilastik

az batch pool create --account-name matlabb --account-endpoint https://matlabb.westeurope.batch.azure.com --id ${poolid} --image "Canonical:UbuntuServer:16.04.0-LTS" --node-agent-sku-id "batch.node.ubuntu 16.04"  --vm-size Standard_D11 --verbose

#6. Assign a json to a pool
az batch pool set --pool-id ${poolid} --json-file pool-shipyard.json --account-endpoint https://matlabb.westeurope.batch.azure.com --account-name matlabb

#7. Resize a pool
az batch pool resize --pool-id ${poolid} --target-dedicated 2 --account-endpoint https://matlabb.westeurope.batch.azure.com --account-name matlabb

#8. Remove the old pool* Remove the pool
# az batch pool delete --pool-id ilastik  --account-endpoint https://matlabb.westeurope.batch.azure.com --account-name matlabb

