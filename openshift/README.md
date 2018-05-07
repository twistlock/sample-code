# README
* twistlock_openshift_deploy.sh deploys Twistlock within an OpenShift cluster

## Prerequisites 
* Session is authenticated to the OpenShift cluster
* Access to OpenShift Command Line Interface (oc)
* Twistlock license

## Running it
Download the bash script to your host and replace the following values:
* TWISTLOCK_VERSION the version of Twistlock to deploy (e.g. TWISTLOCK_VERSION="2_4_95")
* TWISTLOCK_RELEASE_URL path to Twistlock release (e.g. TWISTLOCK_RELEASE_URL="https://twistlock.example.com/releases/twistlock_2_4_95.tar.gz")

After making changes run:
```
./twistlock_openshift_deploy.sh
```
You will be prompted for the following information:
* Twistlock OpenShift Project name
* Twistlock Access Token
* Twistlock License Key
* OpenShift external route FQDN for Twistlock Console access
* Twistlock Console Administrative Username
* Twistlock Console Administrative Password
* Persistent Volume provisioning, 
  * "Storage Class" = dynamic PVC
  * "Persistent Volume Labels" = static PVC
