#!/bin/bash
workspace=`pwd`/tozip
echo $workspace
cd $workspace
tar -cf runme.tar pixelClassification.ilp run_task.sh
echo "Uploading"
az storage blob upload -f runme.tar --account-name shipyarddata --account-key O3SgBchy4x4Ms1UDDpSpeHVy+G9Ah2IWanRHppyJaQoUG3aPOTP9q+AcW0YfyZA/KEtyYnsLjQEG5yk9PYZilQ== -c drosophila --name runme.tar
cd ..
echo "Uploading"
az storage blob upload -f deploy_script.sh --account-name shipyarddata --account-key O3SgBchy4x4Ms1UDDpSpeHVy+G9Ah2IWanRHppyJaQoUG3aPOTP9q+AcW0YfyZA/KEtyYnsLjQEG5yk9PYZilQ== -c drosophila --name deploy_script.sh
