# Twistlock supports Helm through twistcli (19.03+), this repository remains available to assist customers who may wish to work with an older version of Twistlock or create their own charts, but should be considered deprecated.

## Helm chart for installing Twistlock Console into Kubernetes with script for installing Twistlock Defender daemonset

## Downloading the charts

Just clone this repository and install from the charts, we don't make Twistlock charts available from the Helm package repository as our product is commercial.

## Prerequisites

### Helm

You will need [Helm](https://helm.sh/) installed (both the Helm client locally and the Tiller server component) on your Kubernetes cluster.

### Firewall

You will need to configure your Kubenetes cluster firewall rules to allow ingress traffic on port 8081 for HTTP and 8083 for HTTPS browser access.  Port 8084 is utilized for Defender to Console WSS communications within your cluster.

### Secrets

You will need the access token that comes with your Twistlock subscription; look for this in an e-mail from Twistlock support.

### Kubernetes client tools

You will need a local installation of the `kubectl` command that has been configured for the management of the target Kubernetes cluster.

### Twistlock access token and license

You will need the access token and the license that was provided to you by the Twistlock account team.

## Installing the Helm chart

### Configuration

First, copy the file `twistlock-console/valuesTemplate.yaml` to `twistlock-console/values.yaml`.

Next, edit `twistlock-console/values.yaml`, adding in the appropriate values for the _version_, _imageTag_, _imageName_, and  _accessToken_ parameters.

Note: the Twistlock release should be formatted with underscores as the version separator in the _imageTag_ parameter (_19_03_307_), and periods for the _version_ parameter (_19_03_307_).

There are several parameters in `charts/twistlock-console/charts/console/values.yaml` that should be reviewed for correctness in the target environment:
 * _serviceType_: can be one of _LoadBalancer_, _or NodePort_. (default: _LoadBalancer_)
 * _persistentVolumeSize_: a _10Gi_ PV will suffice for a very small POC deployment. For a deployment of any signifigance, a PV of _50Gi_ or higher should be used. (default: _50Gi_)
 * _httpPort_, _httpsPort_, _commPort_: these parameters define the Console service ports. Although they can be changed, it is recommended to retain the defaults for operational simplicity. (default: 8081, 8083, and 8084)

### Execution

Run the following _helm_ command to install the Console:

    $ helm install twistlock-console -n twistlock-console --namespace=twistlock

 * `-n twistlock-console`: set the release name to _twistlock-console_
 * `--namespace=twistlock`: install into the _twistlock_ namespace

## Configure and setup your Twistlock Console

### Determine the Console address

The Console address can be found in the `External IP` field in the output of the following command:

    $ kubectl get service -n twistlock


### Accessing the Console

Open a browser to _https://<CONSOLE_ADDRESS>:8083_, enter in a username and password to create an initial administrator account, then enter your license into the provided text box.

Note: Port 8083 is the default HTTPS port for the Console. If you changed it in _values.yml_, please replace 8083 with the appropriate value.

## Installing the Twistlock Defender DS

Although this Helm chart is limited to the installation of the Twistlock Console only, we have provided a shell script to help automate the installation of the Defender daemonset.

The script `install_defender_ds.sh` should be executed after the Console is running and the license has been installed.

The script accepts a single argument that should match the _httpsPort_ of the Console (default: 8083).

    $ ./install_defender_ds.sh 8083

For more information, see the [documentation covering the installation of Defenders under Kubernetes.](https://docs.twistlock.com/docs/latest/install/install_kubernetes.html#_install_defender)


## Uninstalling Twistlock

First, remove the Defender daemonset by running:

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
