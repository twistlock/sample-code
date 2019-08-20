## Concourse twistcli scan

#### Scan image from registry flow

 - Make your own git repo and place the code in this directory (and subdir) in it
like https://github.com/jpadams/concourse-test

 - Modify the `pipeline.yml` file to set the `twistlock-repo` resource's `source: {uri:}`
and `TL_CONSOLE_URL` in the `twistlock-scan` job.

 - For a workflow where you build your image and push it to a public registry before this scan step,
you should be able to modify the `twistcli-scan` job in `pipeline.yml`
to set your `twistcli` scan parameters including image to scan and
thresholds for vulns and compliance.

#### Build and scan flow

 - Alternatively, you could create a git repo with this code plus a `Dockerfile` and any other needed files.
In the `twistcli-scan.sh` file you can then insert a `docker build` commmand before running the scan.

This is just a sample, so of course this flow could be further perfected.
