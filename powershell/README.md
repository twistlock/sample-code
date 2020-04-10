# Twistlock API + Powershell
This repository contains sample powershell scripts that query the Twistlock API to extract data.
These scripts are intended to help with your understanding of how to use the Twistlock API to further its functionality and value.
Pull requests are welcomed.

## Scripts

* **vulnerabilities.ps1** - simple powershell example that queries the Twistlock API for an image and returns the vulnerabilities found.
  * Modify:
    * _$request_ = Your Twistlock Console address with an image name or search term in 'search'
    * You can omit the entire '?search=<image>' clause if you want to return all images
  * Output:
    * results to standard out
  * Execute:
  ```
    .\vulnerabilities.ps1
  ```

* **compliances.ps1** - simple powershell example that queries the Twistlock API for an image and returns the compliance failures found.
  * Modify:
    * _$request_ = Your Twistlock Console address with an image name or search term in 'search'
    * You can omit the entire '?search=<image>' clause if you want to return all images
  * Output:
    * results to standard out
  * Execute:
  ```
    .\compliance.ps1
  ```

* **base_image_finder.ps1** - this script will compare all the images to a base image. Supply the name of the image that is your base image used as the foundation for other images within your environment.
  * Modify:
    * Change the _$tlconsole_ variable to your Twistlock Console's API URL
  * Output:
    * The results will be returned within a CSV (_yyyyMMdd-HHmmss-base-image-search.csv_) with the following associations:
      * _child_ - the image has more layers than the "master" image and the master's base layers match.
      * _parent_ - the image has less layers than the "master" image and the parent's base layers match. The image you supplied is based upon another image.
      * _no-association_ - the images' first layers does not match.
  * Execute:
      * Provide the name of the image to be used as the base image when comparing against all images within Twistlock. For example _localhost:5000/alpine:latest_
    ```
    .\base_image_finder.ps1 localhost:5000/alpine:latest
    ```

* **compliance_status.ps1** - this script takes the name of a compliance policy rule as input and finds all images, containers and hosts' compliance status to the rule.
  * Update 20191101: updated for API v19.07, compliance policies are divided between images/container and hosts.
  * Modify:
    * Change the $tlconsole variable to your Twistlock Console's API URL
  * Output:
    * Outputs an CSV file (_yyyyMMdd-HHmmss-<ruleName>-compliance-check.csv_).
    * Generates a CSV that can be used to generate charts within excel, for example:

    ![Compliance Status Image](../images/compliance_status.png?raw=true "compliance status results")

  * Execute:
    * Provide the name of the compliance policy rules. For example _800-190-images_ and _800-190-hosts_
    ```
    .\compliance_status.ps1 800-190-images 800-190-hosts
    ```

* **rmf_ato.ps1** - this script generates a sample Authority to Operate report for an image showing the packages, vulnerabilities, compliance and running containers. You can expand upon the data you want to render in the resulting csv file.
  * Update 20200409: updated for the API v20.04.163
  * Modify:
    * Change the $tlconsole variable to your Twistlock Console's API URL
  * Output:
    * Outputs an CSV file (_yyyyMMdd-HHmmss-<imageName>-ato.csv_).
    * Generates a CSV that can be used to generate charts within excel, for example:

        ![ATO report](../images/ato_report.png?raw=true "ato report")

  * Execute:
    * Provide the name of the image. For example _openebs/jiva:0.6.0_
        ```
        .\rmf_ato.ps1 openebs/jiva:0.6.0
        ```

* **tl-rsop.ps1** - Queries Twistlock API to determine the vulnerability and compliance rules applied to an image. Basically a Resultant Set of Policies (RSOP).
  * Update 20200409: updated for the API v20.04.163, additional logic to evaluated CI images against runtime policies
  * Update 20191126: updated for API v19.11
  * Logic:
    * Finds the Vulnerability Policy (Defend > Vulnerabilities > Policy) that applies to the image.
    * Compares the images vulnerabilities to the settings within the policy.
      * Does the image have a higher vulnerability than defined in the Severity of the policy.
      * Is the policy configured to “block” for the package type.
    * Finds the Compliance Policy (Defend > Compliance > Policy) that applies to the image.
    * Compare the image's failed compliance findings to the applied rule and the Action defined.
  * Modify:
    * Change the $tlconsole variable to your Twistlock Console's API URL

  * Output:
    * Outputs to stdout

  ```
  $ ./tl-rsop.ps1 infoslack/dvwa:latest
  Checking vulnerablity and compliance policy for: infoslack/dvwa:latest

  PowerShell credential request
  Enter your credentials.
  User: paul
  Password for user paul: *************

  Found image found on a docker host

  Found: infoslack/dvwa:latest
  ImageID: sha256:779975a3607d703c6cce88f2bb6076ef2f8e0b20d971d474cb1b81dee5d5acca

  Vulnerabilities:
          Critical:  0
          High:  12
          Medium:  340
          Low:  235

  Matching Vulnerability Policy: High and Critical
  Vulnerability Policy Fail: image will be blocked

  Matching Compliance Policy: 800-190-images

  Rule                             Block Image will be blocked
  ----                             ----- ---------------------
  7) Private keys stored in image  True  True

  *** Twistlock will block this image from running as a container on nodes running the Twistlock Defender ***
  ```



  If any matching vulnerability or compliance rule that is set to "block" the script will output *** Twistlock will block this image from running as a container on nodes running the Twistlock Defender *** and set exit(1). The exit status can be determined with the command $LASTEXITCODE


  ```
  $LASTEXITCODE
  1
  ```

  * Execute:
    * Provide the name of the image. For example  _neilcar/struts2_demo:latest_

      ```
      ./tl-rsop.ps1 infoslack/dvwa:latest
      ```

* **compliance_check.ps1** - this script takes the Twistlock ID of a compliance check as input and finds all failing images, containers or hosts' compliance to the individual compliance check.
    * Modify:
      * Change the $tlconsole variable to your Twistlock Console's API URL
    * Output:
        * Outputs to stdout

          ```
          TwistlockCheck: 41
          Title: Image should be created with a non-root user
          Description: It is a good practice to run the container as a non-root user, if possible. Though user
          namespace mapping is now available, if a user is already defined in the container image, the
          container is run as that user by default and specific user namespace remapping is not
          required
                   1) microsoft/windowsservercore:1803
                   2) microsoft/iis:20180911-windowsservercore-1803
                   3) node:7-onbuild
                   4) tl_demo/hellonode:latest
                   5) weaveworksdemos/queue-master:0.3.1
                   6) morello/httpd:latest
                   7) tl_demo/struts2_demo:2.3.12_build
                   8) morello/motools:latest
          ...
          ...
                  66) 113505086193.dkr.ecr.us-east-2.amazonaws.com/node:latest
                  67) 113505086193.dkr.ecr.us-west-1.amazonaws.com/bad-dockerfile:test
          Failing: 67
          Passing: 32
          ```

    * Execute:
      * Provide the name of the compliance policy check. For example _41_ will list all images that fail the check for non-root user.

          ```
          .\compliance_check.ps1 41
          ```

## Prerequisite
* PowerShell version 6.0 or greater.
  * Earlier versions of PowerShell don't support basic authentication with Invoke-RestRequest.
  * To use an earlier version of PowerShell, you will have to [manually build the authentication header](https://pallabpain.wordpress.com/2016/09/14/rest-api-call-with-basic-authentication-in-powershell/).
* Permissions to run locally-created scripts:
For this, run Powershell as an Administrator, then run the following command:

  ```
  Set-ExecutionPolicy RemoteSigned
  ```
* Why powershell? Why not.
