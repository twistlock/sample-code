#
# Title: OpenShift (OSE) Internal Registry to Twistlock Registry Scanner Populator
# 
# Purpose:
# This script queries OpenShift for all the images within each Project's Image Stream. 
# Then calls the Twistlock API to create a Defender > Vulnerabilities > Registry entry for each repository
#
# Background: 
# The OpenShift Internal Registry currently does not support the Docker v2 Registry catalog API call. 
# Therefore all repositories need to be added into Twistlock to scan the images within the OpenShift Internal Registry.
# RedHat will be adding the catalog API call in v3.11 https://trello.com/c/AZINw5qI
#
# Update 20190808 - modified for the New Twistlock v19_07+ API settings/registry call and multiple Defender scanners
# Update 20190410 - modified for the new Twistlock v18_11+ API call for the Twistlock Credential Store and the use of the credential in the Defend > Vulnerabilities > Registry entry
# 
# Requirements:
#  - Twistlock v19_07+
#  - OpenShift v3.6+, authenticated to cluster and OSE CLI (oc) access 
#  - Powershell v6 https://blogs.msdn.microsoft.com/powershell/2018/01/10/powershell-core-6-0-generally-available-ga-and-supported/ runs on MacOS and Linux!
# 
# Twistlock Service Account Password:
# Twistlock creates a Service Account that has associated Docker Secrets to authenticate to the internal OSE registry
# Put this password into the $TL_service_account_password variable 
# 1) Give the Twistlock Service account the right to read the OpenShift registry: oc adm policy add-cluster-role-to-user system:image-puller system:serviceaccount:twistlock:twistlock-service
# 2) oc describe sa twistlock-service -n twistlock 
# 3) oc describe secret twistlock-service in the secret, note the username (serviceaccount) and the password (a very long string, ends before "email") copy the password string into the $TL_service_account_password variable 
# Note: Some versions of OpenShift will not return the whole password. Use the OSE Console to pull the password Twistlock_Project -> Resources -> Secrets -> twistlock-service-dockercfg-<string> -> Show Annotations -> openshift.io/token-secret.value -> See All
# 
#
# Discalimer: Use of this script does not imply any rights to Twistlock products and/or services.

# variables
# Endpoint of the Twistlock API
$twistlock_API = "https://twistlock.example.com"
# Twistlock Service Account password. See notes above on how to get the password
$TL_service_account_password = "<follow the instructions above on how to obtain the Twistlock service account's password>"
# registry address of the internal openshift registry, leave the "/" off the end of the string
$ose_internal_registry = "docker-registry.default.svc:5000"
# Name of the Twistlock Credential created
$TL_Credential = "OSE-Internal-Registry-Scanner" 
# Set to $true to remove all registry entries in 
$TL_flush_registry_settings = [bool]$false

# Make sure we can see the OSE cluster, check the default docker-registry route
if (!(oc get route docker-registry -n default))
    {
    write-host "Unable to connect to OpenShift Cluster, use oc login to authenticate to your cluster"
    exit    
    }
else {
    write-host "access to OpenShift Cluster confirmed"
    }

# Pull all the projects
$project_names = @()
$projects = oc get projects --output=json | ConvertFrom-Json
foreach($project in $projects.items)
    {
    $project_names += $project.metadata.name
    }
 
# list all the images within each project's image stream   
$internal_registry_images = @()
foreach($project in $project_names)
    {
    $images = oc get is -n $project --output=json | ConvertFrom-Json  
    foreach($image in $images.items)
        {
        # why can't I trim up to the :5000/, it trims the "o" in openshift
        # for now leave it on and then trim "/" when generating the input json
        $internal_registry_images += $image.status.dockerImageRepository.TrimStart($ose_internal_registry)   
        }
    }

# Images to be loaded into Twistlock
write-host "The following OpenShift internal registry repositories will be added into Twistlock:"
$internal_registry_images

# Call the Twistlock API to load in the registry scanner information
# We will need credentials to connect so we will ask the user
$cred = Get-Credential

# Create the Twistlock Credential for the ServiceAccount
# build the json payload for the API call            
$credentialStore = @{
 "accountID" = "serviceaccount"
 "secret" = @{"plain" = $TL_service_account_password}
  "type" = "basic"
  "_id" = $TL_Credential
}

# convert to json
$json_payload += $credentialStore| ConvertTo-Json -Depth 4 

# Call the API
$request = "$twistlock_API/api/v1/credentials"
$header = @{"Content-Type" = "application/json"}
Invoke-RestMethod $request -Authentication Basic -Credential $cred -AllowUnencryptedAuthentication -SkipCertificateCheck -Method "Post" -Header $header -Body $json_payload

#status output
write-host "Created credential: $TL_Credential"

# For each image build the json for the registry scanning entry
$subbody = @()
foreach($image in $internal_registry_images)
    {
    # build the json payload for the API call            
    $tmp = @{
        "version" = "redhat"
        "registry" = $ose_internal_registry
        "credential" = @{"_id" = $TL_Credential}
        "useAWSRole" = $false
        "os" = "linux"
        "cap" = 5
        # trim the "/" from the begining of the namesapce/repository, don't know why it doesnt trim properly in the earlier trim
        "repository" = $image.TrimStart("/")
        "scanners" = 2
        }
    $subbody += $tmp 
    } # end building payload of the input json
    
    # now build the specification json structure
    if(!$TL_flush_registry_settings)
        {
        $body = @{
            "specifications" = @(
            $subbody
            )
            }
        }
    else
        {
        # flushing registry entries
        $body = @{
            "specifications" = @()
            }
        } 

# convert to json
$json_payload = $null
$json_payload += $body | ConvertTo-Json -Depth 4 

# Call the API
$request = "$twistlock_API/api/v1/settings/registry"
$header = @{"Content-Type" = "application/json"}
Invoke-RestMethod $request -Authentication Basic -Credential $cred -AllowUnencryptedAuthentication -SkipCertificateCheck -Method "Put" -Header $header -Body $json_payload 

#status output
if(!$TL_flush_registry_settings)
    {
    write-host "Created" $subbody.count "registry entries"
    }
else
    {
    write-host "All registry entries in Defend > Vulnerabilities > Registry have been removed."    
    }
