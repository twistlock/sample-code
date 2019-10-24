# Important OpenShift v3.11 Customers
RedHat has now incorporated the Docker v2 */api/_catalog* call to the [OpenShift v3.11 internal registry](https://bugzilla.redhat.com/show_bug.cgi?id=1509084).
You do not have to use the tl_ose_internal_registry_populator program to populate your Twistlock Console with OpenShift ImageStream entries.
To configure Twistlock scanning of the OpenShift v3.11 internal registry perform the following steps:
- Give the cluster role permission of [registry-viewer](https://docs.openshift.com/container-platform/3.11/install_config/registry/accessing_registry.html#access) to the twistlock-service account ```oc adm policy add-cluster-role-to-user registry-viewer system:serviceaccount:<twistlock_project>:twistlock-service```

- Obtain the password for the *twistlock-service* account
  - ```oc describe sa twistlock-service -n <twistlock_project>```
  - Use the *Image pull secrets* value (e.g. twistlock-service-dockercfg-64jtt) in the following command, for example ```oc get secret twistlock-service-dockercfg-64jtt -n twistlock --output=json|grep openshift.io/token-secret.value```
  - Copy the returned *openshift.io/token-secret.value*


- In the Twistlock Console go to Manage > Authentication > Credential Store : click **Add credential**
  - Name: **OSE-Internal-Registry-Scanner**
  - Type: **Basic Credential**  
  - Username: **serviceaccount**
  - Password: _twistlock-service account password obtained in last step_
- Click **Save**

- In the Twistlock Console go to Defend > Vulnerabilities > Registry : click **Add registry**
    - Version: **Red Hat OpenShift**
    - Registry: **docker-registry.default.svc:5000**
    - Credential: **OSE-Internal-Registry-Scanner**
    - OS Type: **Linux**
    - Scanner: **Automatic**
    - Number of scanners: **2**
    - Cap: **5**
- Click **Save**

Twistlock will now begin the scanning of all the images via the internal OpenShift docker-registry service endpoint.


# README
This directory contains both compiled GoLang applications and a powershell script for the populating of images within the OpenShift internal registry into the Twistlock Console's Defend > Vulnerabilities > Registry settings.
The GoLang application has been compiled for the Linux, OSX and Windows operating systems.
The powershell script is provided for you to understand the process, API calls and provides the logic if you want to port to another language.
Powersell v6+ is now supported on the Windows, OSX and Linux operating systems. https://blogs.msdn.microsoft.com/powershell/2018/01/10/powershell-core-6-0-generally-available-ga-and-supported/

This program queries OpenShift for all the images within each Project's Image Stream.
Then calls the Twistlock API to create a Defend > Vulnerabilities > Registry entry for each repository.

Background:
The OpenShift Internal Registry currently does not support the Docker v2 Registry catalog API call.
Therefore all repositories need to be added into Twistlock to scan the images within the OpenShift Internal Registry.

## Releases / Updates

2019-08-08: Updated the Go binaries to support the API call with the new 19.07.353 release (changed the API call from POST to PUT and removed the definition of a defender so it gets auto selected).

2019-10-15: Updated guidance for using a least privileged account to authenticate to the OpenShift Cluster, enumerate the projects, associated image streams and obtain the twistlock-service account's password.

## GoLang

This Go program will do the following:
- Connect to OpenShift
- List all Projects within OpenShift
- Enumerate all images within each Project's ImageStream
- Determine the Twistlock Service account's password
- Calls Twistlock API to create a credential for the Twistlock Service account
- Calls Twistlock API to create Defend > Vulnerabilities > Registry entry for each repository in the OpenShift internal registry

### Prerequisites

- The program needs access to OpenShift Command Line Interface (oc)
- Give the Twistlock Service account the system:image-puller right in OpenShift  
 OpenShift v3.6: ```oc adm policy add-cluster-role-to-user system:image-puller system:serviceaccount:<twistlock_project>:twistlock-service```  
 OpenShift v3.10: ```oc policy add-role-to-user system:image-puller system:serviceaccount:<twistlock_project>:twistlock-service```  
 Check your OpenShift version's documentation. Otherwise Twistlock Registry scanning will error with 401 unauthorized.

### Using an OpenShift Least Privileged Account for Authentication
This program will authentication to the OpenShift Cluster (-ose) using the username (-oseUser) and password (-osePWD).
It is ideal to use a least privileged account to perform this task.
For example:
- Create an OpenShift account ```pierre```
- Assign the clusterrole ```view``` which allows the account to list all projects and the imageStreams within each project ```oc adm policy add-cluster-role-to-user view pierre```
- Create a role within the Twistlock project in which the account can "get" serviceaccounts within the project ```oc create role tl-get-sa --verb=get --resource=sa -n twistlock```
- Assign the account the role ```oc adm policy add-role-to-user tl-get-sa pierre --role-namespace=twistlock -n twistlock```
- Create a role within the Twistlock project in which the account can "get" the serviceaccount's password within the project ```oc create role tl-get-sa-pwd --verb=get --resource=secret -n twistlock```
- Assign the account the role ```oc adm policy add-role-to-user tl-get-sa-pwd pierre --role-namespace=twistlock -n twistlock```

### Executables
  - Linux ```tl_ose_internal_registry_populator_linux```
  - Mac OSX ```tl_ose_internal_registry_populator_macos```
  - Windows ```tl_ose_internal_registry_populator_windows.exe```

  - Command line arguments
```
./tl_ose_internal_registry_populator_macos --help
Usage of tl_ose_internal_registry_populator_macos:
-TLAuthPwd string
    Twistlock Authentication, password
-TLAuthToken string
    Twistlock Authentication, bearer token
-TLAuthUser string
    Twistlock Authentication, username
-TLConsole string
    URL to the Twistlock Console (default "https://localhost:8083")
-TLCredential string
    Name of the OpenShift Twistlock ServiceAccount entry created within Twistlock (default "OSE-Internal-Registry-Scanner")
-TLFlushRegistrySettings
    true = remove all registry entries in Twistlock Console's Defend > Vulnerabilities > Registry
-ose string
    URL to the OpenShift Management Console (default "https://localhost:8443")
-osePWD string
    OpenShift Management Console password
-oseProject string
    Twistlock Project in OpenShift (default "twistlock")
-oseRegistry string
    OpenShift internal registry, for http based connections http://docker-registry.default.svc:<http_endpoint> (default "docker-registry.default.svc:5000")
-oseToken string
    OpenShift Management Console token
-oseUser string
    OpenShift Management Console username
  ```

### Example

Authenticate to Twistlock using the user's Twistlock API bearer token and an OpenShift ServiceAccount (e.g. pierre).
The Twistlock-Console is running within the "twistlock" OpenShift Project.

- Command:

```
./tl_ose_internal_registry_populator_macos -ose https://master.openshift.example.com:8443 \
 -oseUser pierre \
 -osePWD <pierre_password> \
 -TLConsole https://tl-console.apps.openshift.example.com \
 -TLAuthToken <Twistlock_user_API_token> \
 -oseProject twistlock
```


- Output:

```
OpenShift Console: https://master.openshift.example.com:8443
OpenShift internal registry: docker-registry.default.svc:5000
OpenShift Twistlock Project name: twistlock
Twistlock Console: https://tl-console.apps.openshift.example.com
Twistlock Credential Name: OSE-Internal-Registry-Scanner
Removing all registry settings in Defend > Vulnerabilities > Registry: false

2019/08/09 13:37:10 Attempting to connect to OpenShift via username/password...
2019/08/09 13:37:12 Connected to: https://master.openshift.example.com:8443
Connected to OpenShift cluster, https://master.openshift.example.com:8443
Number of projects: 23
aqsa
	Images: [aqsa/busybox aqsa/ubuntu]
ashley
	No images found
compliance
	Images: [compliance/passwd_perms]
default
	No images found
dsop
	Images: [dsop/dsop_ubi_stig dsop/ubi_stig]
jenkins
	No images found
jjones
	No images found
kube-public
	No images found
kube-service-catalog
	No images found
kube-system
	No images found
management-infra
	No images found
mytest
	Images: [mytest/client]
openshift
	Images: [openshift/dotnet openshift/dotnet-runtime openshift/fis-java-openshift openshift/fis-karaf-openshift openshift/httpd openshift/igiveup-apb openshift/java openshift/jboss-amq-62 openshift/jboss-amq-63 openshift/jboss-datagrid65-client-openshift openshift/jboss-datagrid65-openshift openshift/jboss-datagrid71-client-openshift openshift/jboss-datagrid71-openshift openshift/jboss-datagrid72-openshift openshift/jboss-datavirt63-driver-openshift openshift/jboss-datavirt63-openshift openshift/jboss-decisionserver62-openshift openshift/jboss-decisionserver63-openshift openshift/jboss-decisionserver64-openshift openshift/jboss-eap64-openshift openshift/jboss-eap70-openshift openshift/jboss-eap71-openshift openshift/jboss-fuse70-console openshift/jboss-fuse70-eap-openshift openshift/jboss-fuse70-java-openshift openshift/jboss-fuse70-karaf-openshift openshift/jboss-processserver63-openshift openshift/jboss-processserver64-openshift openshift/jboss-webserver30-tomcat7-openshift openshift/jboss-webserver30-tomcat8-openshift openshift/jboss-webserver31-tomcat7-openshift openshift/jboss-webserver31-tomcat8-openshift openshift/jenkins openshift/jenkins-agent-nodejs-8-rhel7 openshift/jenkins-slave-base-rhel7 openshift/mariadb openshift/mongodb openshift/mysql openshift/nginx openshift/nodejs openshift/perl openshift/php openshift/postgresql openshift/python openshift/redhat-openjdk18-openshift openshift/redhat-sso70-openshift openshift/redhat-sso71-openshift openshift/redhat-sso72-openshift openshift/redis openshift/rhdm70-decisioncentral-openshift openshift/rhdm70-kieserver-openshift openshift/rhpam70-businesscentral-indexing-openshift openshift/rhpam70-businesscentral-monitoring-openshift openshift/rhpam70-businesscentral-openshift openshift/rhpam70-controller-openshift openshift/rhpam70-kieserver-openshift openshift/rhpam70-smartrouter-openshift openshift/ruby openshift/tldeploy-apb openshift/twistlock1-apb openshift/twistlock1811103-apb openshift/twistlock2-apb openshift/twistlock3-apb openshift/wildfly]
openshift-ansible-service-broker
	No images found
openshift-infra
	No images found
openshift-logging
	No images found
openshift-node
	Images: [openshift-node/node]
openshift-sdn
	Images: [openshift-sdn/node]
openshift-template-service-broker
	No images found
openshift-web-console
	No images found
pfox-apb-test
	Images: [pfox-apb-test/pfox-test-apb pfox-apb-test/pfox-test-apb1 pfox-apb-test/pfox-test2-apb pfox-apb-test/pfox-test3-apb]
twistlock
	Images: [twistlock/nginx-example]
Total # of images found: 79
Service Account: twistlock-service-dockercfg-xxxx
Twistlock Service Account's Secret: eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJhcXNhIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZWNyZXQubmFtZSI6InR3aXN0bG9jay1zZXJ2aWNlLXRva2VuLTdsZzlwIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6InR3aXN0bG9jay1zZXJ2aWNlIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQudWlkIjoiYmQxNTVjMjYtMTUxOC0xMWU5LWExOGItMDI3RWE3Y2MxODEyIiwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50OmFxc2E6dHdpc3Rsb2NrLXNlcnZpY2UifQ.B_Ym6eTZCjG3zrRdxEMh-37HoNCbj0e2RQU6RXGO2mNVKsq13CMOpJ2qufMQcnnng3GwDfU_w1wg3eblkJBkfVf2aZc3_lfdxJ0JTKrrijvGsq3z1Jn3eXTlKXetBRo4DbWUn4j4PiO2ngI4rDQWpNahSLsKILvUbu66HwrmeOKoNDYRM1UWd1X3Bn0xAIEoZyFgYQ3OYv-h_VH0eKlgcGgA0O9LmufUCPif7BjSrmjSxbVyVXsbK7amHzR1L7jqsgUX--YrJQxiiTVPdjzHEdLueVE4Twl2itvR22atFP0XCUb1f7nkUNPqbXEzqJNEwmjWfA4EDJSbBVCKBkdzXg


**NOTE**:
Give the Twistlock Service account the right to read the OpenShift registry, for example:
	OpenShift v3.6: oc adm policy add-cluster-role-to-user system:image-puller system:serviceaccount:twistlock:twistlock-service
	OpenShift v3.10: oc policy add-role-to-user system:image-puller system:serviceaccount:twistlock:twistlock-service
Check your OpenShift version's documentation. Otherwise Twistlock Registry scanning will error with 401 unauthorized.

Post Credential via API response: 200 OK
2019/08/09 13:37:28 200 OK
Put registry settings via API response: 200 OK
2019/08/09 13:37:29 200 OK
```

## Powershell

### Prerequisites
* Session is authenticated to the OpenShift cluster
* Powershell has access to OpenShift Command Line Interface (oc)
* Powersell v6 https://blogs.msdn.microsoft.com/powershell/2018/01/10/powershell-core-6-0-generally-available-ga-and-supported/

### Modify the following script variables for your environment
* $twistlock_API - endpoint of the Twistlock API
* $TL_service_account_password - Twistlock Service Account password. See notes within the script on how to get the password
* $TL_flush_registry_settings = [bool]$true will remove all registry entries in Defend > Vulnerabilities > Registry

### Execute

```
./tl-ose-registry-populator.ps1
```
