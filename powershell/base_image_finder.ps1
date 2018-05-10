#  
#  Queries Twistlock API to determine the association of all images to the image supplied via the input parameter.
#  Outputs an CSV file yyyyMMdd-HHmmss-base-image-search.csv
#  Relationship of images:
#  "master" - image provided as the search image. Only one instance of this image can be returned by the API otherwise the program will exit.
#  "child" - the image has more layers than the "master" image and the master's base layers match.
#  "parent" - the image has less layers than the "master" image and the parent's base layers match.
#  "no-association - the image's first layer does not match.
#  
#  Requires: Twistlock v2.4
#  Requires: powershell v6 https://blogs.msdn.microsoft.com/powershell/2018/01/10/powershell-core-6-0-generally-available-ga-and-supported/
#  Discalimer: Use of this script does not imply any rights to Twistlock products and/or services.
# 
#  Usage: ./base_image_finder.ps1 <name of image>

param($arg1)

if(!$arg1){
  write-host "Usage: ./base_image_finder.ps1 <name of image>"
  exit
  }
else{
  write-host "Searching for" $arg1
  }

#
# Function formatOutput
# Returns an CSV formated string with the image assocation and location
#
function formatOutput([array]$image,[string]$relationship)
  {
  $newline = [environment]::newline
  $formatOutputString=""
  foreach($instance in $image.instances)
    {
    # if the image._id starts with sha256: the image is on a host
    if($image._id.StartsWith("sha256:"))
      {
      $formatOutputString = $formatOutputString+$relationship+","+$instance.image+",host,"+$instance.host+$newline
      }
    else
       {
       # image is in a registry
       $formatOutputString = $formatOutputString+$relationship+","+$instance.image+",registry,"+$instance.registry+"/"+$instance.repo+":"+$instance.tag+$newline
       }   
    }
  return $formatOutputString 
  } # end function

#
# Main
#
# Variables
$tlconsole = "https://<fqdn_of_your_twistlock_console>:8083"
$foundBaseImage = [bool]$false
$baseImageLayers = @()
$newline = [environment]::newline
$outputCSV = "relationship,image,host-or-registry,location"+$newline
$time = Get-Date -f "yyyyMMdd-HHmmss"


# We will need credentials to connect so we will ask the user
$cred = Get-Credential

# Search for the base image by name (input argument) in both the images and registry API
$request = "$tlconsole/api/v1/images?search=$arg1"

# Get the JSON data back from Twistlock and turn it
# into a PowerShell object.
$images = Invoke-RestMethod $request -Authentication Basic -Credential $cred

# Make sure only one image was found 
if($images.count -eq 1)
    {$foundBaseImage = [bool]$true
    write-host "Found base image found on a docker host"
    $baseImage = $images[0]
    }
elseif ($images.count -gt 1)
    {
    write-host "found more than 1 image that matches that name, please narrow your search"
    exit
    }
else {
    write-host "Did not find base image on docker hosts"
    }

# Search images within the registry, if it was not found on the docker host
if(!$foundBaseImage){
    $request = "$tlconsole/api/v1/registry?search=$arg1"
    $registry = Invoke-RestMethod $request -Authentication Basic -Credential $cred
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
        write-host "Did not find base image in a registry"
        exit
        }

} # end if !foundBaseImage search registry for base image

# Inspect the base image and put the image layers into an array
write-host ""
write-host "Base image name:`t"$arg1
write-host "ID:`t`t`t"$baseImage._id
write-host "Last scan:`t`t"$baseImage.scanTime
write-host "Layers:"
$baseImageLayers = $baseImage.info.layers
foreach($layer in $baseImageLayers)
    {
    write-host $layer
    }

# query for all images on the docker host & registry
write-host ""
write-host "Scanning Images and Registry...."
$request = "$tlconsole/api/v1/images"
$images = Invoke-RestMethod $request -Authentication Basic -Credential $cred
$request = "$tlconsole/api/v1/registry"
$images += Invoke-RestMethod $request -Authentication Basic -Credential $cred
write-host "Images found: "$images.count

# go through the array and find each image's association
foreach($image in $images)
    {
    # check the first layer, if they match do a full compare
    if($baseImageLayers[0] -eq $image.info.layers[0])
        {
        # assume match and prove otherwise
        $match = [bool]$true
        
        # if the number layers are equal this is the image you are using to search. Make sure the layers match
        if($baseImageLayers.count -eq $image.info.layers.count)
            {
            for($x=0; $x -le $baseImageLayers.count; $x++)
                {
                if($baseImageLayers[$x] -ne $image.info.layers[$x])
                    {
                    write-host "Base layers do not match - equal layers"
                    $match = [bool]$false
                    }
                } #end foreach layer in the image
            if($match)
                {
                $outputCSV = $outputCSV + (formatOutput $image "master")
                }
              else
                {
                # no match on the base layer
                $outputCSV = $outputCSV + (formatOutput $image "no-association")
                }
            }
        elseif($baseImageLayers.count -lt $image.info.layers.count)
            {
            # more layers than the base image
            for($x=0; $x -lt $baseImageLayers.count; $x++)
                {
                if($baseImageLayers[$x] -ne $image.info.layers[$x])
                    {
                    write-host "Base layers do not match - base layers < image layers"
                    $match = [bool]$false
                    }
                } #end foreach layer in the image
            if($match)
                {
                $outputCSV = $outputCSV + (formatOutput $image "child")
                }
              else
                {
                # no match on the base layer
                $outputCSV = $outputCSV + (formatOutput $image "no-association")
                }
            }
        elseif($baseImageLayers.count -gt $image.info.layers.count)
            {
            # there is a base image to the image scanning with
            for($x=0; $x -lt $image.info.layers.count; $x++)
                {
                if($baseImageLayers[$x] -ne $image.info.layers[$x])
                    {
                    write-host "Base layers do not match - base layers > image layers"
                    $match = [bool]$false
                    }
                } #end foreach layer in the image
            if($match)
                {
                $outputCSV = $outputCSV + (formatOutput $image "parent")
                }
              else
                {
                # no match on the base layer
                $outputCSV = $outputCSV + (formatOutput $image "no-association")
                }
            }
        else
            {
            # should not get to this point
            write-host "something ain't right"
            }
        } #first layer matches
        else 
            {
            # no match at the base layer
            $outputCSV = $outputCSV + (formatOutput $image "no-association")
            }
    } # end foreach


#
# Output
#
$outputFile = $time+"-base-image-search.csv"
$outputCSV | Out-File -FilePath .\$outputFile -Encoding ASCII
write-host "Output file name:" $outputFile
