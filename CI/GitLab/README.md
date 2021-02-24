This directory contains an example of a basic [GitLab CI/CD pipeline](https://docs.gitlab.com/ee/ci/pipelines/pipeline_architectures.html#basic-pipelines) that integrates container image scanning for vulnerabilities and compliance issues directly into GitLab.

## Requirements
To use this GitLab pipeline, you will need
* a functional Prisma Cloud Compute Console that is reachable from a [GitLab runner](https://docs.gitlab.com/ee/ci/runners/README.html)
* credentials for a Compute user ([CI User](https://docs.twistlock.com/docs/compute_edition/authentication/user_roles.html#ci-user) or [Build and Deploy Security](https://docs.twistlock.com/docs/enterprise_edition/authentication/prisma_cloud_user_roles.html#prisma-cloud-roles-to-compute-roles-mapping) role is recommended)

## Setup
1. Create the variables used by the pipeline (`PCC_USER`, `PCC_PASS`, and `PCC_CONSOLE_URL`). See [GitLab's documentation](https://docs.gitlab.com/ee/ci/variables/README.html#create-a-custom-variable-in-the-ui) for instructions.
2. Add the `.gitlab-ci.yml` file to the root of your repository.

The image will be built, tagged, and scanned using `owner/repository:commit`. This is the image name under which the scan results will be displayed in the Compute Console. You can adjust this with the `IMAGE_NAME` variable in `.gitlab-ci.yml`.

The image scan policy (including failure thresholds) is managed in the Compute Console at
* **Defend > Vulnerabilities > Images > CI**
* **Defend > Compliance > Containers and images > CI**

If you are using a self-signed certificate on the Compute Console, you may have to add `--no-check-certificate` to the `wget` command. For example:
```'wget --header "Authorization: Basic $(echo -n $PCC_USER:$PCC_PASS | base64)" --no-check-certificate $PCC_CONSOLE_URL/api/v1/util/twistcli'```
