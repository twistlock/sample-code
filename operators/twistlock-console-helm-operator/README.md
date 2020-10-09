# User Guide

This guide walks through using the Prisma Cloud Compute (Twistlock) Console operator 
powered by Helm using tools and libraries provided by the Operator SDK.

The operator runs as a container that has the Prisma Cloud Compute (Twistlock) Console helm charts on board
and can watch to see if the components are present. If they're not, the
operator will use Helm to install the Prisma Cloud Compute (Twistlock) Console correctly without
any user interaction!

All you have to to do is tell your cluster about the new TwistlockConsole custom resource by
applying the included Custom Resource Definition (CRD). Then deploy the operator
container into the cluster and let it do its thing.

Let's get down to it. All we need from you is the Twistlock registry/docs token
that came with your license. All of the yaml files you need to deploy are numbered from
0 - 6.

##  Here's the plan:

```sh
    # Let the cluster know about our new custom resource, TwistlockConsole
    kubectl apply -f deploy/0_8_crds/0_charts_v1alpha1_twistlockconsole_crd.yaml

    # Create the 'twistlock' namespace
    kubectl apply -f deploy/1_namespace.yaml

    # Create necessary user and permissions to make things happen
    kubectl apply -f deploy/2_service_account.yaml 
    kubectl apply -f deploy/3_role.yaml
    kubectl apply -f deploy/4_role_binding.yaml
    kubectl apply -f deploy/5_clusterrole.yaml
    kubectl apply -f deploy/6_clusterrole_binding.yaml

    # Deploy the operator container as a pod
    kubectl apply -f deploy/7_operator.yaml

    # Add your token and apply. For more detail, before you apply the CR, read the note below
    kubectl apply -f deploy/0_8_crds/8_charts_v1alpha1_twistlockconsole_cr.yaml
``` 


### Understanding the Twistlock Customer Resource (CR) spec

Helm uses a concept called [values][helm_values] to provide customizations
to a Helm chart's defaults, which are defined in the Helm chart's `values.yaml`
file.

Overriding these defaults is as simple as setting the desired values in the CR
spec. In our case we just have to override this value by replacing the string
`<REPLACE_TWISTLOCK_TOKEN>`,with your token and <CONSOLE_VERSION>, with the latest version from docs.twistlock.com. specify like: 20_09_345>. 
Save the deploy/0_8_crds/8_charts_v1alpha1_twistlockconsole_cr.yaml file, then you're ready to apply it as the last step.

```sh
consoleImageName: registry-auth.twistlock.com/tw_<REPLACE_TWISTLOCK_TOKEN>/twistlock/console:console_<CONSOLE_VERSION>
``` 

The other option to choose is whether we're on OpenShift, since Kubernetes is the default. If on OpenShift, be sure to add these lines to your CR spec as well:

```sh
openshift: true
serviceType: NodePort
```

### Next steps

`kubectl get all -n twistlock` should get you your Console pod, replication controller, and most importantly, the twistlock-console service and the LoadBalancer IP you'll use to connect to the Console. Typically you'll connect at `https://<external_lb_ip>:8083` where you'll be prompted to create an admin user and to provide your full license key. After that, navigate to **Manage > Defenders > Deploy Daemon Set** or **Manage > Defenders > Deploy** to get Defenders installed wherever you need them.

### Special Thanks

Thanks to the folks who put together https://github.com/operator-framework/operator-sdk/blob/master/doc/helm/user-guide.md and the other Operator Framework and Operator SDK docs and example. What an amazing resource. I borrowed from it liberally.
