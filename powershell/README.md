# README
The scripts extract vulnerability and compliance data from Twistlock's image health scan API call **/api/v1/images.**

## Running it
* Download the powershell scripts on your host and replace the following parameters and values
*$request = Your Twistlock Console address with an image name in 'search'
*$credPair = Your Twistlock Credentials

After making changes run:
```
PowerShell .\vulnerabilities.ps1
PowerShell .\compliances.ps1
```

## Prerequisite 
* PowerShell version 3.0 or greater
* Permissions to run locally-created scripts:
For this, run Powershell as an Administrator, then run the following command:
```
Set-ExecutionPolicy RemoteSigned
```
