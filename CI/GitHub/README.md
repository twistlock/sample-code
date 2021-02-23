This directory contains an example GitHub Action that can be used to integrate vulnerability and compliance scanning with regular pushes and pull requests.

A big shoutout to [@jpadams](https://github.com/jpadams) for the initial sample action and scan.yml used to configure the Action.

## Requirements
To use this GitHub Action, you will need
* a functional Prisma Cloud Compute Console
* credentials for a Compute user ([CI User](https://docs.twistlock.com/docs/compute_edition/authentication/user_roles.html#ci-user) or [Build and Deploy Security](https://docs.twistlock.com/docs/enterprise_edition/authentication/prisma_cloud_user_roles.html#prisma-cloud-roles-to-compute-roles-mapping) role is recommended)

## Setup
1. Add the `.github` directory to the root of your repository.
2. Create the secrets used by the action (`PCC_USER`, `PCC_PASS`, and `PCC_CONSOLE_URL`). See [Github's documentation](https://docs.github.com/en/actions/reference/encrypted-secrets#creating-encrypted-secrets-for-a-repository) for instructions.

The image will be built, tagged, and scanned using `owner/repository:commit`. This is the image name under which the scan results will be displayed in the Compute Console. You can adjust this with the `IMAGE_NAME` variable in `scan.yml`.

The image scan policy (including failure thresholds) is managed in the Compute Console at
* **Defend > Vulnerabilities > Images > CI**
* **Defend > Compliance > Containers and images > CI**
