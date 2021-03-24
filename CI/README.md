# CI platform integrations

As you browse these subdirectories, you may notice a common theme with the examples: most of them are wrappers around [`twistcli`'s](https://docs.twistlock.com/docs/compute_edition/tools/twistcli_scan_images.html) scanning functions.

`twistcli` is a statically-built program that can scan hosts, container images, serverless functions, and IaC files.
Because of this, dropping it into a build pipeline is generally as simple as pulling it from your Prisma Cloud Compute Console's API, making it executable, and running it.
Furthermore, many pipelines share a similar syntax, so adapting one of these examples to a platform not covered here may be relatively straightforward.

If there are any platforms or use cases not covered here that are important to you and you feel should be represented, please feel free to open an issue or pull request.
