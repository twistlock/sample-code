This pulls the images data from a Twistlock console and formats it as an HTML vulnerability report per image.

It expects environment variables for Twistlock config:

* TL_CONSOLE:  URL of the console (`https://twistlock.contoso.com:8083`)
* TL_USER:  Username to use for generating the report.  Must have the Auditor role or higher
* TL_USER_PW:  Password for TL_USER
