This directory contains an example of a basic [GitHub Action](https://docs.github.com/en/actions) that integrates container image scanning for vulnerabilities and compliance issues directly into GitHub.

## Requirements
To use this GitHub Action, you will need
* a functional Prisma Cloud Compute Console that is reachable from a [GitHub Actions runner](https://github.com/actions/runner)
* credentials for a Compute user ([CI User](https://docs.twistlock.com/docs/compute_edition/authentication/user_roles.html#ci-user) or [Build and Deploy Security](https://docs.twistlock.com/docs/enterprise_edition/authentication/prisma_cloud_user_roles.html#prisma-cloud-roles-to-compute-roles-mapping) role is recommended)

## Setup
1. Create the secrets used by the action (`PCC_USER`, `PCC_PASS`, and `PCC_CONSOLE_URL`). See [GitHub's documentation](https://docs.github.com/en/actions/reference/encrypted-secrets#creating-encrypted-secrets-for-a-repository) for instructions on how to create these.

    If you are using Prisma Cloud Compute Edition (self-hosted), `PCC_USER` and `PCC_PASS` will likely just be your normal username and password of the user with CI User role. `PCC_CONSOLE_URL` will be the address you use to access the Compute Console.

    If you are using Prisma Cloud Enterprise Edition (SaaS), `PCC_USER` and `PCC_PASS` will be your [access key and secret key](https://docs.twistlock.com/docs/enterprise_edition/authentication/access_keys.html#provisioning-access-keys) pair created with the Build and Deploy Security role. `PCC_CONSOLE_URL` will be the address found at **Compute > Manage > System > Downloads** under the **Path to Console** heading.

2. Add the `.github` directory to the root of your repository.

The image will be built, tagged, and scanned using `owner/repository:commit`. This is the image name under which the scan results will be displayed in the Compute Console. You can adjust this with the `IMAGE_NAME` variable in `scan.yml`.

The image scan policy (including failure thresholds) is managed in the Compute Console at
* **Defend > Vulnerabilities > Images > CI**
* **Defend > Compliance > Containers and images > CI**

If you are using a self-signed certificate on the Compute Console, you may have to add `--insecure` to the `curl` command. For example:
```curl --user $PCC_USER:$PCC_PASS --output ./twistcli --insecure $PCC_CONSOLE_URL/api/v1/util/twistcli```
