#!/bin/bash
# Deploy a new Batch cluster with Ubuntu 

poolid=$1

az batch pool create --account-name matlabb --account-endpoint https://matlabb.westeurope.batch.azure.com --id ${poolid} --image "Canonical:UbuntuServer:16.04.0-LTS" --node-agent-sku-id "batch.node.ubuntu 16.04"  --vm-size Standard_D11 --verbose

# Assign a json to a pool
az batch pool set --pool-id ${poolid} --json-file pool-shipyard.json --account-endpoint https://matlabb.westeurope.batch.azure.com --account-name matlabb

# Resize a pool
az batch pool resize --pool-id ${poolid} --target-dedicated 2 --account-endpoint https://matlabb.westeurope.batch.azure.com --account-name matlabb

# Remove the old pool if necessary
# az batch pool delete --pool-id ${poolid}  --account-endpoint https://matlabb.westeurope.batch.azure.com --account-name matlabb

