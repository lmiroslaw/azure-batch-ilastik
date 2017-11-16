This project shows how to deploy [Ilastik](http://ilastik.org/download.html) software with Azure Batch.
In this project [Drosophila 3D+t](http://data.ilastik.org/drosophila.zip) data set from [Hufnagel Grup, EMBL Heidelberg](http://www.embl.de/research/units/cbb/hufnagel/) is used. 
We assume this data set has been copied to Azure Blob Storage.

## Preparation phase

Following preparation steps must be executed.

1. Create a deployment script [deploy_script.sh](https://github.com/lmiroslaw/azure-batch-ilastik/blob/master/deploy_script.sh)

2. Create a JSON file with declarations to dependencies and deployment script 
3. Compress and upload a tar ball with  pixelClassification.ilp and run_task.sh to the Blob storage (see 00.Upload.sh)

>tar -cf runme.tar pixelClassification.ilp run_task.sh
>az storage blob upload -f runme.tar --account-name shipyarddata --account-key longkey== -c drosophila --name drosophila.zip
>az storage blob upload -f deploy_script.sh --account-name shipyarddata --account-key longkey== -c drosophila --name deploy_script.sh

4. Create a pool named 'ilastik'
>az batch pool create --account-name matlabb --account-endpoint https://matlabb.westeurope.batch.azure.com --id ilastik --image "Canonical:UbuntuServer:16.04.0-LTS" --node-agent-sku-id "batch.node.ubuntu 16.04"  --vm-size Standard_D11 --verbose

5. Assign a json to a pool
>az batch pool set --pool-id ilastik --json-file pool-shipyard.json --account-endpoint https://matlabb.westeurope.batch.azure.com --account-name matlabb

6. Resize a pool
>az batch pool resize --pool-id ilastik --target-dedicated 2 --account-endpoint https://matlabb.westeurope.batch.azure.com --account-name matlabb

OR execute 
> 01.redeploy.sh ilastik

7. Create a job and tasks by running 02.run_job.sh from Azure CLI. Each task analyzes one .h5 file.
> 02.run_job.sh

## Troubleshooting

These set of commands will help to deal with problems during the execution.

* Remove the job
> az batch job delete  --job-id ilastikjob-1504088397  --account-endpoint https://matlabb.westeurope.batch.azure.com --account-name matlabb --account-endpoint https://matlabb.westeurope.batch.azure.com --account-name matlabb --yes

* We can check the status of the pool to see when it has finished resizing.
> az batch pool show --pool-id ilastik  --account-endpoint https://matlabb.westeurope.batch.azure.com --account-name matlabb

* List the compute nodes running in a pool.
> az batch node list --pool-id ilastik --account-endpoint https://matlabb.westeurope.batch.azure.com --account-name matlabb -o table

* List remote login connectoin
> az batch node remote-login-settings show --pool-id ilastik --node-id tvm-3550856927_1-20170904t111707z --account-endpoint https://matlabb.westeurope.batch.azure.com --account-name matlabb -o table

* Create the admin user
> az batch node user create --is-admin --name adminuser --password Azure@123456 --pool-id ilastik --node-id tvm-3550856927_1-20170904t111707z --account-endpoint https://matlabb.westeurope.batch.azure.com --account-name matlabb

* Remove the pool
> az batch pool delete --pool-id ilastik  --account-endpoint https://matlabb.westeurope.batch.azure.com --account-name matlabb