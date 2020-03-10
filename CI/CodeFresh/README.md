# README
The example in this directory provides yaml to integrate Prisma Cloud's CI scanning capabilities with hosted Codefresh.  This sample is a stub illustrating only the steps needed to build a Docker image and scan with twistcli.
* ```/codefresh.yml``` includes details on how to use twistcli when using CodeFresh


## Prerequisites 
* Connectivity from Codefresh to your Prisma Cloud Console
* Environment variables set in Codefresh for required parameters:
  * ```TL_USER```:  The Twistlock user with the CI User role
  * ```TL_PASS```:  The password for this user account
  * ```TL_CONSOLE_URL```:  The base URL for the console -- https://console.<my_company>.com:8083 -- without a trailing /
* ```curl``` must be present in the built image at scanning time
