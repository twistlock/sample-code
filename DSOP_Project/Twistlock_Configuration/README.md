# Twistlock Configuration as Code
This repository contains the Jenkins Pipeline process to configure the Twistlock Consoles used in the DSOP Pathfinder program.

## Prerequisites
- Jenkins
- Twistlock Console and administrator credentials
- GitHub repo to pull Twistlock configuration into the Pipeline's workspace

## Contents
- config
  - json files containing Twistlock Console configuration
- Jenkins_push_dsop_config
  - Jenkins Pipeline Groovy script

## Configuration
1. Place the items in this repo on a GitHub site that is accessible by Jenkins
2. Create a Jenkins *Global Property* to contain the URL of the Twistlock Console to be configured, e.g. *TL_CONSOLE = twistlock-console.example.com*
3. Create a Jenkins global credential for the Twistlock Console's administrator account for authentication to the API. For example *$twistlock_creds*
4. Create a Jenkins Pipeline
5. Configure the newly created Jenkins Pipeline
6. In the General section create a *String Parameter*, name = *GIT*, default value = path to Git repo that contains the contents of this repo
7. In the Advanced Project Options > Pipeline create a *Pipeline script from SCM*, SCM = *Git*, Repository URL = path to Git repo that contains the contents of this repo, Script path = *Jenkins_push_dsop_config*

## Executing
1. Click *Build with Parameters*
2. The default value will appear in the *git_url*
3. Click *Build*

The Twistlock Console will be updated with the DSOP standard settings.
