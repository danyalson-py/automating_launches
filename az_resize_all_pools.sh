#!/usr/bin/env bash

if [ $# -eq 0 ]
  then

	echo az_resize_all_pools.sh - a script to resize all available pools
	echo usage: ./az_resize_all_pools.sh n
	echo usage: where n is the number of desired low-priority cores.
	echo "(c) by AzureCloudMiningScript"
	echo No arguments supplied. Displaying all possible pools...
fi

subs=$(az account list --q "[].id" --o tsv)
echo Found the following subscriptions:
echo $subs

for s in $subs; do 
	echo Checking subscription $s ...
	
	accounts=$(az batch account list --q "[].name" --o tsv --s $s)
	
	echo Found the following accounts:
	echo $accounts

	for acc in $accounts; do 
		echo Checking batch-account $acc ...
		rg=$(az batch account show --n $acc --q "resourceGroup" --o tsv)
		echo ResourceGroup $rg...
		echo Logging in...
		az batch account login -g $rg -n $acc
		pools=$(az batch pool list --q "[].id" --o tsv)
		echo Found the following pools:
		echo $pools

		if [ $# -ne 0 ]
		then
			for p in $pools; do
				echo Trying to resize pool $p to $1 low priority cores...
				az batch pool resize --pool-id $p --account-name $acc --subscription $s --target-low-priority-nodes $1 --target-dedicated-nodes 0
 
			done
		fi

	done
done

