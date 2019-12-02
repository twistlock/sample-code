This repo includes an example GitHub Action that can be used for integrating vulnerability and compliance scans with regular pushes and pull requests.

A big shoutout to [@jpadams](https://github.com/jpadams) for the initial sample Action and scan.yml used to configure the Action.

## Requirements
To use the GitHub Action, users will need the following:
* A Prisma Cloud or Prisma Cloud Compute edition (Twistlock) license with running Console
* A ciuser role, with username and password, which allows users to run vulnerability and compliance scans as part of their workflows
* Proper configuration of the scan.yml file included within the workflows folder

## Editing the scan.yml
The yaml file provides the instructions for the Action, including authenticating with the Prisma Cloud Console via the API to install twistcli, our command line interface that performs our image scan, and publishing the scan results.

Users will need to add their TL_Console_URL within the environment variables section of the scan.yml as well as the name of their Container_Image. Additionally, users will need to add their ciuser username and password (TL_USER and TL_PASS) into the Secrets tab within their repository for proper authentication.

## Running the Action and viewing results
The sample Action is designed to run on any push or pull request. Image scan results can be viewed by navigating to the Actions tab and clicking on the Scan the image step. 

