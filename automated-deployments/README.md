# Automated Deployment Samples
This repo contains sample ansible playbooks for the [deployment](https://docs.prismacloudcompute.com/docs/compute_edition_21_04/install/install.html) of Twistlock. These playbooks are intended to help with your understanding in the Infrastructure as Code deployment of Twistlock. Use of these deployment examples does not imply any rights to Palo Alto Networks products and/or services.

## Deploy Console and Defenders within a Kubernetes cluster
The [K8s-Console-Defender-deployment-ansible.yaml](https://github.com/twistlock/sample-code/tree/master/automated-deployments/K8s-Console-Defender-deployment-ansible.yaml) ansible playbook demonstrates the deployment of both the Console and Defenders within a Kubernetes cluster. The Console is deployed using a Deployment yaml file and for the Defender a daemonSet yaml is used. See [support documentation](https://docs.prismacloudcompute.com/docs/compute_edition_21_04/deployment_patterns/automated_deployment.html) for further information.

## Deploy Defenders from an existing Console
This [defender.yaml](https://github.com/twistlock/sample-code/tree/master/automated-deployments/defender.yaml) ansible playbook demonstrates the deployment of the Defenders from an existing Console using a shell script.
