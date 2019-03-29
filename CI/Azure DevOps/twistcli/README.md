# README
The example in this directory provides a yaml that will allow you to integrate Twistlocks CI scanning capabilities with Azure DevOps build pipelines.  This sample is a stub illustrating only the steps needed to build a Docker image and scan with Twistlock.
* ```/sample_pipeline.yml``` includes details on how to use twistcli in an Azure DevOps build pipeline


## Prerequisite 
* Connectivity from Azure DevOps to your Twistlock Console
* A Linux-based build agent such as "Hosted Ubuntu 1604"
* Configured environment variables for required parameters:
  * ```TL_USER```:  The Twistlock user with the CI User role
  * ```TL_PASS```:  The password for this user account
  * ```TL_CONSOLE_URL```:  The base URL for the console -- http://console.<my_company>.com:8083 -- without a trailing /
