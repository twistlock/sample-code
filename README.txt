Twistlock Splunk App
====================

The Twistlock Splunk App adds two main components to your Splunk deployment: two scripted data inputs for Twistlock Incidents and Forensics and a Splunk dashboard that samples the utility of that data.

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

Within an hour you will have data populated:
  * Incidents pulled on the hour :00 mark
  * forensics pulled on the :05 mark
