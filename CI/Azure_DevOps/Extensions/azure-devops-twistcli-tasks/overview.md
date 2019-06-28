# Tasks for scanning container images and serverless functions in pipelines using twistcli

## How to use
The extension assumes that the `twistcli` command is available in the `PATH` (e.g. `usr/bin`) and executable. You can use a separate task (e.g. Universal Package download) to download it into your Azure DevOps Pipeline.

```
# Example for Command Line Task after Universal Download
sudo mv $(System.DefaultWorkingDirectory)/twistcli /usr/bin/twistcli
sudo chmod +x /usr/bin/twistcli
```

 We've made `twistcli` pluggable by design so there's no need to uninstall/reinstall the Twistlock extension from your organizations/projects/pipelines for each new Twistlock version upgrade, simply upload the updated `twistcli` binary to your feed and select that version to be used in your pipeline.

---
**NOTE**

The `twistcli` version needs to match the Twistlock Console version.

---

## Available tasks

Azure DevOps

1. **Twistlock twistcli scan** which scans a Docker container image or serverless function bundle zip file, displays the results locally, and sends them to the Twistlock Console.
2. **Twistlock embed RASP** which updates a Dockerfile allowing for the RASP defender to be embedded in the container image as it's built.

## Get the source

The [source](https://github.com/twistlock/sample-code/tree/master/CI/Azure_DevOps/Extensions/azure-devops-twistcli-tasks) for this extension is on GitHub.

## Contribute

This extension was created by Mario Weigel and is now stewarded by Twistlock and the Twistlock user community.

## Feedback and issues

If you have feedback or issues, please file an issue on [GitHub](https://github.com/twistlock/sample-code/issues)

