# Prisma Cloud Compute Splunk App

**Important**: This app is delivered as-is and without guaranteed support from Palo Alto Networks.

The Prisma Cloud Compute Splunk App allows high priority security incidents from Prisma Cloud to be sampled by Splunk on a user-defined interval and provides in-depth forensic data for incident analysis and response.

The app adds two main components to your Splunk deployment: scripted data inputs that make use of your Prisma Cloud Compute capabilities API to pull incidents and forensics and a sample Splunk dashboard that presents that data.

## Installation
### Splunkbase
_Note: The app version on Splunkbase may fall behind the app version in the GitHub repository._
1. Download the app tarball from [Splunkbase](https://splunkbase.splunk.com/app/4555).
2. Install the app. Splunk documentation can be found [here](https://docs.splunk.com/Documentation/AddOns/released/Overview/Installingadd-ons) if necessary.
3. Restart Splunk if necessary.

### GitHub
1. Download the app tarball (pcc-splunk-app-*.tar.gz) from the [twistlock/sample-code repository](https://github.com/twistlock/sample-code/tree/master/siem/splunk).
2. Install the app. Splunk documentation can be found [here](https://docs.splunk.com/Documentation/AddOns/released/Overview/Installingadd-ons) if necessary.
3. Restart Splunk if necessary.

## Setup
1. Open `bin/data/config.json` for editing and add the appropriate values for your environment. See the annotated example and field descriptions below for more detail:
    ```
    {
      "credentials": {
        "username": "jdoe", [1]
        "password": "Password123!" [1]
      },
      "console": {
        "url": "https://my.console.url:8083", [2]
        "projects": ["Central Console", "my tenant project"] [3]
      }
    }
    ```

    [1] Prisma Cloud Compute Console API credentials. If you are using Prisma Cloud Compute Edition (self-hosted), this will likely just be your normal username and password. If you are using Prisma Cloud Enterprise Edition (SaaS), this will be your [access key and secret key](https://docs.twistlock.com/docs/enterprise_edition/authentication/access_keys.html#provisioning-access-keys). With the default configuration, a user with the [DevSecOps role](https://docs.twistlock.com/docs/compute_edition/authentication/user_roles.html#devsecops-user) is required.

    [2] Prisma Cloud Compute Console URL (without trailing `/`). This URL must be reachable by Splunk. If you are using Prisma Cloud Enterprise Edition (SaaS), this will be the address found at **Compute > Manage > System > Downloads** under the **Path to Console** heading.

    [3] List of projects. This is only applicable to users with [projects](https://docs.twistlock.com/docs/compute_edition/deployment_patterns/projects.html) configured in Prisma Cloud Compute Edition. **If you do not use projects, you can safely leave the default value.** The field accepts two types of values: a list of projects (example above) and the string `"all"` (be sure to include quotes). Using the list, you can specify a set of projects you'd like queried. With the string `"all"`, the script will automatically pull data from all projects. Using `"all"` requires a user with at least the [DevSecOps role](https://docs.twistlock.com/docs/compute_edition/authentication/user_roles.html#devsecops-user).

2. Enable `poll_incidents.py` and `poll_forensics.py` at **Settings > Data inputs > Scripts**.

3. **Optional:** Adjust the schedule as needed. The `poll_forensics.py` script uses a file created by `poll_incidents.py` to only pull relevant forensics information. Be sure to schedule `poll_forensics.py` at least 5 minutes after `poll_incidents.py`.

## Change notes
### February 17, 2021 - v3.2.0
- Changed the method of getting projects to not require an admin user ([#91](https://github.com/twistlock/sample-code/issues/91).

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
