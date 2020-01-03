* For assistance with deploying the Twistlock container Defender on Azure Windows Service Fabric.
 * https://azure.microsoft.com/en-us/services/service-fabric/
* The primary issue is that the Container Defender requires Docker to be be running on the host before the Service will start.  Service Fabric runs the Docker Service without using the standard Windows Service mechanism. Therefore when the Twistlock Container Defender starts it will fail due to the requirement for the docker service to be running.

* The fix is to pull down the defender.ps1 file and remove the requirement.  This script is an example of these steps.