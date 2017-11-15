#Preparation phase

## 1. Create a deployment script deploy_script.sh

## 2. Create a JSON file with declarations to dependencies and deployment script 
## 3. Create drosophila.zip file with pixelClassification.ilp and run_task.sh
## 4. Compress and upload a tar ball with  pixelClassification.ilp and run_task.sh to the Blob storage
az storage blob upload -f drosophila.zip --account-name shipyarddata --account-key longkey== -c drosophila --name drosophila.zip

az storage blob upload -f deploy_script.sh --account-name shipyarddata --account-key longkey== -c drosophila --name deploy_script.sh

## 5. Create a pool
az batch pool create --account-name matlabb --account-endpoint https://matlabb.westeurope.batch.azure.com --id ilastik --image "Canonical:UbuntuServer:16.04.0-LTS" --node-agent-sku-id "batch.node.ubuntu 16.04"  --vm-size Standard_D11 --verbose

## 6. Assign a json to a pool
 az batch pool set --pool-id ilastik --json-file pool-shipyard.json --account-endpoint https://matlabb.westeurope.batch.azure.com --account-name matlabb

## 7. Resize a pool
az batch pool resize --pool-id ilastik --target-dedicated 2 --account-endpoint https://matlabb.westeurope.batch.azure.com --account-name matlabb

OR 
az batch pool resize --pool-id ilastik0 --target-dedicated 0 --target-low-priority-nodes 2  --account-endpoint https://matlabb.westeurope.batch.azure.com --account-name matlabb

## 8. Create a job and create tasks by running 02.run_job.sh from Azure CLI

# Execution script
wget https://shipyarddata.blob.core.windows.net/drosophila/drosophila_00-49_9.h5
cd ilastik-1.*-Linux
./run_ilastik.sh --headless --project=../pixelClassification.ilp ../drosophila_00-49_9.h5 --export_source="Simple Segmentation" --output_filename_format="../out/{nickname}{slice_index}.tiff" --output_format="multipage tiff sequence" > log.out

## Copy files to  blob storage

## Create run_job : create a loop with a set of tasks that call run_task.sh from the command line
Note: run_task.sh is a part of a zip file with the app

## Create run_task.sh that downloads input file from blob storage and executes run_ilastik 
 
## Remove the job
 az batch job delete  --job-id ilastikjob-1504088397  --account-endpoint https://matlabb.westeurope.batch.azure.com --account-name matlabb --account-endpoint https://matlabb.westeurope.batch.azure.com --account-name matlabb --yes

## We can check the status of the pool to see when it has finished resizing.
az batch pool show --pool-id ilastik  --account-endpoint https://matlabb.westeurope.batch.azure.com --account-name matlabb

## List the compute nodes running in a pool.
az batch node list --pool-id ilastik --account-endpoint https://matlabb.westeurope.batch.azure.com --account-name matlabb -o table

## List remote login connectoin
az batch node remote-login-settings show --pool-id ilastik --node-id tvm-3550856927_1-20170904t111707z --account-endpoint https://matlabb.westeurope.batch.azure.com --account-name matlabb -o table

## Create the admin user
az batch node user create --is-admin --name adminuser --password Azure@123456 --pool-id ilastik --node-id tvm-3550856927_1-20170904t111707z --account-endpoint https://matlabb.westeurope.batch.azure.com --account-name matlabb
