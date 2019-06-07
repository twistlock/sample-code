# azure-devops-twistcli-tasks
Azure DevOps build and release tasks to perform container image scanning using twistcli or embedding the RASP defender.

The extension currently assumes that the twistcli tool is present. You can use a separate task (e.g. Universal Package download) to download it into your Azure DevOps Pipeline. That way you can use this same extension with different versions of `twistlci`. The `twistcli` version must match the Console version.

To build the extension from source, run this command from this directory:

```
From within the "sample-code/CI/Azure_Devops/Extensions/azure-devops-twistcli-tasks" directory, execute:

1. npm install
2. npm run build
```

The output will be a `.vsix` file.
For more information, please see the Microsoft docs: https://docs.microsoft.com/en-us/azure/devops/extend/develop/add-build-task?view=azure-devops#step-4-package-your-extension
