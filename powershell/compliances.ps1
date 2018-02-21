# We want to call the container API to get all
# of the runtime models
$request = "https://console:8083/api/v1/images?search=<image_name>"
# We will need credentials to connect so we will ask the user
# $cred = Get-Credential

# Step 1. Create a username:password pair
$credPair = "admin:Passwordhere"
# Step 2. Encode the pair to Base64 string
$encodedCredentials = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($credPair))
# Step 3. Form the header and add the Authorization attribute to it
$headers = @{ Authorization = "Basic $encodedCredentials" }

  # Get the JSON data back from Twistlock and turn it
# into a PowerShell object.
$images = Invoke-RestMethod $request -Headers $headers -UseBasicParsing


#$images = Invoke-RestMethod $request -Authentication Basic -Credential $cred
# Answer the question 
foreach($image in $images)
{
    $image._id
    $image.instances.image
    $image.info.complianceVulnerabilities | Select-Object id, severity, cvss, description
}