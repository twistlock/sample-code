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

// Simple wrapper around Twistlock's twistcli tool.
async function run() {
    try {
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
        if (tl.getInput('scanType', true) === "serverless") {
            twistcli.arg("serverless");
        } else {
            twistcli.arg("images");
        }
        twistcli.arg("scan");

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

        // Set vulnerability configuration.
        twistcli.arg(['--vulnerability-threshold', tl.getInput('vulnerabilityThreshold', true)]);
        // --grace-period is only for container images
        if (tl.getInput('scanType', true) === "images") {
            twistcli.arg(['--grace-period', tl.getInput('gracePeriod', true)]);
        }

        if (tl.getBoolInput('onlyFixed', true)) {
            twistcli.arg('--only-fixed');
        }

        // Set compliance configuration.
        twistcli.arg(['--compliance-threshold', tl.getInput('complianceThreshold', true)]);

        // Set Twistlock console authentication configuration.
        twistcli.arg(['--user', twistlockServiceEndpointAuthorization.parameters.username]);
        twistcli.arg(['--password', twistlockServiceEndpointAuthorization.parameters.password]);

        // Show detailed vulnerability and compliance information.
        twistcli.arg('--details');

        // Set the image or functions zip to be scanned.
        twistcli.arg(tl.getInput('artifact', true));

        // Execute twistcli.
        let exitCode: number = await twistcli.exec(<tr.IExecOptions>{
            cwd: ".",
            failOnStdErr: false,
            errStream: process.stdout,
            outStream: process.stdout,
            ignoreReturnCode: true,
            env: {},
            silent: false,
            windowsVerbatimArguments: false
        });

        if (exitCode == 0) {
            tl.setResult(tl.TaskResult.Succeeded, '');
        } else {
            tl.setResult(tl.TaskResult.Failed, 'Either scanning failed or the scan results do not satisfy policy. Check the logs for details.');
        }
    }
    catch (err) {
        tl.setResult(tl.TaskResult.Failed, err);
    }
}

run();
