# As of the 19.03 release, Twistlock includes native support for Helm.  Please refer to Twistlock support for additional information.  This repository will remain available for reference purposes only.

# Rancher Helm chart for installing Twistlock Console into Kubernetes 


## adding the charts to rancher 2.0

Detailed documentation can be found here https://rancher.com/docs/rancher/v2.x/en/catalog/#adding-custom-catalogs
Ideally you should copy the rancher catalog to your own repo and follow the instructions detailed above.

NOTE: if you add this repo as a catalog you will end up with two twistlock entries, the helm chart as well as the rancher
chart both of which are valud Rancher catalogs; Rancher charts have a questions.yml which provides a simple form that helps
modify the value.yaml on the fly. You can learn more about Rancher charts here https://github.com/rancher/charts

## Prerequisites


### Secrets

You will need the access token that comes with your Twistlock subscription; look for this in an e-mail from Twistlock support.

## Installing the Helm chart

after you have added the repo as a catalog, click the twistlock app, fill out the form and click launch.

## Configure and setup your Twistlock Console

Depending on the option you chose for ingress you will either need to get a loadbalancer ip via kubectl
```
	kubectl get service -n twistlock
```

or navigate to the url:port if you chose the nginx ingress annotations.

Once you have a means to access the concolse Log into your console via a browser
	- https://<CONSOLE_EXTERNAL_IP>:8083
	- create an admin account
	- install your license.

## Installing the Twistlock Defender DS

The Helm chart installs the Twistlock console only.

To complete the Twistlock install, you will need to deploy the Twistlock Defender Daemonset. Please see Twistlock docs for this - search for **defender daemonset kubernetes**.  Or go directly to the support documentation [here.](https://docs.twistlock.com/docs/latest/install/install_kubernetes.html#_install_defender)
