# azure-devops-twistcli-task
Azure DevOps build and release task to perform container image scanning using twistcli

The extension currently assumes that the twistcli tool is present. You can use a separate task (e.g. universal package download) or a curl command to the Twistlock Console to install it.

To build the extension from source, run this command from this directory:

```
tfx extension create --manifest-globs vss-extension.json
```

The output will be a `.vsix` file.
For more information, please see the Microsoft docs: https://docs.microsoft.com/en-us/azure/devops/extend/develop/add-build-task?view=azure-devops#step-4-package-your-extension
