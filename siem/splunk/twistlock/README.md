# Prisma Cloud Compute Splunk App

_Updated for Prisma Cloud Compute (formerly Twistlock) versions 19.11 and onwards. Previous Twistlock versions are not supported._

**Important**: This app is delivered as-is and without guaranteed support from Palo Alto Networks.

The Prisma Cloud Compute Splunk App allows high priority security incidents from Prisma Cloud to be sampled by Splunk on a user-defined interval and provides in-depth forensic data for incident analysis and response.

The app adds two main components to your Splunk deployment: scripted data inputs that make use of your Prisma Cloud Compute capabilities API to pull incidents and forensics and a sample Splunk dashboard that presents that data.

## Installation
### Splunkbase
_Note: The app version on Splunkbase may fall behind the app version in the GitHub repository.
1. Download the app tarball from [Splunkbase](https://splunkbase.splunk.com/app/4555).
2. Install the app. Splunk documentation can be found [here](https://docs.splunk.com/Documentation/AddOns/released/Overview/Installingadd-ons) if necessary.
3. Restart Splunk if necessary.

### GitHub
1. Download the app tarball (pcc-splunk-app-*.tar.gz) from the [twistlock/sample-code repository](https://github.com/twistlock/sample-code/tree/master/siem/splunk).
2. Install the app. Splunk documentation can be found [here](https://docs.splunk.com/Documentation/AddOns/released/Overview/Installingadd-ons) if necessary.
3. Restart Splunk if necessary.

## Setup
1. Add Prisma Cloud Compute Console API credentials and URL (without trailing `/`) to `bin/data/config.json`. If you are using Prisma Cloud Compute Edition (self-hosted), this will likely just be your normal username and password and the address in your URL bar. If you are using Prisma Cloud Enterprise Edition (SaaS), this will be your access key and secret key (NOT email address and password) and the address found at **Compute > Manage > System > Downloads** under the **Path to Console** heading. For example, your file could look like this:
```json
{
  "credentials": {
    "username": "user",
    "password": "pass"
  },
  "console": {
    "url": "https://your.console.url:8083"
  }
}
```

2. Enable `poll-incidents.py` and `poll-forensics.py` at **Settings > Data inputs > Scripts**.

3. **Optional:** Adjust the schedule as needed. The `poll-forensics.py` script uses a file created by `poll-incidents.py` to only pull relevant forensics information. Be sure to schedule `poll-forensics.py` to run slightly after `poll-incidents.py`. A few minutes is probably fine. A one-minute gap was used during testing.

## Change notes
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
