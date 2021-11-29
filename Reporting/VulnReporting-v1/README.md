This pulls the images data from a Twistlock console and formats it as an HTML vulnerability report per image.

It expects environment variables for Twistlock config:

* TL_CONSOLE:  URL of the console (`https://twistlock.console.com:8083`)
* TL_USER:  Username to use for generating the report.  Must have the Auditor role or higher
* TL_USER_PW:  Password for TL_USER



## Setup
First clone this repo:

```
git https://github.com/twistlock/sample-code.git
```

It is recommended you create a virtual environment to keep installed python packages isolated from the rest of your system:

```
cd sample-code/Reporting/VulnReporting-v1
python3 -m venv env
```
Activate it:

```
source env/bin/activate
```

Next you will need to install the required python packages:

```
pip install -r requirements.txt
```

## Usage Examples
* report.py for a report on deployed images
* reportCI.py for a report on CI scanned images