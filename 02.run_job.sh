#!/bin/bash

prefix=ilastikjob
#suffix=$("date+%s")  # The "+%s" option to 'date' is GNU-specific.
#JOBID=$prefix_$suffix
JOBID=`date +%Y-%m-%d_%H_%M_%S`
#echo 'creating job $JOBID...'
az batch job create --id $JOBID --pool-id ilastik1 --account-endpoint https://matlabb.westeurope.batch.azure.com --account-name matlabb # 
for k in {1..2} 
  do 
    echo "starting task_$k ..."
    az batch task create --job-id $JOBID --task-id "task_$k" --command-line "/mnt/batch/tasks/shared/run_task.sh $k > out.log" --account-endpoint https://matlabb.westeurope.batch.azure.com --account-name matlabb
  done
echo "done."
