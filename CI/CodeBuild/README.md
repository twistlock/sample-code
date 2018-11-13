# README
The example in this directory provides a yaml that will allow you to integrate Twistlocks CI scanning capabilities with AWS CodeBuild.  This sample is a stub illustrating only the steps needed to build a Docker image and scan with Twistlock.
* ```/buildspec.yml``` includes details on how to use twistcli when using AWS CodeBuild


## Prerequisite 
* Connectivity from CodeBuild to your Twistlock Console
* Configured environment variables in CodeBuild for required parameters:
  * ```TL_USER```:  The Twistlock user with the CI User role
  * ```TL_PASS```:  The password for this user account
  * ```TL_CONSOLE_URL```:  The base URL for the console -- http://console.<my_company>.com:8083 -- without a trailing /
