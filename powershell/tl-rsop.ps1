#  Twistlock Resultant Set of Vulnerability and Compliance Policies for an Image
# 
#  Queries Twistlock API to determine the vulnerability and compliance rules applied to an image.
#  Finds the Vulnerability Policy (Defend > Vulnerabilities > Policy) that applies to the image.
#  Compares the images vulnerabilities to the settings within the policy.
#    - Does the image have a higher vulnerability than defined in the Severity of the policy.
#    - Is the policy configured to “block” for the package type.
#  Find the Compliance Policy (Defend > Compliance > Policy) that applies to the image.
#  Compare the image's failed compliance findings to the applied rule and the Action defined
#
#  Requires: powershell v6 https://blogs.msdn.microsoft.com/powershell/2018/01/10/powershell-core-6-0-generally-available-ga-and-supported/
#  Discalimer: Use of this script does not imply any rights to Twistlock products and/or services.
# 
#  Usage: ./tl-rsop.ps1 <name of image>
#

param ($arg1)
if(!$arg1)
    {
    write-host "Please provide an image name"
    write-host "Usage: ./tl-rsop.ps1 <name of image>"
    exit
    }
else 
    {
    write-host "Checking vulnerablity and compliance policy for: $arg1"
    }

# variables
# change this variable for the URL to your Twistlock Console's API
$tlconsole = "https://twistlock-console.example.com:8083"
# Twistlock hash table for the type of packages scanned and their idenitifier, this table to use for output readability
$vulnHash = @{"410"="Python";"411"="Binaries";"412"="Custom Components";"413"="0-day";"46"="OS Packages";"47"="Java";"48"="Ruby Gems";"49"="Node.js"}
# This hash table will contain the images high CVSS score for each package type
$imageVulnHash = @{"410"="0";"411"="0";"412"="0";"413"="0";"46"="0";"47"="0";"48"="0";"49"="0"}
# Twistlock hash table to define the "low, medium, high & critical" CVSS mappings
$sevHash = @{"0"="Low";"4"="Medium";"7"="High";"9"="Critical"}
# Hash table of the policy name and the order in which it is applied
$vulnPolicies = @{}
$policies = @()
$compliancePolicies = @{}
$imageChecks = [string] @(4,9)
$foundImage = [bool]$false
$policyMatch = [bool]$false
$newline = [environment]::newline
$output = "Package,Block,Severity,Highest Vulnerability Found" + $newline
$outputCompliance = "Rule,Block,Image will be blocked" + $newline

# We will need credentials to connect so we will ask the user
$cred = Get-Credential

# query API to find the image
$request = "$tlconsole/api/v1/images?search=$arg1"
$image = Invoke-RestMethod $request -Authentication Basic -Credential $cred -SkipCertificateCheck

# Make sure only one image was found 
if($image.count -eq 1)
    {
    $foundImage = [bool]$true
    write-host "Found image found on a docker host"
    # Grab the image ID
    $imageid = $image[0]._id
    }
elseif ($image.count -gt 1)
    {
    write-host "found more than 1 image that matches that name, please narrow your search"
    exit
    }
else {
    write-host "Did not find image on docker hosts"
    }

# Search images within the registry, if it was not found on the docker host
if(!$foundImage){
    $request = "$tlconsole/api/v1/registry?search=$arg1"
    $image = Invoke-RestMethod $request -Authentication Basic -Credential $cred -SkipCertificateCheck
    if($image.count -eq 1)
        {
        $foundImage = [bool]$true
        write-host "Found image found in a registry"
        $imageid = $image[0]._id
        }   
    elseif ($image.count -gt 1)
        {
        write-host "found more than 1 image that matches that name, please narrow your search"
        exit
        }
    else
        {
        write-host "Did not find image in a registry"
        exit
        }

} # end if !foundImage search registry for base image

# Output the image found
write-host ""
write-host "Found: $arg1"
write-host "ImageID: $imageid"

# Break out the vulnerabilities
write-host ""
write-host "Vulnerabilities:"
write-host "`tCritical: "$image[0].info.cveVulnerabilityDistribution.critical
write-host "`tHigh: "$image[0].info.cveVulnerabilityDistribution.high
write-host "`tMedium: "$image[0].info.cveVulnerabilityDistribution.medium
write-host "`tLow: "$image[0].info.cveVulnerabilityDistribution.low

# Determine the highest level severity of the packages' CVEs, base it upon CVSS
# For each type of package scanned put the highest found vulnerability into the $imageVulnHash table
$vulnerabilities = $image[0].info.cveVulnerabilities
foreach($vulnerability in $vulnerabilities)
    {
    # Update the $imageVulnHash table with the highest vulnerability
    $tmpVulnIDString = $vulnerability.id.ToString()
    
    if([int]$imageVulnHash.$tmpVulnIDString -le $vulnerability.cvss)
        {
        $imageVulnHash.$tmpVulnIDString = $vulnerability.cvss
        }
    } #end of foreach vulnerability within the image

# Now query the API to determine which Defend > Policy > Vulnerabilities > Policy rule applies to the image
# and what is the Action is Alert or Block
$request = "$tlconsole/api/v1/policies/cve"
$returnedRules = Invoke-RestMethod $request -Authentication Basic -Credential $cred -SkipCertificateCheck

# Pull out the rule names in order because Twistlock process the rules in order and the first matching rule is processed
# and all other rules are not.
$rules = $returnedRules[0].rules
$i = 0 
foreach ($rule in $rules)
    {
    # put the policies name into an array and a hash table as well so we can index it when we go to examine the policies.
    # have to do the array for the policy names to keep the order of the rule application.
    # the hash table flips it, if you can tell me how to do it with just the hash table, submit a PR please.
    $tmp = $rule[0].name
    $policies += $tmp
    $vulnPolicies.$tmp = $i
    $i++
    }

# call impacted API to see if the rule applies to this image
$matchingPolicy = ""
foreach($policy in $policies)
    {
    $request = "$tlconsole/api/v1/policies/cve/impacted?ruleName=$policy&search=$imageid"
    $returnedImpact = Invoke-RestMethod $request -Authentication Basic -Credential $cred -SkipCertificateCheck
    if($returnedImpact.count -eq 1)
        {
        $matchingPolicy = $policy
        $policyMatch = [bool]$true
        break
        }        
    } # end of foreach policy

if(!$policyMatch)
    {
    write-host "No vulnerability policies match, odd the Default Rule should apply, exiting"
    exit(1)
    }

# now determine the effect of the rule
write-host ""
write-host "Matching Vulnerability Policy: $matchingPolicy"

# find the rule in the existing $returnedRules and determine the effect
# pull out the Policy's ID, Type and Action and combine with the images corresponding vuln from the $imageVulHash table into output
# use the $vulnPolicies hash table to find which array element the $rule conditions/settings
$TLBlock = [bool]$false
$conditions = $rules[$vulnPolicies.$matchingPolicy].condition.vulnerabilities
foreach ($condition in $conditions)
    {
    # what is the package type of the image cveVuln
    $tmpPackage = ($condition[0].id).ToString()
    $tmpSev = ($condition[0].minSeverity).ToString()
    # use the hash tables to make the output readable (names instead of number)
    $output = $output + $vulnHash.$tmpPackage+","+$condition[0].block+","+$sevHash.$tmpSev+","+$imageVulnHash.$tmpPackage + $newline
    # determine if Twistlock will block the deployment of the image
    if(($condition[0].minSeverity -le $imageVulnHash.$tmpPackage) -and ($condition[0].block) -and ($imageVulnHash.$tmpPackage -ne 0))
      {
      $TLBlock = [bool]$true
      }
    }
# send to output 
ConvertFrom-Csv $output | Format-Table

# Now determine the Compliance Policy that is applied to the image 
$policies = @() #reset and reuse array
$request = "$tlconsole/api/v1/policies/compliance"
$compliances = Invoke-RestMethod $request -Authentication Basic -Credential $cred -SkipCertificateCheck
# Pull out the compliance rule names in order
$rules = $compliances[0].rules
$i = 0 
foreach ($rule in $rules)
    {
    # put the policies name into an array and a hash table as well so we can index it when we go to examine the policies.
    # have to do the array for the policy names to keep the order of the rule application.
    # the hash table flips it, if you can tell me how to do it with just the hash table, submit a PR please.
    $tmp = $rule[0].name
    $policies += $tmp
    $compliancePolicies.$tmp = $i
    $i++
    }

# find the rule that applies to the image 
$policyMatch = [bool]$false
$matchingPolicy = ""
foreach($policy in $policies)
    {
    $request = "$tlconsole/api/v1/policies/compliance/impacted?ruleName=$policy&search=$imageid"
    $returnedImpact = Invoke-RestMethod $request -Authentication Basic -Credential $cred -SkipCertificateCheck
    if($returnedImpact.count -eq 1)
        {
        $matchingPolicy = $policy
        $policyMatch = [bool]$true
        break
        }        
    } # end of foreach policy

if(!$policyMatch)
    {
    write-host "No compliance policies match, odd the Default Rule should apply, exiting"
    exit(1)
    }

# now determine the effect of the rule
write-host ""
write-host "Matching Compliance Policy: $matchingPolicy"

# Create a hash table of all the compliance checks, this way we will have the description of each check
# Iterate through all the checks and build out the hash table
$request = "$tlconsole/api/v1/static/vulnerabilities"
$return = Invoke-RestMethod $request -Authentication Basic -Credential $cred -SkipCertificateCheck
foreach($compliance in $return.complianceVulnerabilities)
{
    $complianceChecks += @{[string]$compliance.id = $compliance.title,$compliance.description}
}

# Get the compliance findings for the image
$complianceVulnerabilities = $image[0].info.complianceVulnerabilities

# find the rule in the existing $returnedRules and determine the effect
$TLComplianceBlock = [bool]$false
$conditions = $rules[$compliancePolicies.$matchingPolicy].condition.vulnerabilities
$i = 1 # counter to help with the output formating
foreach ($condition in $conditions)
    {
    # only process image checks, checks that start with either "4" or "9"
    $strCheckId = [string]$condition.id
    if($imageChecks.Contains($strCheckId.Substring(0,1)))
        {
        # it is an image check, process
        # remove "," from the rule description
        $checkRule =  $complianceChecks.$strCheckId
        $checkRule = $checkRule.replace(',','')
        # go through all the compliance failures in the $image return
        foreach($complianceVulnerability in $complianceVulnerabilities)
            {
            if($complianceVulnerability.id -eq $condition.id)
                {
                if($condition.block)
                    {
                    #only failed results are within the image report, so if the rule is Block then deployment will fail
                    $outputCompliance = $outputCompliance +$i+") "+$checkRule+","+$condition.block+",True"+$newline
                    $TLComplianceBlock = [bool]$true
                    }
                else {
                    $outputCompliance = $outputCompliance +$i+") "+$checkRule+","+$condition.block+",False"+$newline
                    }
                $i++
                } #end if rules apply
            # no need for an else here
            } # end for each $image compliance vulnerabilityk 
        } # end if checks match
    } # end for each Compliance Rule Condition

# output the compliance findings 
ConvertFrom-Csv $outputCompliance | Format-Table

# Display if either Vulnerability or Compliance rule will block the image becoming a container
# $LASTEXITCODE will give you the exit code Block = exit(1), Passed = exit(0)
if($TLBlock -or $TLComplianceBlock)
    {
    write-host "*** Twistlock will block this image from running as a container on nodes running the Twistlock Defender ***"
    write-host ""
    exit (1)
    }
else {
    # clean exit
    exit(0)
    }
