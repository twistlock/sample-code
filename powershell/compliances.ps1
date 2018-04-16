param ($arg1)

if(!$arg1)
    {
    write-host "Scanning all images"
    }
else 
    {
    write-host "Scanning $arg1"
    }

# variables
$console = pfox-ansible-console.lab.twistlock.com
$port = 8083

# We want to call the images API
# The search parameter ("?search=<image_name>") is optional
if(!$arg1)
    {
    $request = "https://pfox-ansible-console.lab.twistlock.com:8083/api/v1/images"
    }
else 
    {
    $request = "https://pfox-ansible-console.lab.twistlock.com:8083/api/v1/images?search$arg1"
    }

# We will need credentials to connect so we will ask the user
$cred = Get-Credential

# Get the JSON data back from Twistlock and turn it
# into a PowerShell object.
$images = Invoke-RestMethod $request -Authentication Basic -Credential $cred

# Iterate through all the images returned 
foreach($image in $images)
{
    # For each image, output the image ID and the 
    $image._id
    $image.instances.image
    
    # Output compliance issues for this image in a table
    $image.info.complianceVulnerabilities | Select-Object id, severity, cvss, description
}
