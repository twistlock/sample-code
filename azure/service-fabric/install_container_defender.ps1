# Set credentials for the initial API call to authenticate endpoint, going forward you will use the token returned.
$params = @{“username”=“<Username>”;“password”=“<password>”;}

# Address to the Console
$console = 'https://<console-addr>:8083'

# authenticate Endpoint
$request = $console + '/api/v1/authenticate'

# Initial request for token and save into variable
add-type "using System.Net; using System.Security.Cryptography.X509Certificates; public class TrustAllCertsPolicy : ICertificatePolicy{ public bool CheckValidationResult(ServicePoint srvPoint, X509Certificate certificate, WebRequest request, int certificateProblem) { return true; }}"; [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy;

$response = Invoke-WebRequest $request  -Body ($params|ConvertTo-Json) -ContentType "application/json" -Method POST
$token =  ConvertFrom-Json $([String]::new($response.Content))

# Windows Defender endpoint and call
$request2 = $console + '/api/v1/scripts/defender.ps1'
Invoke-WebRequest $request2 -Headers @{"authorization" = 'Bearer ' + $token.token } -OutFile defender.ps1;

# file will be saved as defender.ps1 in the current directory

#remove docker engine prerequisite
(Get-Content -path defender.ps1) -replace ' -DependsOn "docker"' | Set-Content -Path defender.ps1

#Install Twistlock
.\defender.ps1 -type dockerWindows -consoleCN <console-addr> -install


