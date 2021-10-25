## Windows Host Defender PowerShell Automated Deployment Script

## CONFIGURATION

# The Console API to use to download the Windows Host Defender PowerShell - Installation - Script.
#
# For Prisma Cloud SaaS, use: Compute > Manage > System > Utilities > Path to Console
#   Example: "https://example.cloud.twistlock.com/ex-1-123456789"
#
# For Prisma Cloud Compute (On-Premise) see: https://prisma.pan.dev/api/cloud/cwpp/how-to-eval-console#for-self-hosted-installations
#   Example: "https://twistlock.example.com" or "https://twistlock.example.com:8083"

$console = "https://example.cloud.twistlock.com/ex-1-123456789";

# The credentials to use to access the Console API.
# Either the username / password (or, preferably, the access key / secret key) of a user with permissions to deploy Defender.

$user = "username_or_accesskey";
$pass = "password_or_secretkey";


# Set Proxy if needed for internet access 
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -name ProxyServer -Value "http://hostname:port" # http://proxy.xxxx.xxxx:port
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -name ProxyEnable -Value 1 # Enable or disable

# The hostname (or address) that the Windows Host Defender will use to connect to the Console.
#
# For Prisma Cloud SaaS, specify the hostname from the '$console' variable defined above.
#   Example: "example.cloud.twistlock.com"
#
# For Prisma Cloud Compute (On-Premise) use one of: Console > Manage > Defenders > Names
#   Example: "twistlock.example.com"

$consoleCN = "example.cloud.twistlock.com"

## EXECUTION

# The following code is extracted from the Console, changing the Header in $parameters from a Bearer Token to Basic Authentication.
# See: Compute > Manage > Defenders > Deploy > Defenders > Single Defender > Host Defender - Windows > Use the following script to install a Defender on a host

# Define the parameters used by Invoke-WebRequest.

$parameters = @{
  Uri     = "$console/api/v1/scripts/defender.ps1";
  Method  = "Post";
  Header  = @{ Authorization = "Basic {0}" -f [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $user,$pass))) };
  # Proxy info below if needed
  Body    = '{"proxy":{"httpProxy":"http://host:port,"ca":"","user":"","password":"","noProxy":"169.254.169.254"}}';
  OutFile = "defender.ps1";
};

# Define certificate checking for Invoke-WebRequest.

if ($PSEdition -eq 'Desktop') {
  add-type " using System.Net; using System.Security.Cryptography.X509Certificates; public class TrustAllCertsPolicy : ICertificatePolicy{ public bool CheckValidationResult(ServicePoint srvPoint, X509Certificate certificate, WebRequest request, int certificateProblem) { return true; } } ";
  [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy;
} else {
  $parameters.SkipCertificateCheck = $true;
}

# Download the Windows Host Defender PowerShell Installation Script.

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest @parameters;

# Execute the downloaded Windows Host Defender PowerShell Installation Script.

.\defender.ps1 -type serverWindows -consoleCN $consoleCN -install 

# Note that the downloaded PowerShell Installation Script contains parameters specific to this deployment.


# UnSet Proxy if set above
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -name ProxyServer -Value "" # http://proxy.xxxx.xxxx:port
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings' -name ProxyEnable -Value 0 # Enable or disable