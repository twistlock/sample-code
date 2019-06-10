Procedure
1. Add Twistlock Console credentials and FQDN (without trailing `/`) to `twistlock/bin/meta/config.json`.
2. Drop the `twistlock` directory into `$SPLUNK_HOME/etc/apps`.
3. Run `$SPLUNK_HOME/bin/splunk restart` to enable the app.

Enable scripts: The inputs are disabled by default, so after adding the app, go to Settings > Data inputs > Scripts and enable the two scripts added by the app.

Setting script interval: The poll-forensics.py script uses a file created by poll-incidents.py to only pull relevant forensics information. Be sure to set poll-forensics.py to run slightly after poll-incidents.py. A few minutes is probably fine. A one minute gap was used during testing.
