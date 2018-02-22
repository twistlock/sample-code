# README
The scripts extract vulnerability and compliance data from Twistlock's image health scan API call **/api/v1/images.**

## Running it
Download the powershell scripts on your host and replace the following value:

* $request = Your Twistlock Console address with an image name in 'search'

After making changes run:
```
PowerShell .\vulnerabilities.ps1
PowerShell .\compliances.ps1
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
