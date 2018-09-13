# Helm chart for installing Twistlock Console into Kubernetes 

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

## Installing the Twistlock Defender DS

The Helm chart installs the Twistlock console only.  Once installed, you will need to log into your console via a browser, create an admin account and install your license.

You will also then to install the Twistlock defender daemonset on your cluster. Please see Twistlock docs for this - search for **defender daemonset kubernetes**.  Or go directly to the support documentation [here.](https://docs.twistlock.com/docs/latest/install/install_kubernetes.html#_install_defender)
