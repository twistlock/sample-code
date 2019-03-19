#
#  Queries Twistlock API to return all things releated to an image that can be used for an Authority to Operate package.
#  Outputs an CSV file yyyyMMdd-imagename-ato.csv
#
#  Requires: Twistlock v2.4
#  Requires: powershell v6 https://blogs.msdn.microsoft.com/powershell/2018/01/10/powershell-core-6-0-generally-available-ga-and-supported/
#  Discalimer: Use of this script does not imply any rights to Twistlock products and/or services.
#
#  Usage: ./rmf_ato.ps1 <name of image>

param ($arg1)

if(!$arg1)
    {
    write-host "Please provide an image name"
    exit
    }
else 
    {
    write-host "Collecting data for: $arg1"
    }

# variables
$tlconsole = "https://twistlock.example.com"
$outputCSV = "ATO Package: $arg1"+$newline
$newline = [environment]::newline

$time = Get-Date -f "yyyyMMdd-HHmmss"

# We will need credentials to connect so we will ask the user
$cred = Get-Credential

# First search for the image in 'images'
# Search for the base image by name (input argument) in both the images and registry API
$request = "$tlconsole/api/v1/images?search=$arg1"

# Get the JSON data back from Twistlock and turn it
# into a PowerShell object.
$images = Invoke-RestMethod $request -Authentication Basic -Credential $cred -SkipCertificateCheck

# Make sure only one image was found 
if($images.count -eq 1)
    {$foundBaseImage = [bool]$true
    write-host "Found image on a docker host"
    $baseImage = $images[0]
    }
elseif ($images.count -gt 1)
    {
    write-host "found more than 1 image that matches that name, please narrow your search"
    exit
    }
else {
    write-host "Did not find image on docker hosts"
    }

# Search images within the registry, if it was not found on the docker host
if(!$foundBaseImage){
    $request = "$tlconsole/api/v1/registry?search=$arg1"    
    $registry = Invoke-RestMethod $request -Authentication Basic -Credential $cred -SkipCertificateCheck
    if($registry.count -eq 1)
        {
        $foundBaseImage = [bool]$true
        write-host "Found base image found in a registry"
        $baseImage = $registry[0]
        }
    elseif ($registry.count -gt 1)
        {
        write-host "found more than 1 image that matches that name, please narrow your search"
        exit
        }
    else
        {
        write-host "Did not find image in a registry"
        exit
        }
} # end if !Image search registry for base image

# The image we are looking for is
$baseImage
$imageID = $baseImage.info.id
$firstCVE = $baseImage.info.cveVulnerabilities[0].cve

# generate the output as a CSV
# CVE vulnerabilities
$outputCSV = $outputCSV + "ImageID: $imageID" + $newline + $newline
$outputCSV = $outputCSV + "CVEVulnerabilities" + $newline
$outputCSV = $outputCSV + "NumberOfVulnerabilities," + $baseImage.info.cveVulnerabilitiescnt + $newline
$outputCSV = $outputCSV + ",Critical,High,Medium,Low" + $newline
$outputCSV = $outputCSV + "CVEDistribution," + $baseimage.info.cveVulnerabilityDistribution.critical +","+ $baseimage.info.cveVulnerabilityDistribution.high +","+ $baseimage.info.cveVulnerabilityDistribution.medium  +","+ $baseimage.info.cveVulnerabilityDistribution.low + $newline + $newline

# Compliance vulnerabilities
$outputCSV = $outputCSV + "Compliance" + $newline
$outputCSV = $outputCSV + "ComplianceVulnerabilities," + $baseImage.info.complianceVulnerabilitiescnt + $newline
$outputCSV = $outputCSV + ",Critical,High,Medium,Low" + $newline
$outputCSV = $outputCSV + "ComplianceDistribution," + $baseimage.info.complianceDistribution.critical +","+ $baseimage.info.complianceDistribution.high +","+ $baseimage.info.complianceDistribution.medium  +","+ $baseimage.info.complianceDistribution.low + $newline + $newline

# Enumerate all the packages
$outputCSV = $outputCSV + "Packages" + $newline
$baseImage.info.data.packages.count
$packages = $baseImage.info.data.packages
foreach($pkg in $packages)
    {
    $outputCSV = $outputCSV + $pkg.pkgsType +","+ $pkg.pkgs.name + $newline
    }
$outputCSV = $outputCSV + $newline

# Query the impacted-resources API based upon a CVE associated to the image.
# Then find the entry for the image in the returned riskTree hash table
$request = "$tlconsole/api/v1/stats/vulnerabilities/impacted-resources?cve=$firstCVE"
$impacts = Invoke-RestMethod $request -Authentication Basic -Credential $cred -SkipCertificateCheck

$outputCSV = $outputCSV + "Containers" + $newline
foreach ($container in $impacts.riskTree.$imageID)
    {
    $outputCSV = $outputCSV + $container.container + $newline
    }
#$impacts.riskTree.$imageID


# Output to CSV
$file = $arg1.Split("/")

write-host $file.Count
$i = $file.count
$outfile = $file[--$i]
$outputFile = $time+"-"+($outfile -replace ":","_")+"-ato.csv"

$outputCSV | Out-File -FilePath ./$outputFile -Encoding ASCII
write-host "Output file name:" $outputFile
write-host $outputCSV

