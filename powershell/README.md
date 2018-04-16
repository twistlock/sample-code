# README
* Vulnerabilities.ps1 and compliances.ps1 scripts extract vulnerability and compliance data from Twistlock's image health scan API call **/api/v1/images.**
* Base_image_finder.ps1 determines all images' assocation to the image provided as an input argument.

## Running it
Download the powershell scripts on your host and replace the following value:
* Vulnerabilities.ps1 and compliances.ps1:
  * $request = Your Twistlock Console address with an image name or search term in 'search'
    * You can omit the entire '?search=<image>' clause if you want to return all images
*Base_image_finder.ps1:
  * Change the $tlconsole variable to your Twistlock Console's API URL
  * Provide the name of the image to be used as the base image when comparing against all images within Twistlock. For example localhost:5000/alpine:latest 

After making changes run:
```
PowerShell .\vulnerabilities.ps1
PowerShell .\compliances.ps1
PowerShell .\base_image_finder.ps1 localhost:5000/alpine:latest
```

## Prerequisite 
* PowerShell version 6.0 or greater
  * Earlier versions of PowerShell don't support basic authentication with Invoke-WebRequest.
  * To use an earlier version of PowerShell, you will have to [manually build the authentication header](https://pallabpain.wordpress.com/2016/09/14/rest-api-call-with-basic-authentication-in-powershell/).
* Permissions to run locally-created scripts:
For this, run Powershell as an Administrator, then run the following command:
```
Set-ExecutionPolicy RemoteSigned
```
