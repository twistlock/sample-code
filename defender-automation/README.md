# Automating Deployment of Prisma Cloud Host Defender Agents on Linux

Deploy Prisma Cloud Host Defender agents on Linux instances using Ansible-Playbook.

## Description

The playbook defender.yml can be used to deploy the agents across the assets included in your "host" file. 

The required input parameters are:

USERNAME = Your Username to authenticate with the API
PASS = Your access Password to authenticate with the API
CONSOLE_ADDR = Address of your console. Example: us-east1.cloud.twistlock.com
ACCOUNT_ID = For SaaS tenant, your tenanat subscription id

## Usage
#Usage of the command to be called.

## Reference Documentation
https://docs.prismacloudcompute.com/docs/compute_edition_21_04/install/defender_types.html

### Important Links
[Running Ansible Playbooks using EC2 Systems Manager](https://aws.amazon.com/blogs/mt/running-ansible-playbooks-using-ec2-systems-manager-run-command-and-state-manager/)
[Ansible for managing AWS](https://docs.ansible.com/ansible/latest/scenario_guides/guide_aws.html)
