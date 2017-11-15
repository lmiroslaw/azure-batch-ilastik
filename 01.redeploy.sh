#!/bin/bash

#az batch pool delete --pool-id ilastik  --account-endpoint https://matlabb.westeurope.batch.azure.com --account-name matlabb

az batch pool create --account-name matlabb --account-endpoint https://matlabb.westeurope.batch.azure.com --id ilastik1 --image "Canonical:UbuntuServer:16.04.0-LTS" --node-agent-sku-id "batch.node.ubuntu 16.04"  --vm-size Standard_D11 --verbose

#6. Assign a json to a pool
az batch pool set --pool-id ilastik1 --json-file pool-shipyard.json --account-endpoint https://matlabb.westeurope.batch.azure.com --account-name matlabb

#7. Resize a pool
az batch pool resize --pool-id ilastik1 --target-dedicated 2 --account-endpoint https://matlabb.westeurope.batch.azure.com --account-name matlabb

