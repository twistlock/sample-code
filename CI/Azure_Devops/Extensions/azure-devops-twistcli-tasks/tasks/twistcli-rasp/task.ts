import fs = require("fs");
import path = require("path");
import tl = require('azure-pipelines-task-lib/task');
import tr = require('azure-pipelines-task-lib/toolrunner');

// Write the CA certificate received from the DevOps service connection configuration to a temporary file.
function writeCACertificate(caCertData: string): string {
    let tempDirectory = tl.getVariable('agent.tempDirectory');
    tl.checkPath(tempDirectory, `${tempDirectory} (agent.tempDirectory)`);

    let caCertPath = path.join(tempDirectory, 'ca-cert.pem');
    fs.writeFileSync(caCertPath, caCertData);

    return caCertPath;
}

// Taken from https://github.com/Microsoft/azure-pipelines-tasks/blob/master/Tasks/Common/docker-common/fileutils.ts
function findDockerFile(dockerfilepath: string): string {
    if (dockerfilepath.indexOf('*') >= 0 || dockerfilepath.indexOf('?') >= 0) {
        tl.debug('ContainerPatternFound');
        let workingDirectory = tl.getVariable('System.DefaultWorkingDirectory');
        let allFiles = tl.find(workingDirectory);
        let matchingResultsFiles = tl.match(allFiles, dockerfilepath, workingDirectory, { matchBase: true });

        if (!matchingResultsFiles || matchingResultsFiles.length == 0) {
            throw new Error(tl.loc('ContainerDockerFileNotFound', dockerfilepath));
        }

        return matchingResultsFiles[0];
    }
    else {
        tl.debug('ContainerPatternNotFound');
        return dockerfilepath;
    }
}

function executeRASP(dockerfilePath: string, outputFilePath: string) {
    // Get Twistlock service endpoint configuration. This inclues the URL of the Twistlock console, the username
    // and password used to authenticate twistcli to the console and the certificate of the CA that issued the
    // console's certificate so that it can be verified.
    //
    // https://docs.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints?view=azure-devops
    let twistlockServiceEndpoint: string = tl.getInput('twistlockService', true);
    const twistlockServiceEndpointAuthorization = tl.getEndpointAuthorization(twistlockServiceEndpoint, false);

    // Construct twistcli command line.
    let twistcliPath: string = tl.which('twistcli', true);
    let twistcli = tl.tool(twistcliPath);

    // Embed rasp defender.
    twistcli.arg(["rasp", "embed"]);

    // Set console address.
    if (!tl.getEndpointUrl(twistlockServiceEndpoint, true).startsWith('https://')) {
        throw 'The Twistlock console must be accessed via https'
    } else {
        twistcli.arg(['--address', tl.getEndpointUrl(twistlockServiceEndpoint, true)]);
    }

    // If supplied, write the CA certificate received from the DevOps service connection configuration
    // to a temporary location so its path can be passed as an option to twistcli.
    if (twistlockServiceEndpointAuthorization.parameters.tlscacert != '') {
        let caCertPath = writeCACertificate(twistlockServiceEndpointAuthorization.parameters.tlscacert)
        twistcli.arg(['--tlscacert', caCertPath]);
    } else {
        tl.warning('No CA certificate supplied in Twistlock console service connection');
        tl.warning('The connection to the Twistlock console is insecure');
    }

    // Set app ID.
    twistcli.arg(['--app-id', tl.getInput('appID', true)]);

    // Set console host.
    twistcli.arg(['--console-host', tl.getInput('consoleHost', true)]);

    // Set data folder.
    twistcli.arg(['--data-folder', tl.getInput('dataFolder', true)]);

    // Set output file.
    twistcli.arg(['--output-file', outputFilePath]);

    // Set Twistlock console authentication configuration.
    twistcli.arg(['--user', twistlockServiceEndpointAuthorization.parameters.username]);
    twistcli.arg(['--password', twistlockServiceEndpointAuthorization.parameters.password]);

    // Set the path to the Dockerfile.
    twistcli.arg(dockerfilePath);

    // Execute twistcli.
    let results: tr.IExecSyncResult = twistcli.execSync(<tr.IExecOptions>{
        cwd: ".",
        failOnStdErr: false,
        errStream: process.stdout,
        outStream: process.stdout,
        ignoreReturnCode: true,
        env: {},
        silent: false,
        windowsVerbatimArguments: false
    });

    if (results.code != 0) {
        throw 'Unable to update the Dockerfile. Check the logs for details.'
    }
}

function overwriteDockerfile(dockerDirPath: string, outputFilePath: string) {
    let unzipPath: string = tl.which('unzip', true);
    let unzip = tl.tool(unzipPath);

    // Execute unzip.
    unzip.arg(["-o", "-d", dockerDirPath, outputFilePath]);
    let result: tr.IExecSyncResult = unzip.execSync(<tr.IExecOptions>{
        cwd: ".",
        failOnStdErr: false,
        errStream: process.stdout,
        outStream: process.stdout,
        ignoreReturnCode: true,
        env: {},
        silent: false,
        windowsVerbatimArguments: false
    });

    if (result.code != 0) {
        throw 'Unable to overwrite the Dockerfile. Check the logs for details.'
    }
}

// Simple wrapper around Twistlock's twistcli tool.
async function run() {
    try {
        let dockerfilePath = findDockerFile(tl.getInput('dockerfile', true));
        let tempDirectory = tl.getVariable('agent.tempDirectory');
        tl.checkPath(tempDirectory, `${tempDirectory} (agent.tempDirectory)`);
        let outputFilePath = path.join(tempDirectory, 'rasp-' + tl.getVariable('Build.BuildId') + '.zip');

        // Generate the RASP zip file using twistcli.
        executeRASP(dockerfilePath, outputFilePath);

        // Extract the zip file and overwrite the original Dockerfile.
        overwriteDockerfile(path.dirname(dockerfilePath), outputFilePath);

        tl.setResult(tl.TaskResult.Succeeded, '');
    }
    catch (err) {
        tl.setResult(tl.TaskResult.Failed, err);
    }
}

run();
