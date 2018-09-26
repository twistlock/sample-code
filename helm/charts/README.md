# Helm chart for installing Twistlock Console into Kubernetes with script for installing Twistlock Defender daemonset 

## Downloading the charts

Just clone this repository and install from the charts, we don't make Twistlock charts available from the Helm package repository as our product is commercial.

## Prerequisites

### Helm 

You will need [Helm](https://helm.sh/) installed (both the Helm client locally and the Tiller server component) on your Kubernetes cluster. 

### Secrets

You will need the access token that comes with your Twistlock subscription; look for this in an e-mail from Twistlock support.

## Installing the Helm chart

First, copy the file `twistlock-console/valuesTemplate.yaml` to `twistlock-console/values.yaml`.

Next, edit `twistlock-console/values.yaml`, adding in the appropriate values for the _version_, _imageTag_, _imageName_, and  _accessToken_ parameters.

Now run:

    $ helm install ./twistlock-console -n twistlock-console --namespace=twistlock

## Configure and setup your Twistlock Console

NOTE: the Console HTTPS port defaults to 8083. If you changed the port from the default value, please insert the custom value into `twistlock-console/values.yaml`.

You can see your console external IP address with:

    $ kubectl get service -n twistlock

Log into your console via a browser - https://<CONSOLE_EXTERNAL_IP>:8083, create an admin account, and install your license.  

## Installing the Twistlock Defender DS

The Helm chart installs the Twistlock Console only.

The provided script `install_defender_ds.sh` installs the Defender daemonset after the Console is running and the license has been installed.  The httpsPort defaults to 8083 but it must match the httpsPort in `twistlock-console/charts/console/values.yaml`.

    $ ./install_defender_ds.sh <8083>

For more information, see the [documentation covering the installation of Defenders under Kubernetes.](https://docs.twistlock.com/docs/latest/install/install_kubernetes.html#_install_defender)


## Uninstalling Twistlock

First, remove the Defender daemonset by running

    $ kubectl delete -f defender_ds.yaml

Then, remove the Twistlock Console and namespace:

    $ helm delete ./twistlock-console --purge
    $ kubectl delete ns twistlock 


## Next Steps

New users can find details on getting started with some of Twistlock's key features in the following articles:

 * [Creating vulnerability management rules](https://docs.twistlock.com/docs/latest/vulnerability_management/vuln_management_rules.html)
 * [Creating compliance management rules](https://docs.twistlock.com/docs/latest/compliance/manage_compliance.html)
 * [Configuring registry scanning](https://docs.twistlock.com/docs/latest/vulnerability_management/configure_registry_scans.html)
 * [An overview of container runtime defense](https://docs.twistlock.com/docs/latest/runtime_defense/runtime_defense.html)
 * [Setting up a cloud native application firewall](https://docs.twistlock.com/docs/latest/firewalls/cnaf.html)
 * [Setting up a cloud native application firewall](https://docs.twistlock.com/docs/latest/firewalls/cnnf.html)
