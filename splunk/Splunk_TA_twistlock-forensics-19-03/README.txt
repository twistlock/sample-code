--------------------------------------------------------------------------------
1.

Put this file's parent directory in $SPLUNK_HOME/etc/apps/ and restart Splunk.

--------------------------------------------------------------------------------
2.

Put the snippet below in $SPLUNK_HOME/etc/system/local/props.conf. This prevents
fields from being extracted from the two sourcetypes at index time AND search time
causing duplicate fields.

[twistlock:incident]
KV_MODE = none
AUTO_KV_JSON = false

[twistlock:forensic_data]
KV_MODE = none
AUTO_KV_JSON = false

--------------------------------------------------------------------------------
3.

The current configuration uses an index named "twistlock." If you'd like to use
this index, move indexes.conf wherever appropriate.
$SPLUNK_HOME/etc/apps/search/local may be a good location.
You can get more info from the link below:
https://docs.splunk.com/Documentation/Splunk/latest/Indexer/Configureindexstorage

--------------------------------------------------------------------------------
4.

The current configuration uses two field extractions. If you'd like to use
these, move props.conf wherever appropriate.
$SPLUNK_HOME/etc/apps/search/local may be a good location.

--------------------------------------------------------------------------------
5. (optional)

twistlock_forensics.xml is a sample dashboard that makes use of the incident and
forensic information. You can create a new dashboard in the UI and copy the contents
of the file into the source for the new dashboard.
