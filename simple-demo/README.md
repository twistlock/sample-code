## Prisma Cloud NoteMaker Simple as Possible Demo (SAP)

### Prerequisites
1. You have setup a kubernetes or Openshift cluster and have kubectl or oc project access to your cluster
2. You have installed Prisma Cloud DefenderDS into your cluster
3. Your kubernetes environment supports LoadBalancer services (non Openshift)
3. For OpenShift4 using RHCOS, create a soft link in your exe path so that docker will execute podman

### Setup
0. Agree to call this code's root folder locaation ROOT_FLDR
1. Add `./scripts:./:{ROOT_FLDR}/scripts` to your PATH
2. Copy appropriate TEMPLATE_use* file for your target environment (removing TEMPLATE_)
3. Fill in credentials and URL's into appropriate use* script in scripts/setup*, either self hosted or SaaS 
4. Source proper script   `$ source useSaaS` (or useSelfHosted) 
5. for CI/CD go to notemaker/build and run buildReleaseAll without options to see usage
6. for deployment go to {ROOT_FLDR}/notemaker/deploy and run `initialDeploy 1.0`
	* run them from notemaker/deploy folder
    * again, run script without any parameters to see usage
    * check out other scripts available in notemaker/deploy/scripts folder
    
7. Container focused pen tests are in notemaker/pentest, check README.md file at that location for instructions 

### Recording of SAP Demo available
 https://paloaltonetworks.hosted.panopto.com/Panopto/Pages/Viewer.aspx?id=4e4bd448-849e-4be7-ab7b-abc80016ac99

### How to leverage SAP Demo to demo all core features in Prisma Cloud Compute
Consider a typical CI/CD pipeline - Dev, Build, Share (registry), Test, Deploy

Using a command shell that has kubectl access to your cluster (or oc)
* Dev - cd to {ROOT_FLDR}/notemaker/build, run `testForCommitRediness secure`
* Build - cd to /build, run `buildReleaseAll 1.0 allsecure`
* Share - connect notemaker* registry to your Prisma Cloud Console
* Test/Deloy
   - show security posture with runtime radar and Monitor/Vulnerabilities/VulnerabilityExplorer
   - cd to {ROOT_FLDER}/notemaker/pentest to show durability of deployment by running conatinerized pentests - see README.md in that folder for instructions 

