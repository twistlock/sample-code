#  
#  Queries Twistlock API to determine the image, container and host adherence to a compliance rule.
#  Outputs an CSV file yyyyMMdd-HHmmss-<ruleName>-compliance-check.csv
#  Generates a CSV that can be used to generate charts within excel
#
#  Requires: powershell v6 https://blogs.msdn.microsoft.com/powershell/2018/01/10/powershell-core-6-0-generally-available-ga-and-supported/
#  Discalimer: Use of this script does not imply any rights to Twistlock products and/or services.
# 
#  Usage: ./compliance_status.ps1 <name of complaince rule>
#

param ($arg1)

if(!$arg1)
    {
    write-host "Please provide a Compliance rule name"
    exit
    }
else 
    {
    write-host "Checking compliance: $arg1"
    }

# variables
$tlconsole = "https://twistlock.example.com:8083"
$global:imageChecks = [string] @(4,9)
$global:hostChecks = [string] @(1,2,3,6,8)
$global:containerChecks = [string] @(5)
$global:newline = [environment]::newline
$time = Get-Date -f "yyyyMMdd-HHmmss"

function findCompliance([array]$type, [array]$rules, [array]$objects, [int]$total)
    {
    switch($type)
        {
        "image"{$check = $imageChecks}
        "host"{$check = $hostChecks}
        "container"{$check = $containerChecks}
        default{"Unknown switch condition"}
        }
    foreach($rule in $rules)
        {
        # Process only the check that apply to the $type
        $strCheckId = [string]$rule
        if($check.Contains($strCheckId.Substring(0,1)))
            {
            $y = 0
            foreach($object in $objects)
                {
                if($object.info.complianceVulnerabilities.id -eq $rule){$y++}
                }
                $passing = $total - $y
                $tmpOutputCSV = $tmpOutputCSV + "$rule,$y,$passing,$total" +$newline
            } #if an object check
        } #end of foreach check
    # return CSV formated string
    return $tmpOutputCSV
    } # end fidnCompliance function

# main

# We will need credentials to connect so we will ask the user
$cred = Get-Credential

# Query the complaince /policies/compliance API and pull out the rule #s into an array
$request = "$tlconsole/api/v1/policies/compliance"
$compliances = Invoke-RestMethod $request -Authentication Basic -Credential $cred -SkipCertificateCheck
$checks = @()
$i = 0
while ($i -lt $compliances.rules.count)
    {
    if($compliances.rules[$i].name -eq $arg1)
        {
        #Pull out the vulnerabilities/compliance check    
        $checks = $compliances.rules[$i].condition.vulnerabilities.id   
        }
    $i++
    }
if($checks.count -eq 0)
    {
    write-host "no checks found, exiting"
    exit
    }

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

$outputCSV = "ImageComplianceID,failing,passing,total"+$newline
$outputCSV = $outputCSV + (findCompliance "image" $checks $uniqueImages $totalImages) + $newline

# Process the hosts
$request = "$tlconsole/api/v1/hosts"
$hosts = Invoke-RestMethod $request -Authentication Basic -Credential $cred -AllowUnencryptedAuthentication -SkipCertificateCheck
$totalHosts = $hosts.count
$outputCSV = $outputCSV + "HostComplianceID,failing,passing,total"+$newline
$outputCSV = $outputCSV + (findCompliance "host" $checks $hosts $totalHosts) + $newline

# Process the containers
$request = "$tlconsole/api/v1/containers"
$containers = Invoke-RestMethod $request -Authentication Basic -Credential $cred -AllowUnencryptedAuthentication -SkipCertificateCheck
$totalContainers = $containers.count
$outputCSV = $outputCSV + "ContainerComplianceID,failing,passing,total"+$newline
$outputCSV = $outputCSV + (findCompliance "container" $checks $containers $totalContainers) + $newline

$outputFile = $time+"-"+$arg1+"-compliance-check.csv"
$outputCSV | Out-File -FilePath .\$outputFile -Encoding ASCII
write-host "Output file name:" $outputFile
