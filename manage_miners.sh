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
	gcloud compute instance-groups managed resize instance-group-$1 --size=$2 --region="${regions[$1-1]}"
}

scale-project()
{
	usage()
	{
		echo "scale-project -u to resize all the instance-groups to 8"
		echo "scale-project -d to resize all the instance-groups to 0"
		echo "scale-project only resizes current project"
	}
	
	if [ $# -ne 1 ]; then
		usage
		return
	fi
	
	if [ "$1" == "-u" ]; then
		n=8
	elif [ "$1" == "-d" ]; then
		n=0
	else
		usage
		return
	fi
		
	for i in {1..4}
	do
		echo scale-group $i $n
	done
}
