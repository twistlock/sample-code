# README
* Use the defender.yaml to create the Prisma Cloud Defender Demonset in Your GEK Cluster with CLI
* Stronge recommand to use Google Marketplace to install the defender in a more easier way.

## Install
* Update the defender.yaml with necessary information, you need to get those informations from the Prisma Cloud Console, and update the YAML file accordingly to let the defender successfuly turns up and register with the Prsima Cloud Console.
* Use: kubectl apply -f defender.yaml 
* This is to create the necessary service accounts, configmaps, and demonset to run the defender pods.

## Uninstall
* To uninstall the defender from your cluster, just run: kubectl delete -f defender.yaml
