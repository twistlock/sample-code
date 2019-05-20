1. Add credentials and FQDN to bin/meta/config.json.
2. Drop this file's parent directory in $SPLUNK_HOME/etc/apps
3. Run `$SPLUNK_HOME/bin/splunk restart` to enable the app.

Enable scripts: The inputs are disabled by default, so after adding the app, go to Settings > Data inputs > Scripts and enable the two scripts added by the app.

Setting script interval: The poll-forensics.py script uses a file created by poll-incidents.py to only pull relevant forensics information. Be sure to set poll-forensics.py to run slightly after poll-incidents.py (a few minutes is probably fine).