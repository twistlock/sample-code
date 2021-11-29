# pcs-compute-report-generator
This project creates HTML or PDF reports for Vulnerability and Compliance data pulled from a Prisma Cloud Compute (formerly Twistlock) instance.

## Setup
First clone this repo:

```
git https://github.com/twistlock/sample-code.git
```

It is recommended you create a virtual environment to keep installed python packages isolated from the rest of your system:

```
cd sample-code/Reporting-v2
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

Finally, you will need to install [wkhtmltopdf](https://wkhtmltopdf.org/downloads.html) for your platform.

```
homebrew: brew install --cask wkhtmltopdf
```

## Environment Variables
To fun reports with this script you will need 3 environment variables:

| Environment Variable     | Description                               |
|----------------------    |-------------------------------------------|
| COMPUTE_CONSOLE_ADDRESS  | Compute Console address                   |
| COMPUTE_ACCESS_KEY       | Your username for the instance            |
| COMPUTE_SECRET_KEY       | Your password                             |

## Usage Examples
`create_report.py` creates customized vulnerability and compliance reports using several options. Below are some examples:

To create summary report (do not include vulnerability and compliance details, just stats):
```
create_report.py --summary
```

To create an HTML report:
```
create_report.py -f html
```

To create a vulnerability only report:
```
create_report.py -vo
```

To create a report for a specific collection, or list of collections:
```
create_report.py -c collection1 collection 2 ...
```

To list all collections and exit (No report generated):
```
create_report.py --list-collections
```

The full list of options is below:
```
usage: create_report.py [-h] [-d] [-t {deployed,registry,ci}] [-f {pdf,html}] [-c COLLECTIONS [COLLECTIONS ...]] [-s] [-vo] [-co] [-lc]

Create Compute Reports

optional arguments:
  -h, --help                                                                     show this help message and exit
  -d, --debug                                                                    Prints debug output during report creation
  -t {deployed,registry,ci}, --type {deployed,registry,ci}                       Used to select the type of report to run. DEFAULT: deployed
  -f {pdf,html}, --format {pdf,html}                                             Selects the file format of the generated report. DEFAULT: pdf
  -c COLLECTIONS [COLLECTIONS ...], --collections COLLECTIONS [COLLECTIONS ...]  Restrict report to the provided collection(s).
  -s, --summary                                                                  Summary only, do not include vulnerability or compliance details
  -vo, --vulnerabilities-only                                                    Exclude Compliance data from report
  -co, --compliance-only                                                         Exclude Vulnerabilities data from report
  -lc, --list-collections                                                        Lists all collections
```
