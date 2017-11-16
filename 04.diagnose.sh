#!/bin/bash

#nodepattern=$1
mypswd=$1

# List the compute nodes running in a pool.
nodeid=`az batch node list --pool-id ilastik --account-endpoint https://matlabb.westeurope.batch.azure.com --account-name matlabb -o table | grep _1 | awk '{print $1;}'`

# List remote login connectoin
az batch node remote-login-settings show --pool-id ilastik --node-id $nodeid --account-endpoint https://matlabb.westeurope.batch.azure.com --account-name matlabb -o table

# Create the admin user
az batch node user create --is-admin --name adminuser --password $mypswd --pool-id ilastik --node-id $nodeid --account-endpoint https://matlabb.westeurope.batch.azure.com --account-name matlabb
