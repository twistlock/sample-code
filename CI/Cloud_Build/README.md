# README
This is a sample of integration with Google Cloud Build using a custom build step to scan the image with `twistcli`.
* `cloud_build_twistcli` is the Dockerfile and script necessary to build the `cloud-build-twistcli` Docker image for the custom build step.  This must be built before scanning any builds.  

`gcloud builds submit --tag gcr.io/{{ GCP Project ID}}/cloud-build-twistcli`

* `cloud_build_sample` is a simple image that uses the `cloud-build-twistcli` custom build step to scan an image after a Docker build.  Edit `cloudbuild.yaml` with parameters for your environment.

## Prereqs 
* Connectivity from Cloud Build to your Twistlock Console
* Properly configured `cloudbuild.yaml`
