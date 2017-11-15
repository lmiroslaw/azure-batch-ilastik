#!/bin/bash

JOBID=2017-11-14_14_52_02
#filename=drosophila_00-4900.tiff
filename=drosophila_00-490

#for j in {1..2}; do
	for k in {1..3}; do
	  echo "Downloading ${k} tiff results..."
	  az batch task file download --job-id $JOBID --task-id task_${k} --file-path wd/${filename}${k}.tiff --destination ~/ilastikresults/${filename} --account-endpoint https://matlabb.westeurope.batch.azure.com --account-name matlabb
	 done
#done	 
echo "done."

#AZ_BATCH_NODE_SHARED_DIR
