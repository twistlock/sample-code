# Helm Chart for Twistlock Console 


## Downloading the charts

Just clone this repository and install from the charts, we don't make Twistlock charts available from the Helm package repository as our product is commercial.

## Prerequisites

### Helm 

You will need [Helm](https://helm.sh/) installed (both the Helm client locally and the Tiller server component) on your Kubernetes cluster. 

### Secrets

You will need the access token that comes with your Twistlock subscription; look for this in an e-mail from Twistlock support.

## Installing the Helm chart

* First copy twistlock_console/valuesTemplate.xml twistlock_console/values.xml 
and fill in version, image tag, imageName, and  access token in twistlock_console/values.yaml.

* Review settings in twistlock-console/charts/console/values.yaml - change as desired.  Persistent volume size of **50GB** is recommended for larger production environments, **10GB** is sufficient for a trial or smaller deployment (less than 10 defenders).

Now run:

	$ helm install twistlock-console -n twistlock-console --namespace=twistlock

	
## Configure and setup your Twistlock Console

NOTE: console https port defaults to 8083, if you changed it, use the https port you chose in twistlock-console/charts/console/values.yaml

You can see your console external IP address with:

	kubectl get service -n twistlock
	
Log into your console via a browser - https://<CONSOLE_EXTERNAL_IP>:8083, create an admin account, and install your license.  

## Installing the Twistlock Defender DS

The Helm chart installs the Twistlock console only.  

Provided script installs Defender daemonset after console is up and runing and license has been installed.  The httpsPort defaults to 8083 but it must match the httpsPort in twistlock-console/charts/console/values.json.

	$ ./install_defender_ds.sh <8083>

For more information see support documentation [here.](https://docs.twistlock.com/docs/latest/install/install_kubernetes.html#_install_defender)

## Uninstalling Twistlock

First remove defender daemonset by running

	$ kubectl delete -f defender_ds.yaml

Then remove Twistlock console and namespace:

	$ helm delete twistlock-console --purge
	$ kubectl delete ns twistlock 
