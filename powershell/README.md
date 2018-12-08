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
  * Modify:
    * Change the $tlconsole variable to your Twistlock Console's API URL
  * Output:
    * Outputs an CSV file (_yyyyMMdd-HHmmss-<ruleName>-compliance-check.csv_).
    * Generates a CSV that can be used to generate charts within excel, for example:

    ![Compliance Status Image](../images/compliance_status.png?raw=true "compliance status results")

  * Execute:
    * Provide the name of the compliance policy rule. For example _800-190_
    ```
    .\compliance_status.ps1 800-190
    ```

* **rmf_ato.ps1** - this script generates a sample Authority to Operate report for an image showing the packages, vulnerabilities, compliance and running containers. You can expand upon the data you want to render in the resulting csv file.
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

## Prerequisite
* PowerShell version 6.0 or greater.
  * Earlier versions of PowerShell don't support basic authentication with Invoke-WebRequest.
  * To use an earlier version of PowerShell, you will have to [manually build the authentication header](https://pallabpain.wordpress.com/2016/09/14/rest-api-call-with-basic-authentication-in-powershell/).
* Permissions to run locally-created scripts:
For this, run Powershell as an Administrator, then run the following command:

  ```
  Set-ExecutionPolicy RemoteSigned
  ```
* Why powershell? Why not.
