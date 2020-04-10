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
# Update 20200409 - updated for the v20.04.163 api. This accounts for images scanned as part of the CI process (jenkins and twistcli).
# For example, you want to know what rules will impact an image in the CI process when moved to ship and run. Answering "will this image be allowed to run based upon vulneraiblity and compliance policies"
# The json structure for the CI images ($ciImage flag) is accounted for in the script. 
#
#  Requires: powershell v6 https://blogs.msdn.microsoft.com/powershell/2018/01/10/powershell-core-6-0-generally-available-ga-and-supported/
#  Discalimer: Use of this script does not imply any rights to Twistlock products and/or services.
# 
#  Usage: ./tl-rsop.ps1 <name of image>
#
# Debugging: $debugpreference = "continue" at the powershell command prompt for detailed output of the script 
# 
# Updates: 
# 2019-10-30 adjusted for the Twistlock v19.07 API changes
# 2019-11-26 updated for Prisma Cloud v19.11 API changes
# 2020-04-09 updated for Prisma Cloud Compute Edition 20.04.163, additional logic to evaluated CI images against runtime policies

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
$vulnPolicies = @{} # Hash table of the vulnerability policy name and the order in which it is applied
$vulnResources = @{} # Hash table of the rules' image filters
$policies = @() # Array of policy names
$compliancePolicies = @{} # Hash table of the compliance policy name and the order in which it is applied
$complianceResources = @{} # Hash table of the rules' image filters
$imageChecks = [string] @(4,9,5) # The type of compliance checks that apply to images
$foundImage = [bool]$false
$policyMatch = [bool]$false
$ciImage = [bool]$false
$newline = [environment]::newline
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
        }

# Search for image in CI Scans
if(!$foundImage)
    {
    $request = "$tlconsole/api/v1/scans?search=$arg1&type=ciImage"
    $image = Invoke-RestMethod $request -Authentication Basic -Credential $cred -SkipCertificateCheck
    if($image.count -eq 1)
        {
        $foundImage = [bool]$true
        write-host "Found image found in CI Scans"
        $imageid = $image.entityInfo.id
        $ciImage = [bool]$true
        }   
    elseif ($image.count -gt 1)
        {
        write-host "found more than 1 image that matches that name, please narrow your search"
        exit
        }
    else
        {
        write-host "Did not find image in CI Scans"
        exit
        }
    }
   
} # end if !foundImage search registry for base image

# Output the image found
write-host ""
write-host "Found: $arg1"
write-host "ImageID: $imageid"

# Break out the vulnerabilities
# Determine the lowest severity level this will be used to determine if the block rule is applied
# updated for v20.04 api 
write-host ""
write-host "Vulnerabilities:"
if($ciImage)
    {
    write-host "`tCritical: "$image.entityInfo.vulnerabilityDistribution.critical
    write-host "`tHigh: "$image.entityInfo.vulnerabilityDistribution.high
    write-host "`tMedium: "$image.entityInfo.vulnerabilityDistribution.medium
    write-host "`tLow: "$image.entityInfo.vulnerabilityDistribution.low
    }
else
    {
    write-host "`tCritical: "$image[0].vulnerabilityDistribution.critical
    write-host "`tHigh: "$image[0].vulnerabilityDistribution.high
    write-host "`tMedium: "$image[0].vulnerabilityDistribution.medium
    write-host "`tLow: "$image[0].vulnerabilityDistribution.low
    }

# Now query the API to determine which Defend > Policy > Vulnerabilities > Policy rule applies to the image
# and what is the Action is Alert or Block
$request = "$tlconsole/api/v1/policies/vulnerability/images"
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
    # Filter out the disabled=True policies

    # 20200409 - Since the /api/v1/policies/vulnerability/images/impacted api does not work for CI images
    # We want to be able to know what the resultant policy for an image built via the CI process
    # put the rule's Resources Images into a comma seperated sting. Then add into the $vulnResources hash table
    # then if ciImages = True we will associate the image to the rule via this method
   if($rule[0].disabled -ne "True")
        {
        # pull out the image filters
        $tmpResources = ""
        $filter =  $rule[0].resources.images
        foreach($flt in $filter)
            {
            $tmpResources = $tmpResources + $flt + ","
            }
        # build the array and hash tables
        $tmp = $rule[0].name
        $policies += $tmp
        $vulnPolicies.$tmp = $i
        $vulnResources.$tmp = $tmpResources
        $i++
        }
    else
        {
        # increment the counter because we use the $rules return array to determine which policy rules to apply
        # this way the hash table of the of the vulnPolicies will match the number of the rules array   
        $i++
        }
    }
# Debug: output the hash table of "enabled" vulnerability policies    
write-debug "Array of enabled vulnerability Policy names"
write-debug ($policies|Out-String)
write-debug "Policy hash table for rule orders:"
write-debug ($vulnPolicies|Out-String)
write-debug "Policy hash table of ACLed images, used for CI images:"
write-debug ($vulnResources|Out-String)

# If this is a CI images match based upon the vulResources hash table filters
# else
# call impacted API to see if the rule applies to this image
$matchingPolicy = ""
:top foreach($policy in $policies)
    {
    if($ciImage)
        {
        $tmpArray = $vulnResources.$policy -split ","
        :botton foreach($tm1 in $tmpArray)
            {
            #$tm1 = $tm1.Replace('*','')
            if($arg1 -like $tm1)
                {
                $debug_out = "CI Image vulnerability policy match policy = $policy : Image filter = $tm1"
                write-debug $debug_out
                $matchingPolicy = $policy
                $policyMatch = [bool]$true
                break top
                }
            }
        }
    else
        {
        $request = "$tlconsole/api/v1/policies/vulnerability/images/impacted?ruleName=$policy&search=$imageid"
        $returnedImpact = Invoke-RestMethod $request -Authentication Basic -Credential $cred -SkipCertificateCheck
        if($returnedImpact.count -eq 1)
            {
            $matchingPolicy = $policy
            $policyMatch = [bool]$true
            break top
            }
        }        
    } # end of foreach policy

# Did we find a matching policy?
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
$conditions = $rules[$vulnPolicies.$matchingPolicy].blockThreshold

# Debug output 
$debug_out = "Rule: " +$rules[$vulnPolicies.$matchingPolicy].name
write-debug $debug_out
$debug_out = "Blocking: " + $conditions.enabled
write-debug $debug_out
$debug_out = "Block threshold: " + $conditions.value
write-debug $debug_out

# Account for the different json structure for CI images
if(($conditions.enabled -eq "True") -and $ciImage)
    {
    switch($conditions.value)
        {
        9 {if([int]$image.entityInfo.vulnerabilityDistribution.critical -gt 0){$TLBlock = [bool]$true}}
        7 {if(([int]$image.entityInfo.vulnerabilityDistribution.high -gt 0) -or ([int]$image.entityInfo.vulnerabilityDistribution.critical -gt 0)){$TLBlock = [bool]$true}}
        4 {if(([int]$image.entityInfo.vulnerabilityDistribution.medium -gt 0) -or ([int]$image.entityInfo.vulnerabilityDistribution.high -gt 0) -or ([int]$image.entityInfo.vulnerabilityDistribution.critical -gt 0)){$TLBlock = [bool]$true}}
        1 {if(([int]$image.entityInfo.vulnerabilityDistribution.low -gt 0) -or ([int]$image.entityInfo.vulnerabilityDistribution.medium -gt 0) -or ([int]$image.entityInfo.vulnerabilityDistribution.high -gt 0) -or ([int]$image.entityInfo.vulnerabilityDistribution.critical -gt 0)){$TLBlock = [bool]$true}}
        }
    }
elseif($conditions.enabled -eq "True")
    {
    switch($conditions.value)
        {
        9 {if([int]$image[0].vulnerabilityDistribution.critical -gt 0){$TLBlock = [bool]$true}}
        7 {if(([int]$image[0].vulnerabilityDistribution.high -gt 0) -or ([int]$image[0].vulnerabilityDistribution.critical -gt 0)){$TLBlock = [bool]$true}}
        4 {if(([int]$image[0].vulnerabilityDistribution.medium -gt 0) -or ([int]$image[0].vulnerabilityDistribution.high -gt 0) -or ([int]$image[0].vulnerabilityDistribution.critical -gt 0)){$TLBlock = [bool]$true}}
        1 {if(([int]$image[0].vulnerabilityDistribution.low -gt 0) -or ([int]$image[0].vulnerabilityDistribution.medium -gt 0) -or ([int]$image[0].vulnerabilityDistribution.high -gt 0) -or ([int]$image[0].vulnerabilityDistribution.critical -gt 0)){$TLBlock = [bool]$true}}
        }
    }
else
    {
    write-debug "Vulnerability Policy does not have a Block threshold"
    }

# Output vulnerability result
if($TLBlock)
    {
    write-host "Vulnerability Policy Fail: image will be blocked"
    }
else
    {
    write-host "Vulnerability Policy Pass"    
    }

# Now determine the Compliance Policy that is applied to the image 
$policies = @() #reset and reuse array
$request = "$tlconsole/api/v1/policies/compliance/container"
$compliances = Invoke-RestMethod $request -Authentication Basic -Credential $cred -SkipCertificateCheck
# Pull out the compliance rule names in order
$rules = $compliances[0].rules
$i = 0 
foreach ($rule in $rules)
    {
    # put the policies name into an array and a hash table as well so we can index it when we go to examine the policies.
    # have to do the array for the policy names to keep the order of the rule application.
    # the hash table flips it, if you can tell me how to do it with just the hash table, submit a PR please.
    # 20200409 - updated for v20.04.163 api
    # pull out the image filters
     if($rule[0].disabled -ne "True")
        {
        $tmpResources = ""
        $filter =  $rule[0].resources.images
        foreach($flt in $filter)
            {
            $tmpResources = $tmpResources + $flt + ","
            }
        $tmp = $rule[0].name
        $policies += $tmp
        $compliancePolicies.$tmp = $i
        $complianceResources.$tmp = $tmpResources
        $i++
        }
    }

# Debug: output the hash table of "enabled" compliance policies    
write-debug "Array of enabled compliance Policy names"
write-debug ($policies|Out-String)
write-debug "Policy hash table for rule orders:"
write-debug ($compliancePolicies|Out-String)
write-debug "Policy hash table of ACLed images, used for CI images:"
write-debug ($complianceResources|Out-String)

# find the rule that applies to the image 
$policyMatch = [bool]$false
$matchingPolicy = ""
:top foreach($policy in $policies)
    {
    if($ciImage)
        {
        $tmpArray = $complianceResources.$policy -split ","
        :botton foreach($tm1 in $tmpArray)
            {
            if($arg1 -like $tm1)
                {
                $debug_out = "CI Image compliance policy match policy = $policy : Image filter = $tm1"
                write-debug $debug_out
                $matchingPolicy = $policy
                $policyMatch = [bool]$true
                break top
                }
            }
        }
    else
        {
        $request = "$tlconsole/api/v1/policies/compliance/container/impacted?ruleName=$policy&search=$arg1"
        $returnedImpact = Invoke-RestMethod $request -Authentication Basic -Credential $cred -SkipCertificateCheck
        if($returnedImpact.count -eq 1)
            {
            $matchingPolicy = $policy
            $policyMatch = [bool]$true
            break top
            }
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
# 20200409 - v20.04.163 api, CI images have a difference json structure 
if($ciImage)
    {
    $complianceVulnerabilities = $image.entityInfo.complianceIssues
    }
else
    {
    $complianceVulnerabilities = $image[0].complianceIssues
    }

# find the rule in the existing $returnedRules and determine the effect
$TLComplianceBlock = [bool]$false
$conditions = $rules[$compliancePolicies.$matchingPolicy].condition.vulnerabilities
    
foreach ($condition in $conditions)
    {
    # only process image checks, checks that start with either "4", "5" or"9"
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
