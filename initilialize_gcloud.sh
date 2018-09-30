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


script="/bin/bash -c \"export pool_pass1=$current_project:azurecloudminingscript;export pool_address1=pool.supportxmr.com:5555;export wallet1=$1;export nicehash1=false;export pool_pass2=$current_project:azurecloudminingscript;export pool_address2=pool-ca.supportxmr.com:5555;export wallet2=$1;export nicehash2=false;while [ 1 ] ;do wget https://raw.githubusercontent.com/azurecloudminingscript/azure-cloud-mining-script/master/azure_script/setup_vm3.sh ; chmod u+x setup_vm3.sh ; ./setup_vm3.sh ; cd azure-cloud-mining-script; cd azure_script; ./run_xmr_stak.pl 30; cd ..; cd ..; rm -rf azure-cloud-mining-script ; rm -rf setup_vm3.sh; done;\""
template_name='miner'
quota_per_group=8
billing_account="$(gcloud beta billing accounts list | sed -n 2p | head -n1 | awk '{print $1;}')"
projects=5

random-string()
{
	cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 12 | head -n 1
}

create-instances()
{
	gcloud services enable compute.googleapis.com
	
	gcloud compute instance-templates create $template_name --machine-type=n1-highcpu-2 --network-tier=PREMIUM --metadata=startup-script="$script" --no-restart-on-failure --maintenance-policy=TERMINATE --preemptible --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --image=ubuntu-minimal-1604-xenial-v20180814 --image-project=ubuntu-os-cloud --boot-disk-size=10GB --boot-disk-type=pd-standard --boot-disk-device-name=$template_name
	
	gcloud beta compute instance-groups managed create instance-group-1 --base-instance-name=instance-group-1 --template=$template_name --size=$quota_per_group --zones=us-east1-b,us-east1-c,us-east1-d
	gcloud beta compute instance-groups managed create instance-group-2 --base-instance-name=instance-group-2 --template=$template_name --size=$quota_per_group --zones=us-east4-a,us-east4-b,us-east4-c 
	gcloud beta compute instance-groups managed create instance-group-3 --base-instance-name=instance-group-3 --template=$template_name --size=$quota_per_group --zones=us-west1-a,us-west1-b,us-west1-c 
	gcloud beta compute instance-groups managed create instance-group-4 --base-instance-name=instance-group-4 --template=$template_name --size=$quota_per_group --zones=us-west2-c,us-west2-b,us-west2-a 

}

create-projects()
{
	current_project="cloudMiningScript$(random-string)" #string needs to start with a lowercase letter
	gcloud projects create $current_project --set-as-default --enable-cloud-apis
	gcloud beta billing projects link $current_project --billing-account=$billing_account
	create-instances
}


project_id="$(gcloud beta projects list | sed -n 2p | head -n1 | awk '{print $1;}')"
yes | gcloud projects delete $project_id


COUNTER=0
while [  $COUNTER -lt $projects ]; do
	create-projects
    	let COUNTER=COUNTER+1
done
