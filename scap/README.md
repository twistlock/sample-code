# README
## Caveats!
* Twistlock has been installed with SCAP enabled via the twistlock.cfg or the twistlock_console.yaml file.
* Only supported for the scanning of centos, fedora and redhat based images.
* Only failed test results will be reported (passed tests and test results scheduled for the v2.5 release).

## Running it
* When installing Twistlock enable SCAP support. Within the twistlock.cfg set SCAP_ENABLED=true or via the API install within the twistlock_console.yaml file set the _name: SCAP_ENABLED_ to _true_
* In the Twistlock Console go to _*Manage > System > SCAP >*_ click _*Add DataStream*_ and select the SCAP datastream (e.g. passwd_perm_high.xml)
* Go to _*Defend > Compliance > Policy*_ select either an existing policy or click new compliance rule. Scroll down to compliance check id 4000 (note: custom compliance checks will start at ID 4000). Set the failed result Action accordingly (ignore, alert or block).
* To trigger a scan of images within a registry go to _*Monitor > Vulnerabilities > Registry*_ and click _*scan*_.

## Sample SCAP Datastreams
* CCE-3566-7 - File permissions for /etc/passwd should be set correctly (644) - passwd_perm_high.xml
* CCE-3495-9 - The /etc/passwd file should be owned by the appropriate group (root) - passwd_group.xml
* CCE-3958-6 - The /etc/passwd file should be owned by the appropriate user (root) - passwd_owner.xml

## References
* OVAL Repository: https://oval.cisecurity.org/repository/search
* OVAL Test Content: https://github.com/OVALProject/Test-Content
* Perl5 Regular Expressions within OVAL: https://oval.mitre.org/language/about/re_support_5.6.html
