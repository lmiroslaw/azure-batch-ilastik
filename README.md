# azure-batch-ilastik
Running Ilastik on Azure Batch


# Preparation steps. Executed just once.

##Uploading input files
az storage blob upload -c drosophila -f ./deploy_script.sh deploy_script.sh --account-name shippyard --account-key longpassword==

## Create a batch service
az batch account create -g demorg -n matlabb --location westeurope
az batch account show -g demorg -n matlabb 

## Create a pool
az batch pool create --account-name matlabb --account-endpoint https://matlabb.westeurope.batch.azure.com --id ilastik --image "Canonical:UbuntuServer:16.04.0-LTS" --node-agent-sku-id "batch.node.ubuntu 16.04"  --vm-size Standard_A4 --verbose
 
## Set the json file
### The app will be installed in /mnt/batch/tasks/shared  
 az batch pool set --pool-id ilastik --json-file pool-shipyard.json --account-endpoint https://matlabb.westeurope.batch.azure.com --account-name matlabb

 
## Resize the pool
az batch pool resize --pool-id ilastik --target-dedicated 2 --account-endpoint https://matlabb.westeurope.batch.azure.com --account-name matlabb 

## Execute the 02.run_job.sh script to create a job and tasks
## Execute the 03.download_output.sh script to download the results

## Delete the pool after the calculations are finished
az batch pool delete --pool-id ilastik -y 

# TROUBLESHOOTING

If a particular node in the pool is having issues, it can be rebooted or reimaged.
The ID of the node can be retrieved with the list command below.
A typical node ID will be in the format 'tvm-xxxxxxxxxx_1-<timestamp>'.

Example:
az batch node reboot --pool-id ilastik --node-id tvm-123_1-20170316t000000z --account-endpoint https://matlabb.westeurope.batch.azure.com --account-name matlabb

Alternatively, you may want to login to the node and troubleshoot as a local admin user.

## List the compute nodes running in a pool and select the node you want to log in to.
az batch node list --pool-id ilastik --account-endpoint https://matlabb.westeurope.batch.azure.com --account-name matlabb

## List remote login connectoin
az batch node remote-login-settings show --pool-id ilastik --node-id tvm-xxxxxxxxxx_1-<timestamp> --account-endpoint https://matlabb.westeurope.batch.azure.com --account-name matlabb -o table

## Create the admin user
az batch node user create --is-admin --name adminuser --password Azure@123456 --pool-id ilastik --node-id tvm-xxxxxxxxxx_1-<timestamp> --account-endpoint https://matlabb.westeurope.batch.azure.com --account-name matlabb
