#!/bin/bash

scale-group() #requires arg or downscale to 0
{
	new_size=0
	
	if [ $# -ne 0 ]
  	then
    	new_size=$1
	fi
	
	for n in {1..4}
	do
		gcloud compute instance-groups managed resize instance-group-$n --size=$new_size
	done
}

## SOLVE ZONE ISSUE
