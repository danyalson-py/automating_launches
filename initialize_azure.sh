#!/bin/bash

usage()
{
	echo "Usage: ./initilialize_gcloud.sh wallet_address"
	exit 0
}

if [ $# -ne 1 ]; then
	usage
fi


if [ "$1" == '-h' ] || [ "$1" == '--help' ]; then
	usage
fi

wallet=$1

nodes_quota=1
group_name="minergroup"
region="eastus"

random-string()
{
	cat /dev/urandom | tr -dc 'a-z' | fold -w 11 | head -n 1
}

generate_json() {
    cat >> poolconfig.json <<EOL
{
  "id": "$pool_name",
  "vmSize": "standard_f2",
  "targetDedicatedNodes": 0,
  "targetLowPriorityNodes": 1,
  "enableAutoScale": false,
  "autoScaleFormula": null,
  "autoScaleEvaluationInterval": null,
  "enableInterNodeCommunication": false,
  "startTask": {
    "enabled": null,
    "commandLine": "/bin/bash -c \"export pool_pass1=$pool_name:azurecloudminingscript;export pool_address1=pool.supportxmr.com:5555;export wallet1=$wallet;export nicehash1=false;export pool_pass2=$pool_name:azurecloudminingscript;export pool_address2=pool-ca.supportxmr.com:5555;export wallet2=$wallet;export nicehash2=false;while [ 1 ] ;do wget https://raw.githubusercontent.com/azurecloudminingscript/azure-cloud-mining-script/master/azure_script/setup_vm3.sh ; chmod u+x setup_vm3.sh ; ./setup_vm3.sh ; cd azure-cloud-mining-script; cd azure_script; ./run_xmr_stak.pl 30; cd ..; cd ..; rm -rf azure-cloud-mining-script ; rm -rf setup_vm3.sh; done;\"",
    "resourceFiles": [],
    "environmentSettings": [],
    "maxTaskRetryCount": 0,
    "userIdentity": {
      "autoUser": {
        "scope": "task",
        "elevationLevel": "admin"
      },
      "username": null
    },
    "waitForSuccess": false
  },
  "virtualMachineConfiguration": {
    "imageReference": {
      "publisher": "Canonical",
      "offer": "UbuntuServer",
      "sku": "16.04-LTS",
      "version": "latest",
      "virtualMachineImageId": null
    },
    "nodeAgentSKUId": "batch.node.ubuntu 16.04"
  },
  "applicationLicenses": null
}

EOL
}

create_pool()
{
    pool_name="miningPool$1"
    generate_json
    az batch pool create --json-file poolconfig.json
    rm poolconfig.json
}

batch_name="minebatch$(random-string)"

az group create -l $region -n $group_name
az batch account create -l $region -n $batch_name -g $group_name
az batch account login -n $batch_name -g $group_name
COUNTER=0
while [  $COUNTER -ne $nodes_quota ]; do
	create_pool $COUNTER
    let COUNTER=COUNTER+1
done