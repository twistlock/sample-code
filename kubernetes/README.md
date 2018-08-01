# README
* installconsolek8s_tlregistry.sh deploys Twistlock console in a kubernetes cluster as a LoadBalancer or NodePort
* set for Linux, if running on macos, change 'linux' to 'osx' in script
* gke-pv.yaml can be used as a template to provision a persistent volume in gke for a Console install, you must create a persistent disk and format it appropriately  - please chane the YOURIDENTIFIER in the yaml to something that is consistent with your naming convention for resources in your environment

## Prerequisites 
* kubectl setup to manage your kubernetes cluster
* Twistlock software downloaded and extracted, must run this script from Twistlock home folder (where twistlock.cfg file resides) 
* Twistlock access token

## Running it
* ./installconsolek8s_tlregistry.sh   without parameters shows usage
* pass in service type (LoadBalancer or NodePort) and Twistlock access token

Example  ./installconsolek8s_tlregistry.sh LoadBalancer kvbeey2clpcutdfr8rggnzgxxxxxxxxxx
  ```
  You will be prompted for the following information:
  * Persistent Volume provisioning, 
    (depends on cloud provider)
