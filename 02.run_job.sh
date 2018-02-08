#!/bin/bash

JOBID=`date +%Y-%m-%d_%H_%M`
export GROUPID=demorg
export BATCHID=matlabb
az batch account login -g $GROUPID -n $BATCHID

echo 'creating job $JOBID...'
az batch job create --id $JOBID --pool-id ilastik  
for k in {1..2} 
  do 
    echo "starting task_$k ..."
    az batch task create --job-id $JOBID --task-id "task_$k" --command-line "/mnt/batch/tasks/shared/run_task.sh $k > out.log" 
  done
echo "DONE. JOBID=${JOBID} executed."
