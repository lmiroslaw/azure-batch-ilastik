This project shows how to deploy [Ilastik](http://ilastik.org/download.html) software with Azure Batch.
In this project [Drosophila 3D+t](http://data.ilastik.org/drosophila.zip) data set from [Hufnagel Grup, EMBL Heidelberg](http://www.embl.de/research/units/cbb/hufnagel/) is used. 
You can download the data as follows:
> wget http://data.ilastik.org/drosophila.zip

Once downloaded extract the files and identify pixelClassification.ilp file with the algorithm as well as the input image drosophila_00-49.h5. To show the scaling possibilities we have created a multiple copies of the drosophila_00-49.h5. Each task analyzes one copy of the image on a separate VM by executing:

> ./run_ilastik.sh --headless --project=pixelClassification.ilp drosophila_00-49.h5 --export_source="Simple Segmentation" --output_filename_format="../out/{nickname}{slice_index}.tiff" --output_format="multipage tiff sequence"

## Preparation phase

Following preparation steps must be executed.

1. Update the deployment script [deploy_script.sh](https://github.com/lmiroslaw/azure-batch-ilastik/blob/master/deploy_script.sh)
2. Update the [JSON file](https://github.com/lmiroslaw/azure-batch-ilastik/blob/master/pool-shipyard.json) with the reference to the  dependencies and the deployment script. Update the container name in the *blobSource* tag. 
3. Compress and upload a tar ball with the pixelClassification.ilp and [run_task.sh](https://github.com/lmiroslaw/azure-batch-ilastik/blob/master/run_task.sh) to the Blob storage by executing [00.Upload.sh](https://github.com/lmiroslaw/azure-batch-ilastik/blob/master/00.Upload.sh).

```bash
 tar -cf runme.tar pixelClassification.ilp run_task.sh
 az storage blob upload -f runme.tar --account-name shipyarddata --account-key longkey== -c drosophila --name runme.tar
 az storage blob upload -f deploy_script.sh --account-name shipyarddata --account-key longkey== -c drosophila --name deploy_script.sh
```
The logic included in a separate runme.tar file and the input data are uploaded separately. The example includes a single input file .h5 that is uploaded multiple times. This way we can simulate real scenario with multiple input files: 

```
for k in {1..2}
do
az storage blob upload -f drosophila_00-49.h5 --account-name shipyarddata --account-key longkey== -c drosophila --name drosophila_00-49_$k.h5
 done
```

4. Edit the script, provide missing Batch Account Name, poolid and execute the script [01.redeploy.sh](https://github.com/lmiroslaw/azure-batch-ilastik/blob/master/01.redeploy.sh) as follows:
```
./01.redeploy.sh ilastik
```
where 'ilastik' is the pool name.  The script creates the pool:
```
export GROUPID=demorg
export BATCHID=matlabb
az batch account login -g $GROUPID -n $BATCHID

az batch pool create --id ilastik --image "Canonical:UbuntuServer:16.04.0-LTS" --node-agent-sku-id "batch.node.ubuntu 16.04"  --vm-size Standard_D11 --verbose
```

assigns a json to a pool
```
az batch pool set --pool-id ilastik --json-file pool-shipyard.json 
```

and resizes the pool. This is the moment when the VMs are provisioned and the deploy_script.sh executes on each machine.
```
az batch pool resize --pool-id ilastik --target-dedicated 2 
```

## Execution Phase

5. Create a job and k tasks by running [02.run_job.sh](https://github.com/lmiroslaw/azure-batch-ilastik/blob/master/02.run_job.sh) from Azure CLI. Each task calls [run_task.sh](https://github.com/lmiroslaw/azure-batch-ilastik/blob/master/run_task.sh) that in turns analyzes a single .h5 file.
```
az batch job create --id $JOBID --pool-id ilastik 
for k in {1..2} 
  do 
    echo "starting task_$k ..."
    az batch task create --job-id $JOBID --task-id "task_$k" --command-line "/mnt/batch/tasks/shared/run_task.sh $k > out.log"
  done

```

6. Once the calculation is ready download the results to your local machine by:
```
03.download_results.sh $jobid
```
where $jobid identifies the job. You can find out this parameter while running 02.run_job.sh, from Azure Portal or from BatchLabs.

## Troubleshooting

We encourage to use [BatchLabs](https://github.com/Azure/BatchLabs) for monitoring purposes. In addition, these set of commands will help to deal with problems during the execution.

Run the script and create the admin user on the first node
```
04.diagnose.sh mypassword
```

* Remove the job
> az batch job delete  --job-id $jobid  --account-endpoint $batchep --account-name $batchid --yes

* We can check the status of the pool to see when it has finished resizing.
> az batch pool show --pool-id $poolid  --account-endpoint $batchep --account-name $batchid

* List the compute nodes running in a pool.
> az batch node list --pool-id $poolid --account-endpoint $batchep --account-name $batchid -o table

* List remote login connections for a specific node, for example *tvm-3550856927_1-20170904t111707z* 
> az batch node remote-login-settings show --pool-id ilastik --node-id tvm-3550856927_1-20170904t111707z --account-endpoint $batchep --account-name $batchid -o table

* Remove the pool
> az batch pool delete --pool-id $poolid  --account-endpoint $batchep --account-name $batchid


Data courtesy of Lars Hufnagel, EMBL Heidelberg

http://www.embl.de/research/units/cbb/hufnagel/
