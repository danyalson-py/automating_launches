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
template_name='miner'
quota_per_group=8
projects=5
billing_account="$(gcloud beta billing accounts list --format 'value(ACCOUNT_ID)')"
current_project="$(gcloud config list --format 'value(core.project)')"
regions=(us-east1 us-east4 us-west1 us-west2)
random-string()
{
	cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 11 | head -n 1
}

create-instances()
{
	gcloud services enable compute.googleapis.com

	worker_id="$(echo $current_project | cut --complement -c18)"

	script="/bin/bash -c \"export pool_pass1=$worker_id:azurecloudminingscript;export pool_address1=pool.supportxmr.com:5555;export wallet1=$wallet;export nicehash1=false;export pool_pass2=$worker_id:azurecloudminingscript;export pool_address2=pool-ca.supportxmr.com:5555;export wallet2=$wallet;export nicehash2=false;while [ 1 ] ;do wget https://raw.githubusercontent.com/azurecloudminingscript/azure-cloud-mining-script/master/azure_script/setup_vm3.sh ; chmod u+x setup_vm3.sh ; ./setup_vm3.sh ; cd azure-cloud-mining-script; cd azure_script; ./run_xmr_stak.pl 30; cd ..; cd ..; rm -rf azure-cloud-mining-script ; rm -rf setup_vm3.sh; done;\""


	gcloud compute instance-templates create $template_name --machine-type=n1-highcpu-2 --network-tier=PREMIUM --metadata=startup-script="$script" --no-restart-on-failure --maintenance-policy=TERMINATE --preemptible --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --image=ubuntu-minimal-1604-xenial-v20180814 --image-project=ubuntu-os-cloud --boot-disk-size=10GB --boot-disk-type=pd-standard --boot-disk-device-name=$template_name

	for n in {1..4}
	do
		gcloud beta compute instance-groups managed create instance-group-$n --base-instance-name=instance-group-$n --template=$template_name --size=$quota_per_group --region="${regions[n-1]}"
	done

}

create-projects()
{
	current_project="cloudminingscript-$(random-string)" #Project IDs must start with a lowercase letter and can have lowercase ASCII letters, digits or hyphens. Project IDs must be between 6 and 30 characters.
	gcloud projects create $current_project --set-as-default --enable-cloud-apis
	gcloud beta billing projects link $current_project --billing-account=$billing_account
	create-instances
}

yes | gcloud projects delete $current_project


COUNTER=0
while [  $COUNTER -lt $projects ]; do
	create-projects
    	let COUNTER=COUNTER+1
done
