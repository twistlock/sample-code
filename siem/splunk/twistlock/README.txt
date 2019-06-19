Twistlock Splunk App
====================

Author: Wyatt Gill

The Twistlock Splunk App allows high priority security incidents from Twistlock to be sampled by Splunk on a user-defined interval and provides in-depth forensic data for incident anaylysis and response.

The Twistlock Splunk App adds two main components to your Splunk deployment: two scripted data inputs for Twistlock Incidents and Forensics and a Splunk dashboard that samples that data.

The app makes use of your Twistlock Console’s API to pull data into Splunk and apply a couple of field extractions to make the information more useful.


Install procedure:

Add Twistlock Console credentials and FQDN (without trailing /) to twistlock/bin/meta/config.json.
For example, your file could look like this:
{
  "credentials": {
    "username": "user",
    "password": "pass"
  },
  "setup": {
    "console_fqdn": "https://your.twistlock.console.url:8083"
  }
}
Drop the twistlock directory into $SPLUNK_HOME/etc/apps on the necessary Splunk host(s). See Splunk documentation for specific details based on deployment architecture.

Run $SPLUNK_HOME/bin/splunk restart to enable the app.

Enable scripts: The inputs are disabled by default, so after adding the app, go to Settings > Data inputs > Scripts and enable the two scripts added by the app.

Setting script interval: The poll-forensics.py script uses a file created by poll-incidents.py to only pull relevant forensics information. Be sure to set poll-forensics.py to run slightly after poll-incidents.py. A few minutes is probably fine. A one minute gap was used during testing.
