# azure-devops-twistcli-task
Azure DevOps build and release task to perform container image scanning using twistcli

The extension currently assumes that the twistcli tool is present. You can use a separate task (e.g. Universal Package download) to download it into your Azure DevOps Pipeline. That way you can use this same extension with different versions of `twistlci`. The `twistcli` version must match the Console version.

To build the extension from source, run this command from this directory:

```
# compile TypeScript task.ts into task.js
tsc -p 'tasks/twistcli-scan/tsconfig.json'
# package extension as .vsix zip file
tfx extension create --manifest-globs vss-extension.json
```

The output will be a `.vsix` file.
For more information, please see the Microsoft docs: https://docs.microsoft.com/en-us/azure/devops/extend/develop/add-build-task?view=azure-devops#step-4-package-your-extension
