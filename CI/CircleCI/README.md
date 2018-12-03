# README
The example in this directory provides a yaml that will allow you to integrate Twistlocks CI scanning capabilities with hosted CircleCI.  This sample is a stub illustrating only the steps needed to build a Docker image and scan with Twistlock.
* ```/example_config.yml``` includes details on how to use twistcli when using CircleCI's hosted continuous integration service


## Prerequisite 
* Connectivity from CircleCI to your Twistlock Console
* Configured environment variables in CircleCI for required parameters:
  * ```TL_USER```:  The Twistlock user with the CI User role
  * ```TL_PASS```:  The password for this user account
  * ```TL_CONSOLE_URL```:  The base URL for the console -- http://console.<my_company>.com:8083 -- without a trailing /
