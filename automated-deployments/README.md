# Automated Deployment Samples
This repo contains sample ansible playbooks for the [deployment](https://docs.prismacloudcompute.com/docs/compute_edition_21_04/install/install.html) of Prisma Cloud Compute. These playbooks are intended to help with your understanding in the Infrastructure as Code deployment of Prisma Cloud Compute. Use of these deployment examples does not imply any rights to Palo Alto Networks products and/or services.

## Deploy Console and Defenders within a Kubernetes cluster
The [K8s-Console-Defender-deployment-ansible.yaml](K8s-Console-Defender-deployment-ansible.yaml) Ansible playbook demonstrates the deployment of both the Console and Defenders within a Kubernetes cluster. The Console is deployed using a Deployment YAML file, and Defenders are deployed using a DaemonSet YAML file. See [support documentation](https://docs.prismacloudcompute.com/docs/compute_edition_21_04/deployment_patterns/automated_deployment.html) for further information.

## Deploy Defenders from an existing Console
The [defender.yaml](defender.yaml) Ansible playbook demonstrates the deployment of the Defenders from an existing Console using a shell script.

## Deploy Defenders on instance creation
The [host-defender-userdata.sh](host-defender-userdata.sh) script demonstrates how to deploy a host Defender. When used as an instance startup script, you can ensure that a host Defender is installed on each newly-created instance automatically.

### Important links
- [Running Ansible playbooks using EC2 Systems Manager](https://aws.amazon.com/blogs/mt/running-ansible-playbooks-using-ec2-systems-manager-run-command-and-state-manager/)
- [Ansible for managing AWS](https://docs.ansible.com/ansible/latest/scenario_guides/guide_aws.html)
