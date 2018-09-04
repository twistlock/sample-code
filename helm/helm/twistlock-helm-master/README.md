# Helm chart for installing Twistlock Console into Kubernetes 

## Downloading the charts

Just clone this repository and install from the charts, we don't make Twistlock charts available from the Helm package repository
as our product is private

## Prerequisites

### Helm 

You will need [Helm](https://helm.sh/) installed (both the Helm client locally and the Tiller server component on your Kubernetes cluster). 

### Secrets

You will need the access token that comes with your Twistlock subscription, look for this in an e-mail from Twistlock support

## Installing the Helm chart

First copy twistlock/valuesTemplate.xml twistlock/values.xml 
and fill in version, image tag, imageName, and  access token in twistlock/values.xml
if you want to use your own private registry, you need to obtain Twistlock console image from twistlock_console.tar.gz
tag and push it to your private registry and then set imageName appropriately

then run:

$ helm install ./twistlock

## Installing the Twistlock Defender DS

The Helm chart installs the Twistlock console only. 

You will also need to install the Twistlock defender daemonset on your cluster. Please see Twistlock docs for this - 
search for defender daemonset.

