SOME INFORMATION ON PRISMA CLOUD COMPUTE

In our development practices, we follow the Microsoft Secure Development Lifecycle methodology. All devs are trained as part of their onboarding process and receive ongoing refresher training throughout the year. All changes are peer reviewed and approved prior to being committed. All committed changes to the code base are audited and tracked over time and all access to our build environment requires 2FA and usage of a trusted CI process.

Twistlock uses multiple tools, both open source and commercial, to perform static analysis of each build. We also perform human led, active penetration using both our internal Twistlock Labs research team, as well as independent 3rd party audit firms. We perform at least 1 independent 3rd party audit annually, using a unique firm each cycle to ensure diversity of attack methods and tooling and the results of those tests are available to customers under NDA.
5:19

Yes, in addition to the specific security training all developers receive, Twistlock has on-staff experts in secure development practices, penetration testing, and incident response. These staff members have discovered numerous 0-day CVEs in the container ecosystem, spoken at tier 1 conferences, and assisted Fortune 100 organizations and national governments around the world with responding to incidents.

Twistlock is a commercial off the shelf security product that is deployed and operated directly by customers within their own environments. No customer data ever leaves the customer’s control at any time, period. No logs are ever sent to Twistlock for analysis, no images are sent to Twistlock for scanning, and no telemetry about customer environments is ever sent to Twistlock. Twistlock fully supports running in completely disconnected, offline environments with no internet connectivity.

Twistlock operates a single cloud service, the Intelligence Stream, that collects, curates, and distributes vulnerability and threat data to customers. This is a one way data flow in which customers pull data from the Intelligence Stream. No customer data is uploaded to the Intelligence Stream. Accessing the Intelligence Stream is completely optional, it is not required for Twistlock to operate and Twistlock provides full support for updating this information manually for offline environments.

