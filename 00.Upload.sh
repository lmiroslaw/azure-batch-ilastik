#!/bin/bash
workspace=`pwd`/tozip
echo $workspace
cd $workspace
tar -cf runme.tar pixelClassification.ilp run_task.sh
echo "Uploading"
az storage blob upload -f runme.tar --account-name shipyarddata --account-key longkey== -c drosophila --name runme.tar
cd ..
echo "Uploading"
az storage blob upload -f deploy_script.sh --account-name shipyarddata --account-key longkey== -c drosophila --name deploy_script.sh
