# AWS CodeBuild

Set up Prisma Cloud to scan your container images and serverless functions after they're built in your CI/CD pipeline. By scanning your artifacts for vulnerabilities and compliance issues at build-time, you give developers immediate feedback about the security problems that must be addressed before artifacts progress to the next stage (e.g. pushing them to the registry).

Security policies are centrally defined in Console. Policies let you hard-fail builds when issues are detected. Or alternatively, you can simply raise an alert, but allow the pipeline to progress to the next stage.

# How the integration works

The example `buildspec.yml` file in this directory integrates Prisma Cloud's CI scanning capabilities with AWS CodeBuild.
This sample illustrates the steps needed to build a Docker image and scan it with Prisma Cloud.

The integration requires just three lines of code be added to your `buildspec.yml`:

```
- curl -k -u $TL_USER:$TL_PASS --output ./twistcli $TL_CONSOLE_URL/api/v1/util/twistcli
- chmod +x ./twistcli
- ./twistcli images scan --details -address $TL_CONSOLE_URL -u $TL_USER -p $TL_PASS $IMAGE_REPO_NAME:$IMAGE_TAG
```

The first line connects to Prisma Cloud Console, and downloads the scanner (twistcli).
The second line makes the scanner binary executable.
And the final line runs the scanner.
The scanner connects back to Console, and it must be authenticated.
Be sure to create a CI User (the lowest privileged role) in Console specifically for the purpose of running the scanner.

# Integrating the scanner into your build

## Prerequisites

* CodeBuild must have network connectivity to your Prisma Cloud Console.
* You must specify the following environment variables in CodeBuild:
** `TL_USER`: Prisma Cloud Compute user with the CI User role.
** `TL_PASS`: Password for this user account.
** `TL_CONSOLE_URL`: Base URL for Console -- https://console.<my_company>.com:8083 -- no trailing slash (`/`).

## Procedure

1. Enter the following commands in the `post_build` phase of your `buildspec.yml`:

   ```
   - curl -k -u $TL_USER:$TL_PASS --output ./twistcli $TL_CONSOLE_URL/api/v1/util/twistcli
   - chmod +x ./twistcli
   - ./twistcli images scan --details -address $TL_CONSOLE_URL -u $TL_USER -p $TL_PASS $IMAGE_REPO_NAME:$IMAGE_TAG
   ```

2. Set your vulnerability and compliance policy for the build in Prisma Cloud Console.
The following rule fails the build if critical vulnerabilities are detected.
If high severity vulns are found, they're simply reported.
And to make the intelligence actionable, the rule only has affect if the vulnerabilities have vendor fixes.

   <img width="600" alt="prisma_cloud_compute_vuln_rule" src="https://user-images.githubusercontent.com/6518946/83057385-745cf900-a01c-11ea-928f-da6855650a7f.png">

3. In AWS, run the pipeline by clicking *Release Change*.

   <img width="1376" alt="aws_codepipeline_release_change" src="https://user-images.githubusercontent.com/6518946/83057678-df0e3480-a01c-11ea-9c5a-178c077aca31.png">

4. In Prisma Cloud Console, review the results.
In this build, my image was clean -- 0 vulns :)

   <img width="1397" alt="prisma_cloud_compute_build_results" src="https://user-images.githubusercontent.com/6518946/83057757-f64d2200-a01c-11ea-8a6c-b4f2adc3739c.png">
