This project shows how to deploy [Ilastik](http://ilastik.org/download.html) software with Azure Batch.
In this project [Drosophila 3D+t](http://data.ilastik.org/drosophila.zip) data set from [Hufnagel Grup, EMBL Heidelberg](http://www.embl.de/research/units/cbb/hufnagel/) is used. 
You can download the data as follows:
> wget http://data.ilastik.org/drosophila.zip

To show the scaling possibilities we have created a multiple copies of the drosophila_00-49.h5 file. Each task analyzes one copy of the file as follows:

> ./run_ilastik.sh --headless --project=pixelClassification.ilp drosophila_00-49.h5 --export_source="Simple Segmentation" --output_filename_format="../out/{nickname}{slice_index}.tiff" --output_format="multipage tiff sequence"

## Preparation phase

Following preparation steps must be executed.

1. Create a deployment script [deploy_script.sh](https://github.com/lmiroslaw/azure-batch-ilastik/blob/master/deploy_script.sh)

2. Create a [JSON file](https://github.com/lmiroslaw/azure-batch-ilastik/blob/master/pool-shipyard.json) with declarations of the compressed dependencies and the deployment script 
3. Compress and upload a tar ball with  pixelClassification.ilp and [run_task.sh](https://github.com/lmiroslaw/azure-batch-ilastik/blob/master/run_task.sh) to the Blob storage (see [00.Upload.sh](https://github.com/lmiroslaw/azure-batch-ilastik/blob/master/00.Upload.sh))

```bash
 tar -cf runme.tar pixelClassification.ilp run_task.sh
 az storage blob upload -f runme.tar --account-name shipyarddata --account-key longkey== -c drosophila --name runme.tar
 az storage blob upload -f deploy_script.sh --account-name shipyarddata --account-key longkey== -c drosophila --name deploy_script.sh
 az storage blob upload -f drosophila_00-49.h5 --account-name shipyarddata --account-key longkey== -c drosophila --name drosophila_00-49.h5 
```
The logic included in a separate runme.tar file and the input data are uploaded separately. The example includes a single input file .h5 that is downloaded to every VM in a cluster for the analysis. In reality there would be more input files.  

4. Create a pool named 'ilastik' in the existing batch account
```
export GROUPID=demorg
export BATCHID=matlabb
az batch account login -g $GROUPID -n $BATCHID

az batch pool create --id ilastik --image "Canonical:UbuntuServer:16.04.0-LTS" --node-agent-sku-id "batch.node.ubuntu 16.04"  --vm-size Standard_D11 --verbose
```

5. Assign a json to a pool
```
az batch pool set --pool-id ilastik --json-file pool-shipyard.json 
```

6. Resize a pool. This is the moment when the VMs are provisioned and the deploy_script.sh executes on each machine.
```
az batch pool resize --pool-id ilastik --target-dedicated 2 
```
Steps 4-6 are also implemented in:  

```
01.redeploy.sh ilastik
```

## Execution Phase

7. Create a job and k tasks by running [02.run_job.sh](https://github.com/lmiroslaw/azure-batch-ilastik/blob/master/02.run_job.sh) from Azure CLI. Each task calls [run_task.sh](https://github.com/lmiroslaw/azure-batch-ilastik/blob/master/run_task.sh) that in turns analyzes a single .h5 file.
```
az batch job create --id $JOBID --pool-id ilastik 
for k in {1..2} 
  do 
    echo "starting task_$k ..."
    az batch task create --job-id $JOBID --task-id "task_$k" --command-line "/mnt/batch/tasks/shared/run_task.sh $k > out.log"
  done

```

8. Once the calculation is ready download the results to your local machine by:
```
03.download_results.sh
```

## Troubleshooting

These set of commands will help to deal with problems during the execution.

Run the script and create the admin user on the first node
```
04.diagnose.sh mypassword
```

* Remove the job
> az batch job delete  --job-id ilastikjob-1504088397  --account-endpoint https://matlabb.westeurope.batch.azure.com --account-name matlabb --account-endpoint https://matlabb.westeurope.batch.azure.com --account-name matlabb --yes

* We can check the status of the pool to see when it has finished resizing.
> az batch pool show --pool-id ilastik  --account-endpoint https://matlabb.westeurope.batch.azure.com --account-name matlabb

* List the compute nodes running in a pool.
> az batch node list --pool-id ilastik --account-endpoint https://matlabb.westeurope.batch.azure.com --account-name matlabb -o table

* List remote login connectoin
> az batch node remote-login-settings show --pool-id ilastik --node-id tvm-3550856927_1-20170904t111707z --account-endpoint https://matlabb.westeurope.batch.azure.com --account-name matlabb -o table

* Remove the pool
> az batch pool delete --pool-id ilastik  --account-endpoint https://matlabb.westeurope.batch.azure.com --account-name matlabb


Data courtesy of Lars Hufnagel, EMBL Heidelberg

http://www.embl.de/research/units/cbb/hufnagel/
