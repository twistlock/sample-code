#!/bin/sh

# Passed by Concourse. Set in twistlock-scan.yml:
##################################################	
# TL_USER:  The Twistlock user with the CI User role
# TL_PASS:  The password for this user account
# TL_CONSOLE_URL:  The base URL for the console -- http://console.<my_company>.com:8083 -- without a trailing /
# TL_IMAGE: is the image to be scanned.
# TL_VULN_THRESH: "", "low", "medium", "high", "critical" (default: "")
# TL_COMP_THRESH: "", "low", "medium", "high", "critical" (default: "")
# TL_ONLY_FIXED: "", true, false (default: false)
##################################################

# packages needed by stable-dind container to run docker daemon and pull twistcli
apk --no-cache --quiet --no-progress add bash curl util-linux

echo "Starting docker daemon"
bash twistlock-repo/util/docker-engine.sh start
echo

echo "Downloading twistcli from Twistlock Console"
curl -k -u ${TL_USER}:${TL_PASS} --output twistcli ${TL_CONSOLE_URL}/api/v1/util/twistcli
# ...and ensure it's executable.
chmod a+x twistcli
echo

# TODO: until loop maybe to sure daemon is up
# Here is where you would build or pull your docker image to scan
echo "Pulling docker image to scan: ${TL_IMAGE}"
docker pull ${TL_IMAGE}
echo
# TODO: could be doing docker build here if we have docker up
# or maybe use a Concourse docker-image resource??

# Run the scan with twistcli, providing detailed results in Concourse and
# push the results to the Twistlock Console.
# --details returns all vulnerabilities & compliance issues rather than just summaries.
# --address points to our Twistlock Console
# --user and --password provide credentials for Console.  These creds only need the "ciuser" role.
# Finally, we provide the name of the image we built or pulled, above.

thresh_args=$(bash twistlock-repo/util/thresh-args-string.sh ${TL_VULN_THRESH:-""} ${TL_COMP_THRESH:-""} ${TL_ONLY_FIXED:-false})
echo "Running twistcli scan with these arguments: ${thresh_args}"
echo "Results to be sent to Twistlock Console: ${TL_CONSOLE_URL}"
echo

./twistcli images scan --details \
    --address ${TL_CONSOLE_URL} \
    --user ${TL_USER} --password ${TL_PASS} \
    ${thresh_args} \
    ${TL_IMAGE}

#
# add any additional commands needed to test the image, push to a registry, etc.
#

# If the twistcli scan fails (non-zero exit code), the build will fail, else it will pass
exit $?
