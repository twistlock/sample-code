# README
The example in this directory provides a build script to build a Docker image to allow one to scan
other images with the twistcli images scan utility.

## STEPS:
1. Make sure you have provisioned a Twistlock console available from this server.
2. Add a low privileged user to your Twistlock console with ci privileges. 
3. Copy template-setupEnv to setupEnv and edit it with proper values for env variables. 

## NOTES:

To see usage of container with twistcli images scan usage, run testUsage
To see an example of how to run the container, see testScan

testRun script shows how to run the container to do an actual scan of an image using
thresholds to fail a build based on vulnerabilities or compliance violations.

twistcli images scan with thresholds will return non-zero if there are vulns or
compliance issues of given threshold.

image scans completed with twistcli will get pushed to console and be available at 
Monitor -> Vulnerabilities -> twistcli


## Prerequisite 
* Connectivity to your Twistlock Console
* Image is local to where container is running
* Docker is installed on host

