# README
* twistlock_openshift_deploy.sh deploys Twistlock within an OpenShift cluster
* tl-ose-registry-populator.ps1 configures Twistlock's registry scanner for the OpenShift Internal Registry

## Prerequisites 
* Session is authenticated to the OpenShift cluster
* Access to OpenShift Command Line Interface (oc)
* Twistlock v2.5 and license
* For the tl-ose-registry-populator.ps1 script you will need Powersell v6 https://blogs.msdn.microsoft.com/powershell/2018/01/10/powershell-core-6-0-generally-available-ga-and-supported/

## Running it
Twistlock_openshift_deploy.sh
* Download the bash script to your host and replace the following values:
  * TWISTLOCK_VERSION the version of Twistlock to deploy (e.g. TWISTLOCK_VERSION="2_5_99")
  * TWISTLOCK_RELEASE_URL path to Twistlock release (e.g. TWISTLOCK_RELEASE_URL="https://twistlock.example.com/releases/twistlock_2_5_99.tar.gz")

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

tl-ose-registry-populator.ps1
* Download the powershell script and replace the following values: 
  * $twistlock_API - endpoint of the Twistlock API
  * $TL_service_account_password - Twistlock Service Account password. See notes within the script on how to get the password

  After making the changes:
  ```
  ./tl-ose-registry-populator.ps1
  ```
