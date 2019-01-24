 Helm Chart for Twistlock Console

## Downloading the charts

Just clone this repository and install from the charts, we don't make Twistlock charts available from the Helm package repository as our product is commercial.

## Prerequisites

### Helm

You will need [Helm](https://helm.sh/) installed (both the Helm client locally and the Tiller server component) on your Kubernetes cluster.

### Firewall

You will need to configure your kubenetes cluster firewall rules to allow ingress traffic on port 8081 for http and 8083 for https browser access.  Port 8084 is utilized for Defender to Console communications within your cluster (via WSS).

### Secrets

You will need the access token that comes with your Twistlock subscription; look for this in an e-mail from Twistlock support.

### Kubernetes client tools

You will need the `kubectl` command that has been configured for the management of the target Kubernetes cluster.

## Installing the Helm chart

### Configuration

First, copy the file `twistlock-console/valuesTemplate.yaml` to `twistlock-console/values.yaml`.

Next, edit `twistlock-console/values.yaml`, adding in the appropriate values for the _version_, _imageTag_, _imageName_, and  _accessToken_ parameters.

Note: the Twistlock release should be formatted with underscores for the _imageTag_ value (_2_5_127_) and periods for the _version_ value (_2.5.127_).

There are several parameters in `charts/twistlock-console/charts/console/values.yaml` that should be reviewed for correctness in the target environment:
 * _serviceType_: can be one of _LoadBalancer_ or _NodePort_. (default: _LoadBalancer_)
 * _persistentVolumeSize_: should be _10Gi_ for a small POC deployment, _50Gi_ or more for a production environment (default: _50Gi_)
 * _httpPort_,_httpsPort_,_commPort_: these parameters define the Console service ports. They can be changed, although the defaults will suffice in the vast majority of cases. (default: 8081, 8083, and 8084)

### Execution

Run the following _helm_ command to install the Console:

   $ helm install twistlock-console -n twistlock-console --namespace=twistlock

* `-n twistlock-console`: set the release name to _twistlock-console_
* `--namespace=twistlock`: install into the _twistlock_ namespace

## Configure and setup your Twistlock Console

Open a browser to _https://<CONSOLE_ADDRESS>:8083_, enter in a username and password to create an initial administrative account, then enter your license into the provided text box.

Note: Port 8083 is the default HTTPS port for the Console. If you changed it in _values.yml_, please replace 8083 with the appropriate value.

#### Determining the Console address

The value of _<CONSOLE_ADDRESS>_ will vary based on the service type.

For _LoadBalancer_ and _NodePort_ deployments, run the following command to display the external IP address:

    $ kubectl get service -n twistlock

For a _ClusterIP_ deployment, one might use _localhost_ in concert with a local port that has been forwarded to the remote service using an SSH tunnel or the `kubectl port-forward` command.


## Installing the Twistlock Defender DS

Although the Helm chart installs the Twistlock Console only, we have provided a shell script to help automate the installation of the Defender daemonset.

The script `install_defender_ds.sh` should be executed after the Console is running and the license has been installed.

The script accepts a single argument that should match the _httpsPort_ of the Console (default: 8083).

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
