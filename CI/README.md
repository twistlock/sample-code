# CI/CD tool integrations

As you browse these subdirectories, you may notice a common theme with the integrations: most of them are wrappers around the [`twistcli`](https://docs.twistlock.com/docs/compute_edition/tools/twistcli_scan_images.html) tool.

`twistcli` is a statically built program that can scan hosts, container images, serverless functions, and IaC files. Because of this, dropping it into a build pipeline is generally as simple as getting it from your Prisma Cloud Compute Console's API, making it executable, and running it.

If there are any use cases not covered in the documentation that are important to you and you feel should be represented, feel free to open an issue or pull request in [this repository](https://github.com/twistlock/sample-code).
