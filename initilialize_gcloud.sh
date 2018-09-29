#!/bin/bash

script='' #variable containing the start-up script used in the instance-templates
template_name='default' #must be a match of regex
quota_per_group= #integer of how many instances each group will be created. for upgraded users, the quota is group 8 instances (there's also a quota for 64 vcpus max), for free users the quota of vcpus per project is 8, and every project launches dual-core instances.
projects= #integer with number of projects that'll be created

billing_account="$(gcloud beta billing accounts list | tail -c 47 | head -c 20)" #extracts the user billing account id, it's necessary to link every new project with a billing account

random-string()
{
    cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 29 | head -n 1
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
	current_project="a$(random-string)"
    gcloud projects create $current_project --set-as-default --enable-cloud-apis
    gcloud beta billing projects link $current_project --billing-account=$billing_account
    create-instances
}


project_id="$(gcloud beta projects list | sed -n 2p | head -n1 | awk '{print $1;}')" #takes the first project id (created by google) so it can be deleted
yes | gcloud projects delete $project_id


COUNTER=0
while [  $COUNTER -lt $projects ]; do
	create-projects
    let COUNTER=COUNTER+1
done