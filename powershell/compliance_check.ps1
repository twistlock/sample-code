#
#  Queries Twistlock API to determine all images, containers and hosts adherence (failing) to a specific compliance rule.
#
#  Requires: powershell v6 https://blogs.msdn.microsoft.com/powershell/2018/01/10/powershell-core-6-0-generally-available-ga-and-supported/
#  Discalimer: Use of this script does not imply any rights to Twistlock products and/or services.
#
#  Usage: ./compliance_check.ps1 <name of TwistlockComplianceCheckID>
#

param ($arg1)

if(!$arg1)
    {
    write-host "Please provide a Twistlock Compliance identifier"
    write-host "For example: ./compliance_check.ps1 423 "
    write-host "will check for if the image is trusted"
    exit
    }
else
    {
    write-host "Checking images' compliance to: $arg1"
    }

# variables
$tlconsole = "https://twistlock.example.com:8083"
$global:imageChecks = [string] @(4,9)
$global:hostChecks = [string] @(1,2,3,6,8)
$global:containerChecks = [string] @(5)
$global:complianceChecks = @{}

function findCompliance([array]$type, [array]$objects, [int]$total)
    {
    $y = 0
    foreach($object in $objects)
        {
        if($object.info.complianceVulnerabilities.id -eq $arg1)
                {
                $y++
                switch($type)
                    {
                    "image"
                        {
                        $tmpname = $object.instances[0].image
                        write-host "`t $y) $tmpname"
                        }
                    "host"
                        {
                        $tmpname = $object.hostname
                        write-host "`t $y) $tmpname"
                        }
                    "container"
                        {
                        $tmpname = $object.info.name
                        write-host "`t $y) $tmpname"
                        }
                    default{"Unknown switch condition"}
                    }
                }
            }
        $passing = $total - $y
        write-host "Failing: $y"
        write-host "Passing: $passing"
    } # end findCompliance function

# main

# We will need credentials to connect so we will ask the user
$cred = Get-Credential

# Create a hash table of all the compliance checks
$request = "$tlconsole/api/v1/static/vulnerabilities"
$return = Invoke-RestMethod $request -Authentication Basic -Credential $cred -SkipCertificateCheck

# Iterate through all the checks and build out the hash table
foreach($compliance in $return.complianceVulnerabilities)
{
    $complianceChecks += @{[string]$compliance.id = $compliance.title,$compliance.description}
    if([string]$compliance.id -eq $arg1)
        {
        write-host "TwistlockCheck:" $arg1
        write-host "Title:" $compliance.title
        write-host "Description:" $compliance.description
        }
}

# Determine the type of scan based upon the first digit of the Twistlock Check ID #
$strCheckId = [string]$arg1
if($imageChecks.Contains($strCheckId.Substring(0,1)))
    {
    $type = "image"
    }
elseif ($hostChecks.Contains($strCheckId.Substring(0,1)))
    {
    $type = "host"
    }
elseif ($containerChecks.Contains($strCheckId.Substring(0,1)))
    {
    $type = "container"
    }
else
    {
    write-host "Unknown check type $arg1 exiting"
    exit
    }

# Based upon the resource type call the findCompliance function
switch($type)
        {
        "image"
            {
            #Pull images from "Images", "Registry"
            $request = "$tlconsole/api/v1/images"
            $images = Invoke-RestMethod $request -Authentication Basic -Credential $cred -AllowUnencryptedAuthentication -SkipCertificateCheck
            $request = "$tlconsole/api/v1/registry"
            $images += Invoke-RestMethod $request -Authentication Basic -Credential $cred -AllowUnencryptedAuthentication -SkipCertificateCheck

            # Pull the Jenkins and Twistcli scans as well
            $request = "$tlconsole/api/v1/scans?type=twistcli"
            $images += Invoke-RestMethod $request -Authentication Basic -Credential $cred -AllowUnencryptedAuthentication -SkipCertificateCheck
            $request = "$tlconsole/api/v1/scans?type=jenkins"
            $images += Invoke-RestMethod $request -Authentication Basic -Credential $cred -AllowUnencryptedAuthentication -SkipCertificateCheck

            # Get an accurate count of images by removing the duplicates
            $tmparray = @()
            $uniqueImages = @()
            $totalImages = 0
            foreach($image in $images)
                {
                if(!$tmparray.Contains($image.info.id))
                    {
                    $totalImages++
                    $tmparray += $image.info.id
                    $uniqueImages += $image
                    }
                }

            findCompliance "image" $uniqueImages $totalImages
            }
        "host"
            {
            # Process the hosts
            $request = "$tlconsole/api/v1/hosts"
            $hosts = Invoke-RestMethod $request -Authentication Basic -Credential $cred -AllowUnencryptedAuthentication -SkipCertificateCheck
            $totalHosts = $hosts.count
            findCompliance "host" $hosts $totalHosts
            }
        "container"
            {
            # Process the containers
            $request = "$tlconsole/api/v1/containers"
            $containers = Invoke-RestMethod $request -Authentication Basic -Credential $cred -AllowUnencryptedAuthentication -SkipCertificateCheck
            $totalContainers = $containers.count
            findCompliance "container" $containers $totalContainers
            }
        default{"Unknown switch condition"}
        }
