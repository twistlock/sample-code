Copy proper version of setup script to TEMPLATE_use** to file removing TEMPLATE_ and fill in appropriate values
Do not make setup file executable, instead source it to set env variables and download twistcli if needed
Check env with % env | grep TL

EXAMPLE: 
  % cp TEMPLATE_useSelfHosted useSelfHosted
  % <edit useSelfHosted and fill in env variable values>
  % source useSelfHosted 
  % env | grep TL

