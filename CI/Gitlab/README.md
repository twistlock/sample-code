# README
The example in this directory provides an example gitlab-ci yaml that will allow you to integrate Twistlocks CI scanning capabilities with Gitlab Pipeline.  This sample is a stub illustrating only the steps needed to build a Docker image and scan with Twistlock.
* ```/.gitlab-ci.yml``` includes details on how to use twistcli when using Gitlab Pipelines


## Prerequisite
* Configured environment variables in Gitlab CI/CD Settings for required parameters:
  * ```address```:  The Twistlock Console URL http://console.<my_company>.com:8083 -- without a trailing /
  * ```compthreshold```:  The compliance severity threshold used for compliance checks (low, medium, high or critical)
  * ```vulnthreshold```:  The vulnerability severity threshold used for vulnerability checks (low, medium, high or critical)
  * ```graceperiod```:  The grace period defined for new CVEs detected.
  * ```username```:  The username used to connect to the Twistlock Console. Make sure it has at least the ci-user role.
  * ```password```:  The password for the username used to connect to the Twistlock Console.
