# A Script to Scale all possible Pools at once
Sometimes batch-pools get stuck and don't run with the desired number of nodes. In this situation it can help to reset all pools (e.g. scale to 0 and then back to e.g. 10). You can do this for all of your pools at once with this script.

# Usage
Login to the azure-portal. Then open the azure-shell by clicking on the ">_"-icon at the top of the screen. If you have never used the shell before, you'll have to create a storage account for the shell first (just accept the default-settings and click OK). Select _bash_ as your environment. 

Once the shell has started up, enter 
> git clone https://github.com/azurecloudminingscript/automating_launches.git

to load the script into your shell.
If you cloned the repository already before and just want to update the script, enter
> git pull

Then enter
> cd automating_launches

You can start the script with 
> ./az_resize_all_pools.sh n

(replace n with the number of low-priority-nodes you want to scale to).

E.g. to scale all pools to 0, use
> ./az_resize_all_pools.sh 0

Or to scale all pools to 10 nodes, use
> ./az_resize_all_pools.sh 0

---
# WARNING: This script will resize all pools in all of your batch-accounts in all of your subscriptions! Don't run this script unless this is what you want to do!
