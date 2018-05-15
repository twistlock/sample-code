# README
* installconsolek8s_tlregistry.sh deploys Twistlock console in a kubernetes cluster as a LoadBalancer or NodePort
* set for Linux, if running on macos, change 'linux' to 'osx' in script

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
  * Twistlock Console Administrative Username
  * Twistlock Console Administrative Password
  * Persistent Volume provisioning, 
    (depends on cloud provider)
