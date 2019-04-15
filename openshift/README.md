# README
* twistlock_openshift_deploy.sh deploys Twistlock within an OpenShift cluster
* Scanning_Internal_OSE_Registry directory contains a powershell script and compiled GOLang application (Linux, OSX & Windows) for configuring Twistlock to scan the internal OpenShift registry

## Deploy Twistlock within an OpenShift cluster

### Prerequisites
* Session is authenticated to the OpenShift cluster
* Access to OpenShift Command Line Interface (oc)
* Twistlock v2.5+ and license

### Running it
Twistlock_openshift_deploy.sh
* Download the bash script to your host and replace the following values:
  * TWISTLOCK_VERSION the version of Twistlock to deploy (e.g. TWISTLOCK_VERSION="19_03_317")
  * TWISTLOCK_RELEASE_URL path to Twistlock release (e.g. TWISTLOCK_RELEASE_URL="https://twistlock.example.com/releases/twistlock_19_03_317.tar.gz")

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
