#!/bin/bash

regions=(us-east1 us-east4 us-west1 us-west2)

scale-group()
{
	if [ $# -ne 2 ]
  	then
  		echo "scale-group arg1 arg2"
    	echo "arg1 = instance-group number"
    	echo "arg2 = new size"
    	return
	fi
	gcloud compute instance-groups managed resize instance-group-$1 --size=$2 --region="${regions[1-1]}"
}
