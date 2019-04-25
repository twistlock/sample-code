# This repository is deprecrated - Twistlock supports helm natively as of the 19.03 release - please refer to Twistlock support for guidance on helm.  

This repo is maintained for historical reference only.

## Downloading the charts

Just clone this repository and install from the charts, we don't make Twistlock charts available from the Helm package repository as our product is commercial.

## Prerequisites

### Helm 

You will need [Helm](https://helm.sh/) installed (both the Helm client locally and the Tiller server component) on your Kubernetes cluster. 

### Secrets

You will need the access token that comes with your Twistlock subscription; look for this in an e-mail from Twistlock support.

## Installing the Helm chart

First copy twistlock/valuesTemplate.xml twistlock/values.xml 
and fill in version, image tag, imageName, and  access token in twistlock/values.xml.

Now run:

	$ helm install ./twistlock
	
## Configure and setup your Twistlock Console

You can see your console external IP address with:

	kubectl get service -n twistlock
	
Log into your console via a browser - https://<CONSOLE_EXTERNAL_IP>:8083, create an admin account, and install your license.  

## Installing the Twistlock Defender DS

The Helm chart installs the Twistlock console only.  

To complete the Twistlock install, you will need to deploy the Twistlock Defender Daemonset. Please see Twistlock docs for this - search for **defender daemonset kubernetes**.  Or go directly to the support documentation [here.](https://docs.twistlock.com/docs/latest/install/install_kubernetes.html#_install_defender)
