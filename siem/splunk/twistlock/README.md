# Prisma Cloud Compute Splunk App

**Important**: This app is delivered as-is and without guaranteed support from Palo Alto Networks.

The Prisma Cloud Compute Splunk App allows high priority security incidents from Prisma Cloud to be sampled by Splunk on a user-defined interval and provides in-depth forensic data for incident analysis and response.

The app adds two main components to your Splunk deployment: scripted data inputs that make use of your Prisma Cloud Compute API to pull incidents and forensics and a sample Splunk dashboard that presents that data.

## Getting the app
### GitHub
Download the latest app tarball (`pcc-splunk-app-*.tar.gz`) from the [twistlock/sample-code repository](https://github.com/twistlock/sample-code/tree/master/siem/splunk).

### Splunkbase
Download the latest app tarball from [Splunkbase](https://splunkbase.splunk.com/app/4555).

### Splunk Apps Browser
In the Splunk UI, click on the Apps dropdown, click "Find More Apps", then search for Prisma Cloud Compute.

## Installation and setup
1. Install the app by either uploading the tarball or following the Splunkbase prompts.
2. Navigate to the setup page if you aren't guided there.
3. Fill out the setup form and click "Complete setup."
Field descriptions are on the setup page.
4. Enable `poll_incidents.py` and `poll_forensics.py` at **Settings > Data inputs > Scripts** in Splunk.
5. (Optional) Adjust the schedule as needed. By default, the `poll_forensics.py` script runs 2 minutes after `poll_incidents.py` and both scripts will run every 5 minutes.

## FAQs
### What user role is required?
Any user role that is able to view incidents and forensic data. This is a user with at least the [DevSecOps role](https://docs.twistlock.com/docs/compute_edition/authentication/user_roles.html#devsecops-user) (self-hosted Compute) or [Account Group Read Only role](https://docs.twistlock.com/docs/enterprise_edition/authentication/prisma_cloud_user_roles.html#prisma-cloud-roles-to-compute-roles-mapping) (SaaS Compute).

### What is my SaaS Compute Console address?
You can find it at **Compute > Manage > System > Utilities** under the **Path to Console** heading.

### Where is the configuration stored?
Whenever you complete the setup, `local/twistlock.conf` and `local/passwords.conf` are created.
The passwords are stored and accessed using [Splunk's encrypted password storage APIs](https://www.splunk.com/en_us/blog/security/storing-encrypted-credentials.html).

## Troubleshooting
If incidents and/or forensics are not being ingested into Splunk, please verify the following:

- You have at least one incident at **Monitor > Runtime > Incident Explorer** under the "Active" tab.
- You are able to see the incident's forensic data by clicking on the "Forensic snapshot" button.
- The values in `local/twistlock.conf` are correct.
If any are not correct, use the setup page with the same Console configuration name to update them.
- The app's scripts are enabled in Splunk (#4 in instructions), and have been ran at least once (#5 in instructions).

If data is still not being ingested, check `$SPLUNK_HOME/var/log/splunk/splunkd.log` for messages related to `poll_incidents.py` and `poll_forensics.py`:
```
index="_internal" source="/opt/splunk/var/log/splunk/splunkd.log" ("poll_incidents.py" OR "poll_forensics.py")
```

## Change notes

### June 16, 2021 - v4.0.0
- Added an app setup page

### April 9, 2021 - v3.2.3
- Fixed issue with SaaS Console URL paths getting stripped.

### March 23, 2021 - v3.2.2
- Fixed issue with highest serial number tracking.

### February 19, 2021
- Improved resilence to unexpected exits ([#94](https://github.com/twistlock/sample-code/issues/94)).
- Removed requirement for no trailing slash on Console URL. Now it does not matter if one is present.

### February 17, 2021 - v3.2.0
- Changed the method of getting projects to not require an admin user ([#91](https://github.com/twistlock/sample-code/issues/91)).

### January 28, 2021
- Fixed bad data being added to forensics_events.txt when poll_incidents.py is ran multiple times before poll_forensics.py.
- Fixed premature exit when a project in the list of projects does not have any new incidents.

### December 7, 2020
- Added projects support
- Cleaned up code
  - Introduced an API wrapper file for common functions

### October 14, 2020
- Cleaned up code
  - Refactored to use functions
- Enhanced exception handling
- Verified Compute 20.09 support
- Verified Splunk 8 support

#### March 23, 2020
- Combined Windows and Linux `inputs.conf` files. See that file for details.
- Timestamps used in the forensic data now include nanosecond precision.
- Switched from basic authentication to token-based authentication on all API calls.
- Added an `incidentID` field to each forensic event to simplify matching forensic events to their incidents.
